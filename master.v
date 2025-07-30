module master(
    //MASTER INPUT
    input clk, 
    input reset,
    input wr_en,
    input rd_en,
    input [31:0] addr,
    input [31:0] wdata_in,

    //MASTER output
    output reg [31:0] rdata_out,
    output reg read_done, 
    output reg write_done,

    //AW
    output reg awvalid,
    output reg [31:0] awaddr,
    input awready,

    //W
    output reg wvalid,
    output reg [31:0] wdata,
    input wready,

    //B
    input bvalid,
    input [1:0] bresp,
    output reg bready,

    //AR
    output reg arvalid,
    output reg [31:0] araddr,
    input arready,

    //R
    output reg rready,
    input [31:0] rdata,
    input rvalid,
    input [1:0] rresp
);


    parameter W_IDLE  = 3'b000;
    parameter W_AW    = 3'b001;
    parameter W_W     = 3'b010;
    parameter W_B     = 3'b011;
    parameter W_DONE  = 3'b100;

    reg [2:0] w_state;

    parameter R_IDLE  = 2'b00;
    parameter R_AR    = 2'b01;
    parameter R_R     = 2'b10;
    parameter R_DONE  = 2'b11;

    reg [1:0] r_state;

    //INTERNAL LATCH
    reg [31:0] waddr_latch;
    reg [31:0] wdata_latch;
    reg [31:0] raddr_latch;

    always @(posedge clk) begin
        if(reset) begin
            awvalid     <= 0;
            wvalid      <= 0;
            bready      <= 0;
            write_done  <= 0;
            awaddr      <= 0;
            wdata       <= 0;
            w_state     <= W_IDLE;

            // Read channel reset
            arvalid     <= 0;
            rready      <= 0;
            read_done   <= 0;
            araddr      <= 0;
            r_state     <= R_IDLE;

            //LATCH
            waddr_latch <= 0;
            wdata_latch <= 0;
            raddr_latch <= 0;
        end else begin
            case(w_state)
                //case fsm write
                W_IDLE: begin
                    write_done <= 0;
                    if(wr_en) begin
                        waddr_latch <= addr;
                        wdata_latch <= wdata_in;
                        w_state <= W_AW;
                    end
                end
                W_AW: begin
                    awvalid <= 1;
                    awaddr <= waddr_latch;
                    if(awready) begin
                        awvalid <= 0;
                        w_state <= W_W;
                    end
                end
                W_W: begin
                    wvalid <= 1;
                    wdata <= wdata_latch;
                    if(wready) begin
                        wvalid <= 0;
                        bready <= 1;
                        w_state <= W_B;
                    end
                end
                W_B: begin
                    if(bvalid) begin
                        bready <= 0;
                        w_state <= W_DONE;
                    end
                end
                W_DONE: begin
                    write_done <= 1;
                    w_state <= W_IDLE;
                end
                default: w_state <= W_IDLE;
            endcase
            
            //----READ FSM----
            case(r_state)
                R_IDLE: begin
                    read_done <= 0;
                    if(rd_en) begin
                        raddr_latch <= addr;
                        r_state <= R_AR;
                    end
                end
                R_AR: begin
                    araddr <= raddr_latch;
                    arvalid <= 1;
                    if(arready) begin
                        arvalid <= 0;
                        rready <= 1;
                        r_state <= R_R;
                    end
                end
                R_R: begin
                    if(rvalid) begin
                        rdata_out <= rdata;
                        rready <= 0;
                        r_state <= R_DONE; 
                    end
                end
                R_DONE: begin
                    read_done <= 1;
                    r_state <= R_IDLE;
                end
                default: r_state <= R_IDLE;
            endcase
        end
    end
endmodule