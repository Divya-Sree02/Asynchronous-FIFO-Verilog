module async_fifo (
    input  wire        wr_clk,
    input  wire        rd_clk,
    input  wire        reset,

    input  wire        wr_en,
    input  wire [7:0]  wr_data,
    output wire        full,

    input  wire        rd_en,
    output reg  [7:0]  rd_data,
    output wire        empty
);

reg [7:0] mem [0:15];

reg [4:0] wr_ptr_bin;
reg [4:0] rd_ptr_bin;

reg [4:0] wr_ptr_gray;
reg [4:0] rd_ptr_gray;

reg [4:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;
reg [4:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;

function [4:0] bin2gray(input [4:0] bin);
    bin2gray = (bin >> 1) ^ bin;
endfunction

always @(posedge wr_clk or posedge reset) begin
    if (reset) begin
        wr_ptr_bin  <= 0;
        wr_ptr_gray <= 0;
    end
    else if (wr_en && !full) begin
        mem[wr_ptr_bin[3:0]] <= wr_data;
        wr_ptr_bin  <= wr_ptr_bin + 1;
        wr_ptr_gray <= bin2gray(wr_ptr_bin + 1);
    end
end

always @(posedge rd_clk or posedge reset) begin
    if (reset) begin
        rd_ptr_bin  <= 0;
        rd_ptr_gray <= 0;
        rd_data     <= 0;
    end
    else if (rd_en && !empty) begin
        rd_data <= mem[rd_ptr_bin[3:0]];
        rd_ptr_bin  <= rd_ptr_bin + 1;
        rd_ptr_gray <= bin2gray(rd_ptr_bin + 1);
    end
end

always @(posedge wr_clk or posedge reset) begin
    if (reset) begin
        rd_ptr_gray_sync1 <= 0;
        rd_ptr_gray_sync2 <= 0;
    end else begin
        rd_ptr_gray_sync1 <= rd_ptr_gray;
        rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
    end
end

always @(posedge rd_clk or posedge reset) begin
    if (reset) begin
        wr_ptr_gray_sync1 <= 0;
        wr_ptr_gray_sync2 <= 0;
    end else begin
        wr_ptr_gray_sync1 <= wr_ptr_gray;
        wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
    end
end

assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);

assign full =
    (bin2gray(wr_ptr_bin + 1) ==
    {~rd_ptr_gray_sync2[4:3], rd_ptr_gray_sync2[2:0]});

endmodule
