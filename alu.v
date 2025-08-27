`timescale 1ns / 1ps

module alu (
    input wire [31:0] a,           // Operando A (vindo do ALU)
    input wire [31:0] b,           // Operando B (vindo do MUX: registrador ou immediate)
    input wire [3:0]  alu_control, // Sinal de controle que define a operação (vem do Controle da ALU)
    output reg [31:0] result,      // Resultado da operação
    output wire       zero         // Flag Zero (1 se result == 0)
);

    // Sempre recalcule o resultado quando qualquer operando ou sinal de controle mudar
    always @(*) begin
        case (alu_control)
            4'b0000: result = a + b;           // ADD
            4'b0001: result = a - b;           // SUB
            4'b0010: result = a & b;           // AND
            4'b0011: result = a | b;           // OR
            4'b0100: result = a ^ b;           // XOR
            4'b0101: result = a << b[4:0];     // SLL. b[4:0] é o shamt (shift amount).
            default: result = 32'b0;           // Operação padrão (resultado zero) para evitar latch
        endcase
    end

    // A flag ZERO é ativada só se o resultado for zero.
    // É uma atribuição contínua (wire), funciona como um circuito combinacional simples.
    assign zero = (result == 32'b0);

endmodule