  module tb_async_fifo;

reg wr_clk = 0;
reg rd_clk = 0;
reg reset  = 1;

reg        wr_en;
reg [7:0]  wr_data;
wire       full;

reg        rd_en;
wire [7:0] rd_data;
wire       empty;

async_fifo DUT (
    .wr_clk (wr_clk),
    .rd_clk (rd_clk),
    .reset  (reset),
    .wr_en  (wr_en),
    .wr_data(wr_data),
    .full   (full),
    .rd_en  (rd_en),
    .rd_data(rd_data),
    .empty  (empty)
);

always #5 wr_clk = ~wr_clk;
always #8 rd_clk = ~rd_clk;

initial begin
    $dumpfile("fifo.vcd");
    $dumpvars(0, tb_async_fifo);

    wr_en = 0;
    rd_en = 0;
    wr_data = 0;

    #20 reset = 0;
 
    repeat (20) begin
        @(posedge wr_clk);
        if (!full) begin
            wr_en = 1;
            wr_data = wr_data + 1;
        end
        else begin
            wr_en = 0;
        end
    end

    #50;

    repeat (20) begin
        @(posedge rd_clk);
        if (!empty)
            rd_en = 1;
        else
            rd_en = 0;
    end

    #100 $finish;

end

endmodule
