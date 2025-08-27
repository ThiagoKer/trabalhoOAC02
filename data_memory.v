module data_memory (
    input wire clk,               // Clock
    input wire mem_write,        // Habilita escrita
    input wire [31:0] address,   // Endereço de memória
    input wire [31:0] write_data, // Dado a ser escrito
    output reg [31:0] read_data   // Dado lido
);
    reg [31:0] mem [0:255]; // 256 palavras de 32 bits

    initial begin
        // Inicializa a memória com valores em BINÁRIO
        mem[0] = 32'b00000000000000000000000000000101; // 5
        mem[1] = 32'b00000000000000000000000000001010; // 10
        mem[2] = 32'b00000000000000000000000000001111; // 15
        // Preenche o resto com zeros
        for (integer i = 3; i < 256; i = i + 1) begin
            mem[i] = 32'b00000000000000000000000000000000;
        end
    end

    always @(*) begin
        read_data = mem[address[31:2]];     // Lê o dado da memória
    end

    always @(posedge clk) begin
        if (mem_write) begin
            mem[address[31:2]] <= write_data;    // Escreve o dado na memória
        end
    end

endmodule