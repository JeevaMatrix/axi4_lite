`include "master.v"
`include "axi4.v"

module top (
    input clk,
    input reset,
    input wr_en,
    input rd_en,
    input [31:0] addr,
    input [31:0] wdata_in,
    output [31:0] rdata_out,
    output read_done,
    output write_done
);

    // AXI-Lite Interconnect signals
    wire awvalid, awready;
    wire [31:0] awaddr;

    wire wvalid, wready;
    wire [31:0] wdata;

    wire bvalid, bready;
    wire [1:0] bresp;

    wire arvalid, arready;
    wire [31:0] araddr;

    wire rvalid, rready;
    wire [31:0] rdata;
    wire [1:0] rresp;

    master m (
        .clk(clk),
        .reset(reset),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .addr(addr),
        .wdata_in(wdata_in),
        .rdata_out(rdata_out),
        .read_done(read_done),
        .write_done(write_done),
        .awvalid(awvalid),
        .awaddr(awaddr),
        .awready(awready),
        .wvalid(wvalid),
        .wdata(wdata),
        .wready(wready),
        .bvalid(bvalid),
        .bresp(bresp),
        .bready(bready),
        .arvalid(arvalid),
        .araddr(araddr),
        .arready(arready),
        .rready(rready),
        .rdata(rdata),
        .rvalid(rvalid),
        .rresp(rresp)
    );

    axi4 s (
        .clk(clk),
        .reset(reset),
        .awvalid(awvalid),
        .awaddr(awaddr),
        .awready(awready),
        .wvalid(wvalid),
        .wdata(wdata),
        .wready(wready),
        .bvalid(bvalid),
        .bresp(bresp),
        .bready(bready),
        .arvalid(arvalid),
        .araddr(araddr),
        .arready(arready),
        .rdata(rdata),
        .rvalid(rvalid),
        .rresp(rresp),
        .rready(rready)
    );

endmodule
