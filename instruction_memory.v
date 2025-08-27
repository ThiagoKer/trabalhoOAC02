module instruction_memory (
    input wire [31:0] address,     // Endereço da instrução
    output reg [31:0] instruction  // Instrução lida
);
    reg [31:0] mem [0:255]; // 256 palavras de 32 bits

    initial begin
        // Inicializa com instruções em BINÁRIO (convertidas do assembly)
        mem[0] = 32'b00000000000100000000000010110011;  // add x2, x0, x1
        mem[1] = 32'b00000000001000010000000100010011;  // sll x1, x2, x2
        mem[2] = 32'b00000000001100100000001000110011;  // xor x4, x2, x3
        mem[3] = 32'b11111111110000010000000110010011;  // addi x3, x2, -4
        mem[4] = 32'b00000000000000001010001010000011;  // lw x5, 0(x1)
        mem[5] = 32'b00000000010100010001001010100011;  // sw x5, 4(x2)
        mem[6] = 32'b00000000001000001000100001100011;  // bne x1, x2, 8
        mem[7] = 32'b00000000000000000000000000010011;  // nop (addi x0, x0, 0)
        mem[8] = 32'b00000000000000000000000000010011;  // nop (addi x0, x0, 0)
        mem[9] = 32'b00000000000000000000000000010011;  // nop (addi x0, x0, 0)
        mem[10] = 32'b00000000000100000000000001110011; // ebreak
        // Preencha o resto com zeros ou nops
        for (integer i = 11; i < 256; i = i + 1) begin
            mem[i] = 32'b00000000000000000000000000010011; // nop
        end
    end

    always @(*) begin
        instruction = mem[address[31:2]]; // Endereçamento word-aligned
    end

endmodule