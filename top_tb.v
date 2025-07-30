`timescale 1ns/1ns
`include "top.v"

module top_tb;

    reg clk = 0;
    reg reset = 1;
    reg wr_en = 0;
    reg rd_en = 0;
    reg [31:0] addr = 0;
    reg [31:0] wdata_in = 0;
    wire [31:0] rdata_out;
    wire read_done;
    wire write_done;

    top DUT (
        .clk(clk),
        .reset(reset),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .addr(addr),
        .wdata_in(wdata_in),
        .rdata_out(rdata_out),
        .read_done(read_done),
        .write_done(write_done)
    );

    always #5 clk = ~clk;

    initial begin
        reset = 1;
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        #20 reset = 0;

        // WRITE: addr=0x00000010, data=0xABCD1234
        @(posedge clk);
        addr <= 32'h00000010;
        wdata_in <= 32'hCEEB2006;
        wr_en <= 1;

        @(posedge clk);
        wr_en <= 0;

        wait(write_done);
        $display("✅ Write complete at %0t", $time);

        // READ from addr=0x00000010
        @(posedge clk);
        addr <= 32'h00000010;
        rd_en <= 1;

        @(posedge clk);
        rd_en <= 0;

        wait(read_done);
        $display("✅ Read complete at %0t, rdata_out = 0x%08x", $time, rdata_out);

        #20 $finish;
    end

endmodule
