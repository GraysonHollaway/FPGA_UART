module UART_TX#(parameter CLOCKS_PER_BIT = 217)(
    input i_Clk,
    input [7:0] i_TX_Byte,
    input i_TX_DV,
    output o_TX_Active,
    output o_TX_Serial,
    output o_TX_Done
);

parameter INITIAL = 3'b000;
parameter START_BIT = 3'b001;
parameter DATA_BITS = 3'b010;
parameter STOP_BIT = 3'b011;
parameter CLEANUP = 3'b100;

reg [2:0] r_State = INITIAL;
reg [7:0] r_Counter= 0;
reg [2:0] r_Bit_Index = 0;
reg [7:0] r_TX_Data = 0;
reg r_TX_Active = 0;
reg r_TX_Done = 0;
reg r_TX_Serial = 0;

always @(posedge i_Clk) begin
    case (r_State)
        INITIAL : begin
            r_TX_Serial <= 1'b1;
            r_TX_Done <= 1'b0;
            r_Counter <= 0;
            r_Bit_Index <= 0;

            if(i_TX_DV == 1'b1) begin
                r_State <= START_BIT;
                r_TX_Data <= i_TX_Byte;
                r_TX_Active <= 1'b1;
            end
            else begin
                r_State <= INITIAL;
            end
        end

        START_BIT : begin 
            if(r_Counter == CLOCKS_PER_BIT - 1) begin
                r_State <= DATA_BITS;
                r_Counter <= 0;
            end
            else begin
                r_Counter <= r_Counter + 1;
                r_TX_Serial <= 1'b0;
            end
        end

        DATA_BITS : begin 
            if(r_Bit_Index < 7) begin
                if(r_Counter == CLOCKS_PER_BIT - 1) begin
                    r_Counter <= 0;
                    r_Bit_Index <= r_Bit_Index + 1;
                end
                else begin
                    r_TX_Serial <= i_TX_Byte[r_Bit_Index];
                    r_Counter <= r_Counter + 1;
                end
            end
            else begin
                if(r_Counter == CLOCKS_PER_BIT - 1) begin
                    r_State <= STOP_BIT;
                    r_Counter <= 0;
                    r_Bit_Index <= 0;
                end
                else begin
                    r_TX_Serial <= i_TX_Byte[r_Bit_Index];
                    r_Counter <= r_Counter + 1;
                end
                
            end
        end

        STOP_BIT : begin
            if(r_Counter == CLOCKS_PER_BIT) begin
                r_State <= CLEANUP;
                r_Counter <= 0;
            end
            else begin
                r_Counter <= r_Counter + 1;
                r_TX_Serial <= 1'b1;
            end
        end

        CLEANUP : begin
            r_Counter <= 0;
            r_Bit_Index <= 0;
            r_State <= INITIAL;
            r_TX_Active <= 0;
            r_TX_Done <= 1'b1;
            r_TX_Data <= 0;
        end
    endcase
end

    assign o_TX_Serial = r_TX_Serial;
    assign o_TX_Done = r_TX_Done;
    assign o_TX_Active = r_TX_Active;

endmodule