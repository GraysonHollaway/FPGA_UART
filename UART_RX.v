module UART_RX #(parameter CLOCKS_PER_BIT = 217) (
    input i_Clk,
    input i_RX_Serial,
    output o_RX_DV,
    output [7:0] o_RX_Byte
);

    // enum states
    parameter INITIAL  = 3'b000;
    parameter START_BIT = 3'b001;
    parameter SERIAL_DATA = 3'b010;
    parameter STOP_BIT = 3'b011;
    parameter CLEANUP = 3'b100;

    reg [2:0] r_State = 3'b000;
    reg [7:0] r_RX_Byte = 3'b000;
    reg r_RX_DV = 0;
    reg [2:0] r_Bit_Index = 0;
    reg [7:0] r_Clock_Count = 0;

    always @(posedge i_Clk) begin
        case (r_State) 
            INITIAL :
                begin
                    r_RX_DV <= 0;
                    r_Clock_Count <= 0;
                    r_Bit_Index <= 0;

                    if(i_RX_Serial == 1'b0) 
                        begin
                            r_State <= START_BIT;
                        end
                    else
                        begin
                            r_State <= INITIAL;
                        end
                end
            START_BIT :
                begin
                    if(r_Clock_Count == (CLOCKS_PER_BIT - 1) / 2)
                        begin
                            if(i_RX_Serial == 1'b0)
                                begin
                                    r_State <= SERIAL_DATA;
                                end
                            else
                                begin
                                    r_State <= INITIAL;
                                end
                            r_Clock_Count <= 0;    
                        end
                    else 
                        begin
                            r_Clock_Count <= r_Clock_Count + 1;
                        end
                    
                end
            SERIAL_DATA :
                begin
                    if(r_Clock_Count == CLOCKS_PER_BIT - 1)
                        begin
                            if(r_Bit_Index < 7)
                                begin
                                    r_RX_Byte[r_Bit_Index] <= i_RX_Serial;
                                    r_Bit_Index <= r_Bit_Index + 1;
                                    r_Clock_Count <= 0;
                                end
                            else
                                begin
                                    r_RX_Byte[r_Bit_Index] <= i_RX_Serial;
                                    r_State <= STOP_BIT;
                                    r_Bit_Index <= 0;
                                    r_Clock_Count <= 0;
                                end 
                        end
                    else
                        begin
                            r_Clock_Count <= r_Clock_Count + 1;
                        end
                end
            STOP_BIT :
                begin
                    if(r_Clock_Count == CLOCKS_PER_BIT - 1)
                        begin
                            r_State <= CLEANUP;
                            r_Clock_Count <= 0;
                        end
                    else
                        begin
                            r_Clock_Count <= r_Clock_Count + 1;
                        end
                end
            CLEANUP :
                begin
                    r_RX_DV <= 1'b1;
                    r_Clock_Count <= 0;
                    r_State <= INITIAL;
                    r_Bit_Index <= 0;
                end
            default : r_State <= INITIAL;
        endcase
    end 

    assign o_RX_Byte = r_RX_Byte;
    assign o_RX_DV = r_RX_DV;
    
endmodule