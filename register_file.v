module register_file (
    input wire clk,                // Clock
    input wire reset,              // Reset
    input wire write_enable,       // Habilita escrita
    input wire [4:0] read_reg1,    // Registrador a ser lido 1
    input wire [4:0] read_reg2,    // Registrador a ser lido 2
    input wire [4:0] write_reg,    // Registrador a ser escrito
    input wire [31:0] write_data,  // Dado a ser escrito
    output wire [31:0] read_data1, // Dado lido do registrador 1
    output wire [31:0] read_data2  // Dado lido do registrador 2
);
    reg [31:0] registers [0:31];    // Banco de registradores

    // Leitura assíncrona
    assign read_data1 = (read_reg1 != 0) ? registers[read_reg1] : 0;     // Registrador 1
    assign read_data2 = (read_reg2 != 0) ? registers[read_reg2] : 0;     // Registrador 2

    // Escrita síncrona
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Inicializa todos os registradores (exceto x0) para zero
        for (integer i = 1; i < 32; i = i + 1) begin  // Inicializa registradores
            registers[i] <= 32'b0;
        end
    end else if (write_enable && write_reg != 0) begin  // Se habilitado e registrador não for 0
        registers[write_reg] <= write_data;  // Se habilitado e registrador não for 0
    end
end

endmodule