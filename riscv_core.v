`timescale 1ns / 1ps
// Instruções: lw, sw, add, xor, addi, sll, bne

module riscv_core (
    input wire clk,     // Clock
    input wire reset    // Reset
);

    // DECLARAÇÃO DE SINAIS INTERNOS
    // Estágio IF (Instruction Fetch)
    reg [31:0] PC;                      // Program Counter
    wire [31:0] PC_plus_4;              // PC + 4
    wire [31:0] PC_plus_imm;            // PC + immediate (para branch)
    wire [31:0] instruction;            // Instrução atual
    
    // Estágio ID (Instruction Decode)
    wire [6:0] opcode;                  // Bits [6:0] da instrução
    wire [4:0] rs1, rs2, rd;            // Campos dos registradores
    wire [2:0] funct3;                  // Bits [14:12]
    wire [6:0] funct7;                  // Bits [31:25]
    wire [31:0] imm_ext;                // Imediato estendido
    wire [31:0] read_data_1;            // Dado lido do registrador rs1
    wire [31:0] read_data_2;            // Dado lido do registrador rs2
    
    // Estágio EX (Execute)
    wire [31:0] alu_src_b;              // Segundo operando da ALU (MUX)
    wire [31:0] alu_result;             // Resultado da ALU
    wire alu_zero;                      // Flag zero da ALU
    wire [3:0] alu_control;             // Controle da ALU
    
    // Estágio MEM (Memory)
    wire [31:0] read_mem_data;          // Dado lido da memória
    
    // Estágio WB (Write Back)
    wire [31:0] write_back_data;        // Dado para writeback (MUX)
    
    // Sinais de Controle
    wire reg_write;            // Habilita escrita no registrador
    wire alu_src;              // ALU source
    wire mem_write;            // Habilita escrita na memória
    wire mem_to_reg;           // Habilita leitura da memória
    wire branch;               // Habilita branch
    wire branch_neq;          // Habilita branch não igual
    wire [1:0] alu_op;        // Operação da ALU
    wire PCSrc;               // Controle do MUX do PC

    // ATRIBUIÇÕES BÁSICAS
    assign opcode = instruction[6:0];          // Opcode da instrução
    assign rs1 = instruction[19:15];           // Registrador fonte 1
    assign rs2 = instruction[24:20];           // Registrador fonte 2
    assign rd = instruction[11:7];             // Registrador destino
    assign funct3 = instruction[14:12];       // Funct3
    assign funct7 = instruction[31:25];       // Funct7

    assign PC_plus_4 = PC + 4;                  // PC + 4
    assign PCSrc = (branch & alu_zero) | (branch_neq & ~alu_zero);   // Controle do MUX do PC

    // INSTANCIAÇÃO DOS MÓDULOS

    // Memória de Instruções (ROM)
    instruction_memory imem (
        .address(PC),                // Endereço da instrução
        .instruction(instruction)    // Saída da instrução
    );

    // Banco de Registradores
    register_file reg_file (
        .clk(clk),                    // Clock
        .reset(reset),                  // Reset
        .write_enable(reg_write),     // Habilita escrita
        .read_reg1(rs1),              // Registrador fonte 1
        .read_reg2(rs2),              // Registrador fonte 2
        .write_reg(rd),                // Registrador destino
        .write_data(write_back_data), // Dado a ser escrito
        .read_data1(read_data_1),     // Dado lido do registrador fonte 1
        .read_data2(read_data_2)      // Dado lido do registrador fonte 2
    );

    // Extensor de Imediato
    sign_extend sign_extend (
        .instruction(instruction),    // Instrução a ser estendida
        .imm_ext(imm_ext)             // Imediato estendido
    );

    // MUX para o operando B da ALU
    assign alu_src_b = alu_src ? imm_ext : read_data_2;    // Se alu_src for 1, usa imm_ext, senão usa read_data_2

    // Unidade de Controle Principal
    control_unit ctrl_unit (
        .opcode(opcode),           // Opcode da instrução
        .funct3(funct3),           // Funct3
        .funct7(funct7),           // Funct7
        .reg_write(reg_write),     // Habilita escrita
        .alu_src(alu_src),         // ALU source
        .mem_write(mem_write),     // Habilita escrita na memória
        .mem_to_reg(mem_to_reg),   // Habilita leitura da memória
        .branch(branch),           // Habilita branch
        .branch_neq(branch_neq),   // Habilita branch não igual
        .alu_op(alu_op)            // ALU operation
    );

    // Unidade de Controle da ALU
    alu_control_unit alu_ctrl (
        .alu_op(alu_op),         // ALU operation
        .funct3(funct3),         // Funct3
        .funct7(funct7),         // Funct7
        .alu_control(alu_control) // Controle da ALU
    );

    // ALU
    alu main_alu (
        .a(read_data_1),           // Operando A
        .b(alu_src_b),             // Operando B
        .alu_control(alu_control), // Controle da ALU
        .result(alu_result),       // Resultado da ALU
        .zero(alu_zero)           // Sinal de zero
    );

    // Cálculo do endereço de desvio
    assign PC_plus_imm = PC + imm_ext;     // PC + Imediato estendido

    // Memória de Dados
    data_memory dmem (
        .clk(clk),                    // Clock
        .mem_write(mem_write),       // Habilita escrita na memória
        .address(alu_result),        // Endereço da memória
        .write_data(read_data_2),   // Dado a ser escrito
        .read_data(read_mem_data)    // Dado lido da memória
    );

    // MUX para Write Back
    assign write_back_data = mem_to_reg ? read_mem_data : alu_result;   // Dados a serem escritos

    // LÓGICA DO PROGRAM COUNTER
    always @(posedge clk or posedge reset) begin
        if (reset) begin     // Reset do PC
            PC <= 32'b0;     // PC = 0
        end else begin       // Se não estiver em reset
            if (PCSrc) begin // Se o PCSrc for ativado
                PC <= PC_plus_imm;  // Desvio taken
            end else begin   // Se o PCSrc não for ativado
                PC <= PC_plus_4;    // Próxima instrução
            end
        end
    end

endmodule