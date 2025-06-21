`timescale 1ns/1ps

module MINHA_FPU_tb;

    logic clk;
    logic reset_n;
    logic [31:0] Op_A_in, Op_B_in;
    logic op_select;
    logic [31:0] data_out;
    logic [3:0] status_out;

    MINHA_FPU dut (
        .clk(clk),
        .reset_n(reset_n),
        .Op_A_in(Op_A_in),
        .Op_B_in(Op_B_in),
        .op_select(op_select),
        .data_out(data_out),
        .status_out(status_out)
    );

    always #5000 clk = ~clk;

    // Casos de teste
    typedef struct {
        logic [31:0] A;
        logic [31:0] B;
        logic op; // 0 = soma, 1 = sub
        string desc;
    } test_case_t;

    test_case_t tests[10] = '{
        '{32'h3f800000, 32'h3f800000, 0, "1.0 + 1.0"},     // 2.0
        '{32'h40000000, 32'h3f800000, 0, "2.0 + 1.0"},     // 3.0
        '{32'h40400000, 32'h3f800000, 1, "3.0 - 1.0"},     // 2.0
        '{32'h3f800000, 32'h40400000, 1, "1.0 - 3.0"},     // -2.0
        '{32'h7f800000, 32'h3f800000, 0, "inf + 1.0"},     // inf
        '{32'h7f800000, 32'h7f800000, 1, "inf - inf"},     // NaN
        '{32'h7fc00001, 32'h3f800000, 0, "NaN + 1.0"},     // NaN
        '{32'h00000001, 32'h00000001, 0, "subnormal + subnormal"}, // pequenininho
        '{32'h3f800000, 32'hbf800000, 0, "1.0 + (-1.0)"},  // 0.0
        '{32'h3f800000, 32'h3f800000, 1, "1.0 - 1.0"}      // 0.0
    };

    initial begin
        $display("Iniciando Testes da MINHA_FPU @ 100kHz...\n");
        clk = 0;
        reset_n = 0;
        Op_A_in = 0;
        Op_B_in = 0;
        op_select = 0;

        // Reset por uma borda
        #100;
        reset_n = 1;

        foreach (tests[i]) begin
            @(negedge clk);
            Op_A_in = tests[i].A;
            Op_B_in = tests[i].B;
            op_select = tests[i].op;

            @(posedge clk); // aguarda borda onde processamento ocorre
            @(posedge clk); // garantir que data_out seja atualizado

            $display("[%0t ns] Teste %0d | %s", $time, i, tests[i].desc);
            $display("  A        = %h", tests[i].A);
            $display("  B        = %h", tests[i].B);
            $display("  Operacao = %s", (tests[i].op ? "SUB" : "ADD"));
            $display("  OUT      = %h", data_out);
            $display("  STATUS   = %b\n", status_out);

            Op_A_in = 0;
            Op_B_in = 0;
            op_select = 0;

            repeat(2) @(posedge clk);
        end

        $display("Fim dos testes!");
        $stop;
    end

endmodule
