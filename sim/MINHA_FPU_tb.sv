`timescale 1ns/1ps

module MINHA_FPU_tb;

    logic clk;
    logic reset_n;
    logic [31:0] Op_A_in, Op_B_in;
    logic op_select;
    logic [31:0] data_out;
    logic [3:0] status_out;

    // Instanciando o DUT (Device Under Test)
    MINHA_FPU dut (
        .clk(clk),
        .reset_n(reset_n),
        .Op_A_in(Op_A_in),
        .Op_B_in(Op_B_in),
        .op_select(op_select),
        .data_out(data_out),
        .status_out(status_out)
    );

    // Clock de 10ns (100MHz)
    always #5 clk = ~clk;

    // Tarefa para imprimir resultado
    task show_result(string op_str);
        $display("Time: %0t | A: %h | B: %h | OP: %s | Result: %h | Status: %b",
                 $time, Op_A_in, Op_B_in, op_str, data_out, status_out);
    endtask

    initial begin
        // Inicialização
        clk = 0;
        reset_n = 0;
        Op_A_in = 32'h00000000;
        Op_B_in = 32'h00000000;
        op_select = 0;

        // Reset
        #12;
        reset_n = 1;

        // Teste 1: Soma 1.5 + 2.5 (float: 0x3FC00000 + 0x40200000)
        #10;
        Op_A_in = 32'h3FC00000; // 1.5
        Op_B_in = 32'h40200000; // 2.5
        op_select = 0; // Soma
        #100;
        show_result("SOMA");

        // Teste 2: Subtração 5.5 - 2.0 (float: 0x40B00000 - 0x40000000)
        #10;
        Op_A_in = 32'h40B00000; // 5.5
        Op_B_in = 32'h40000000; // 2.0
        op_select = 1; // Subtração
        #100;
        show_result("SUB");

        // Teste 3: Subtração de números iguais 3.0 - 3.0
        #10;
        Op_A_in = 32'h40400000; // 3.0
        Op_B_in = 32'h40400000; // 3.0
        op_select = 1; // Subtração
        #100;
        show_result("ZERO");

        // Fim da simulação
        #50;
        $finish;
    end

endmodule
