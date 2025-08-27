module sign_extend (
    input wire [31:0] instruction,  // Instrução a ser estendida
    output reg [31:0] imm_ext      // Imediato estendido
);
    always @(*) begin
        case (instruction[6:0])     // Tipo da instrução
            // Tipo I (addi, lw)
            7'b0010011, 7'b0000011:
                imm_ext = {{20{instruction[31]}}, instruction[31:20]};   // Extensão de sinal para Tipo I
            // Tipo S (sw)
            7'b0100011:
                imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};   // Extensão de sinal para Tipo S
            // Tipo SB (bne)
            7'b1100011:
                imm_ext = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};  // Extensão de sinal para Tipo SB
            default:
                imm_ext = 32'b0;         // Caso padrão
        endcase
    end

endmodule