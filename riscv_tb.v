`timescale 1ns / 1ps

module riscv_tb;
    reg clk;
    reg reset;

    // Instanciação do processador
    riscv_core uut (
        .clk(clk),
        .reset(reset)
    );

    // Monitor para parar no ebreak
    always @(posedge clk) begin
        if (uut.instruction == 32'h00100073) begin
            $display("EBREAK encontrado! Parando simulação.");
            $display("Resultados finais:");
            for (integer i = 0; i < 32; i = i + 1) begin
                $display("x%0d = %b", i, uut.reg_file.registers[i]);
            end
            $finish;
        end
    end

    // Geração de clock (período de 10ns)
    always #5 clk = ~clk;

    // Procedimento de teste
    initial begin
        // Inicializa entradas
        clk = 0;
        reset = 1;

        // Dump de waveform
        $dumpfile("riscv_sim.vcd");
        $dumpvars(0, riscv_tb);

        // Monitor em tempo real
        $monitor("Time: %t | PC: %b | Instr: %b | ALU: a=%b b=%b res=%b",
                $time, uut.PC, uut.instruction,
                uut.read_data_1, uut.alu_src_b, uut.alu_result);

        // Reseta o processador
        #10;
        reset = 0;

        // DEBUG INICIAL
        #20;
        $display("=== DEBUG INICIAL ===");
        $display("PC = %b", uut.PC);
        $display("Instruction = %b", uut.instruction);
        $display("opcode = %b", uut.opcode);
        $display("funct3 = %b", uut.funct3);
        $display("reg_write = %b", uut.reg_write);
        $display("=== VALORES DOS REGISTRADORES ===");
        $display("x1 = %b", uut.reg_file.registers[1]);
        $display("x2 = %b", uut.reg_file.registers[2]);
        $display("x3 = %b", uut.reg_file.registers[3]);

        // DEBUG DA ALU CONTROL
        $display("=== DEBUG DA ALU CONTROL ===");
        $display("alu_op = %b", uut.alu_op);
        $display("funct3 = %b", uut.funct3);
        $display("funct7 = %b", uut.funct7);
        $display("alu_control = %b", uut.alu_control);

        // DEBUG DA LEITURA DE REGISTRADORES
        $display("=== DEBUG DA LEITURA DE REGISTRADORES ===");
        $display("rs1 = %d, rs2 = %d", uut.rs1, uut.rs2);
        $display("read_reg1 = %d, read_reg2 = %d", uut.reg_file.read_reg1, uut.reg_file.read_reg2);
        $display("read_data1 = %b, read_data2 = %b", uut.read_data_1, uut.read_data_2);
        $display("write_reg = %d, write_data = %b", uut.rd, uut.write_back_data);

        // Espera para executar algumas instruções
        #60;  // Espera mais 6 ciclos (total 8 ciclos desde o reset)

        $display("=== APÓS EXECUÇÃO ===");
        $display("PC = %b", uut.PC);
        $display("Instruction = %b", uut.instruction);
        $display("x1 = %b, x2 = %b, x3 = %b", 
                uut.reg_file.registers[1], 
                uut.reg_file.registers[2],
                uut.reg_file.registers[3]);

        // Final da simulação
        #10;
        $display("=== FINAL ===");
        $display("Final register values:");
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("x%0d = %b", i, uut.reg_file.registers[i]);
        end

        // Espera para o EBREAK
        #200;

        // Se não encontrou ebreak, mostra mensagem
        $display("⚠️  EBREAK não foi encontrado. Parando simulação.");
        $display("Estado final:");
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("x%0d = %b", i, uut.reg_file.registers[i]);
        end

        $finish;
    end

endmodule