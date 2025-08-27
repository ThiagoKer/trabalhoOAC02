module alu_control_unit (
    input wire [1:0] alu_op,     // Parâmetro de controle da ALU
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [3:0] alu_control // Para a ALU
);

always @(*) begin
    case (alu_op)
        2'b00: alu_control = 4'b0000; // add (para lw, sw, addi)
        2'b01: alu_control = 4'b0001; // sub (para branch)
        2'b10: begin // Instruções do tipo R
            case (funct3)
                3'b000: alu_control = (funct7 == 7'b0000000) ? 4'b0000 : 4'b0001; // add ou sub
                3'b100: alu_control = 4'b0100; // xor
                3'b001: alu_control = 4'b0101; // sll
                default: alu_control = 4'b0000; // add como padrão
            endcase
        end
        default: alu_control = 4'b0000; // add
    endcase
end

endmodule