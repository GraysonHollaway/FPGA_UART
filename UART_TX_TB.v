`timescale 1ps/1ps
`include "UART_TX.v"
`include "UART_RX.v"

module UART_TX_TB();

    parameter c_CLOCK_PERIOD_NS = 40;
    parameter c_CLOCKS_PER_BIT = 217;
    parameter c_BIT_PERIOD = 8680;

    reg r_Clock = 0;
    reg r_TX_DV = 0;
    reg [7:0] r_TX_Byte = 0;
    wire w_TX_Serial;
    wire w_TX_Active;
    wire w_UART_Line;
    wire [7:0] w_RX_Byte;
    wire w_RX_DV;

    UART_RX #(c_CLOCKS_PER_BIT) RX_Inst (
        .i_Clk(r_Clock),
        .i_RX_Serial(w_UART_Line),
        .o_RX_DV(w_RX_DV),
        .o_RX_Byte(w_RX_Byte)
    );

    UART_TX #(c_CLOCKS_PER_BIT) TX_Inst (
        .i_Clk(r_Clock),
        .i_TX_Byte(r_TX_Byte),
        .i_TX_DV(r_TX_DV),
        .o_TX_Active(w_TX_Active),
        .o_TX_Serial(w_TX_Serial),
        .o_TX_Done()
    );

    assign w_UART_Line = w_TX_Active ? w_TX_Serial : 1'b1;

    always begin
        #(c_CLOCK_PERIOD_NS / 2) r_Clock <= !r_Clock;
    end

    initial begin
        @(posedge r_Clock);
        @(posedge r_Clock);
        r_TX_DV <= 1'b1;
        r_TX_Byte <= 8'h37;
        @(posedge r_Clock);
        r_TX_DV <= 1'b0;

        @(posedge r_Clock);
        #10000000
        @(posedge r_Clock);
        if(w_RX_Byte == 8'h37) begin
            $display("Test passed...");
        end
        else begin
            $display("Test failed...");
        end
        $finish();

    end

    initial begin
        $dumpfile("TX_TB.vcd");
        $dumpvars(0);
    end



endmodule