`timescale 1ns / 1ps

module control_unit (
    input wire [6:0] opcode, // Código da operação
    input wire [2:0] funct3, // Código da função
    input wire [6:0] funct7, // Código da função extendido
    output reg reg_write, // Habilita escrita no registrador
    output reg alu_src,   // Seleciona a fonte do segundo operando da ALU
    output reg mem_write, // Habilita escrita na memória
    output reg mem_to_reg, // Seleciona a fonte de dados para o registrador
    output reg branch,    // Habilita o branch
    output reg branch_neq, // Habilita o branch se não for igual
    output reg [1:0] alu_op // Seleciona a operação da ALU
);

// Parâmetros para os opcodes
localparam [6:0] OPCODE_R_TYPE = 7'b0110011; // Tipo R
localparam [6:0] OPCODE_ADD_I  = 7'b0010011; // ADDI
localparam [6:0] OPCODE_LOAD   = 7'b0000011; // LOAD
localparam [6:0] OPCODE_STORE  = 7'b0100011; // STORE
localparam [6:0] OPCODE_BRANCH = 7'b1100011; // BRANCH
localparam [6:0] OPCODE_EBREAK = 7'b1110011; // EBREAK

always @(*) begin
    // Valores padrão
    reg_write = 1'b0; // Habilita escrita no registrador
    alu_src   = 1'b0; // Seleciona a fonte do segundo operando da ALU
    mem_write = 1'b0; // Habilita escrita na memória
    mem_to_reg = 1'b0; // Seleciona a fonte de dados para o registrador
    branch    = 1'b0; // Habilita o branch
    branch_neq = 1'b0; // Habilita o branch se não for igual
    alu_op    = 2'b00; // Seleciona a operação da ALU

    case (opcode)
        OPCODE_R_TYPE: begin  // Tipo R
            reg_write = 1'b1; // Habilita escrita no registrador
            alu_src   = 1'b0; // Seleciona a fonte do segundo operando da ALU
            mem_write = 1'b0; // Habilita escrita na memória
            mem_to_reg = 1'b0; // Seleciona a fonte de dados para o registrador
            branch    = 1'b0; // Habilita o branch
            branch_neq = 1'b0; // Habilita o branch se não for igual
            alu_op    = 2'b10; // Seleciona a operação da ALU
        end

        OPCODE_ADD_I: begin // ADDI
            reg_write = 1'b1; // Habilita escrita no registrador
            alu_src   = 1'b1; // Seleciona a fonte do segundo operando da ALU
            mem_write = 1'b0; // Habilita escrita na memória
            mem_to_reg = 1'b0; // Seleciona a fonte de dados para o registrador
            branch    = 1'b0; // Habilita o branch
            branch_neq = 1'b0; // Habilita o branch se não for igual
            alu_op    = 2'b00; // Seleciona a operação da ALU
        end

        OPCODE_LOAD: begin // lw
            reg_write = 1'b1; // Habilita escrita no registrador
            alu_src   = 1'b1; // Seleciona a fonte do segundo operando da ALU
            mem_write = 1'b0; // Habilita escrita na memória
            mem_to_reg = 1'b1; // Seleciona a fonte de dados para o registrador
            branch    = 1'b0; // Habilita o branch
            branch_neq = 1'b0; // Habilita o branch se não for igual
            alu_op    = 2'b00; // Seleciona a operação da ALU
        end

        OPCODE_STORE: begin // sw
            reg_write = 1'b0; // Desabilita escrita no registrador
            alu_src   = 1'b1; // Seleciona a fonte do segundo operando da ALU
            mem_write = 1'b1; // Habilita escrita na memória
            mem_to_reg = 1'bx; // Não se aplica
            branch    = 1'b0; // Habilita o branch
            branch_neq = 1'b0; // Habilita o branch se não for igual
            alu_op    = 2'b00; // Seleciona a operação da ALU
        end

        OPCODE_BRANCH: begin // Tipo B
            reg_write = 1'b0; // Desabilita escrita no registrador
            alu_src   = 1'b0; // Seleciona a fonte do segundo operando da ALU
            mem_write = 1'b0; // Habilita escrita na memória
            mem_to_reg = 1'bx; // Não se aplica
            alu_op    = 2'b01; // Seleciona a operação da ALU

            case (funct3)   // Verifica o tipo de branch
                3'b000: begin  // BEQ
                    branch = 1'b1; // Habilita o branch
                    branch_neq = 1'b0; // Desabilita o branch se não for igual
                end
                3'b001: begin  // BNE
                    branch = 1'b0; // Desabilita o branch
                    branch_neq = 1'b1; // Habilita o branch se não for igual
                end
                default: begin  // Caso padrão
                    branch = 1'b0; // Desabilita o branch
                    branch_neq = 1'b0; // Desabilita o branch se não for igual
                end
            endcase
        end

        // CASE SEPARADO PARA EBREAK
        OPCODE_EBREAK: begin
            reg_write = 1'b0; // Desabilita escrita no registrador
            alu_src   = 1'b0; // Seleciona a fonte do segundo operando da ALU
            mem_write = 1'b0; // Habilita escrita na memória
            mem_to_reg = 1'b0; // Não se aplica
            branch    = 1'b0; // Habilita o branch
            branch_neq = 1'b0; // Habilita o branch se não for igual
            alu_op    = 2'b00; // Seleciona a operação da ALU
        end

        default: begin  // Caso padrão
            reg_write = 1'b0; // Desabilita escrita no registrador
            alu_src   = 1'b0; // Seleciona a fonte do segundo operando da ALU
            mem_write = 1'b0; // Habilita escrita na memória
            mem_to_reg = 1'b0; // Não se aplica
            branch    = 1'b0; // Habilita o branch
            branch_neq = 1'b0; // Habilita o branch se não for igual
            alu_op    = 2'b00; // Seleciona a operação da ALU
        end
    endcase
end

endmodule