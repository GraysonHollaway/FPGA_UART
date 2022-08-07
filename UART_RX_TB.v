`timescale 1ns/1ns
`include "UART_RX.v"

module UART_RX_TB();

    parameter c_CLOCK_PERIOD_NS = 40;
    parameter c_CLKS_PER_BIT = 217;
    parameter c_BIT_PERIOD = 8680;

    reg r_Clock = 0;
    reg r_RX_Serial = 1;
    wire [7:0] w_RX_Byte;
    wire w_RX_DV;

    task UART_WRITE_BYTE;
        input [7:0] i_Data;
        integer i;
        begin
            r_RX_Serial <= 1'b0;
            #(c_BIT_PERIOD);
            #1000;

            for(i = 0; i < 8; i = i + 1) begin
                r_RX_Serial <= i_Data[i];
                #(c_BIT_PERIOD);
            end

            r_RX_Serial <= 1;
            #(c_BIT_PERIOD);
        end
    endtask

    UART_RX #(.CLOCKS_PER_BIT(c_CLKS_PER_BIT)) UART_INST (
        .i_Clk(r_Clock),
        .i_RX_Serial(r_RX_Serial), 
        .o_RX_DV(w_RX_DV),
        .o_RX_Byte(w_RX_Byte)
    );

    always #(c_CLOCK_PERIOD_NS / 2) r_Clock <= !r_Clock;

    initial begin
        @(posedge r_Clock);
        UART_WRITE_BYTE(8'h3A);
        @(posedge r_Clock);
        #100000

        if(w_RX_Byte == 8'h3A) begin
            $display("Test passed");
        end
        else begin
            $display("Test failed");
        end

        $finish();
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule