module axi4(
    input wire clk,
    input wire reset,

    //AW
    input wire awvalid,
    input wire[31:0] awaddr,
    output reg awready,
    
    //W
    input wire wvalid,
    input wire[31:0] wdata,
    output reg wready,

    //RESPOSE B
    output reg bvalid,
    output reg[1:0] bresp,
    input wire bready,

    //AR
    input wire arvalid,
    input wire[31:0] araddr,
    output reg arready,

    //R
    output reg[31:0] rdata,
    output reg rvalid,
    output reg[1:0] rresp,
    input wire rready
);

    reg[31:0] my_reg [0:31];

    //FLAGS - latch
    reg aw_handshake;
    reg w_handshake;
    reg ar_handshake;

    reg [4:0]aw_index;
    reg [4:0]ar_index;
    integer i;

    always @(posedge clk) begin
        if(reset) begin
            awready <= 0;
            wready <= 0;
            bvalid <= 0;
            bresp <= 0;
            aw_handshake <= 0;
            w_handshake <= 0;

            arready <= 0;
            ar_handshake <= 0;
            rvalid <= 0;
            rdata <= 32'd0;
            rresp <= 2'b00;
            for (i = 0; i < 32; i = i + 1)
                my_reg[i] <= 32'd0;

        end else begin
            //AW
            if(~awready && awvalid && !aw_handshake) begin
                awready <= 1;
            end else begin
                awready <= 0;
            end

            if(!aw_handshake && awvalid && awready) begin
                aw_handshake <= 1;
                aw_index <= awaddr[6:2];
            end

            //W
            if(~wready && wvalid && !w_handshake) begin
                wready <= 1;
            end else begin
                wready <= 0;
            end

            if(!w_handshake && wvalid && wready) begin
                $display("The write address: %b",aw_index);
                w_handshake <= 1;
            end
            if(aw_handshake && w_handshake) begin
                my_reg[aw_index] <= wdata;
            end

            //B - response
            if(!bvalid && aw_handshake && w_handshake) begin
                bvalid <= 1;
                bresp <= 2'b00; //OKAY respose
            end

            //B - CLEAR
            if(bvalid && bready) begin
                bvalid <= 0;
                aw_handshake <= 0;
                w_handshake <= 0;
            end

            //AR
            if(~arready && arvalid && !ar_handshake) begin
                arready <= 1;
            end else begin
                arready <= 0;
            end
            
            //R
            if(!ar_handshake && arvalid && arready) begin
                ar_handshake <= 1;
                ar_index <= araddr[6:2];     //address
            end

            if(ar_handshake && !rvalid) begin
                $display("The Read address: %b",ar_index);
                rdata <= my_reg[ar_index];
                rvalid <= 1;
                rresp <= 2'b00;
            end

            if(rvalid && rready) begin
                rvalid <= 0;
                ar_handshake <= 0;
            end
        end 
    end

endmodule