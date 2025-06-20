`timescale 1ns/1ps

module MINHA_FPU_tb;

    logic clk;
    logic reset_n;
    logic [31:0] Op_A_in, Op_B_in;
    logic op_select; // 0 = soma, 1 = subtracao
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

    // Clock de 100 khz
    always #5000 clk = ~clk; 


    function string format_fp(input [31:0] fp);
        logic sign;
        logic [7:0] exp;
        logic [22:0] mant;
        real r_val;
        begin
            sign = fp[31];
            exp  = fp[30:23];
            mant = fp[22:0];

            if (exp == 8'hFF) begin
                if (mant == 0)
                    return (sign ? "-inf" : "+inf");
                else
                    return (sign ? "-nan" : "+nan");
            end else if (exp == 0 && mant == 0) begin
                return (sign ? "-0.0" : "+0.0");
            end else begin
                if (exp == 0) // Subnormal
                    r_val = (mant / (2.0**23)) * (2.0**(-126));
                else // Normal
                    r_val = (1.0 + mant / (2.0**23)) * (2.0**(exp - 127));
                
                if (sign) r_val = -r_val;
                return $sformatf("%f", r_val);
            end
        end
    endfunction

    task apply_op(input [31:0] A, input [31:0] B, input logic sel);
        begin
            @(posedge clk);
            Op_A_in = A;
            Op_B_in = B;
            op_select = sel;
            
            // ESPERA UM CICLO DE CLOCK PARA A SAIDA DA FPU SER ATUALIZADA
            @(posedge clk); 
            #1; 
            
            $display("A = %s, B = %s, Op = %s, Result = %s, Status = %b",
                     format_fp(Op_A_in),
                     format_fp(Op_B_in),
                     (op_select ? "-" : "+"),
                     format_fp(data_out),
                     status_out);
        end
    endtask

    function [31:0] make_fp(input logic sign, input [7:0] exp, input [22:0] mant);
        return {sign, exp, mant};
    endfunction

    initial begin
        $display("Inicio do Tb\n");

        clk = 0;
        reset_n = 0;
        #10;
        reset_n = 1;
        
        // Caso 1: Sum EXATA: 1.0 + 1.0
        apply_op(make_fp(0, 127, 0), make_fp(0, 127, 0), 0);

        // Caso 2: SubEXATA: 2.0 - 1.0
        apply_op(make_fp(0, 128, 0), make_fp(0, 127, 0), 1);
        
        // Caso 3: Op invalida: inf - inf
        apply_op(make_fp(0, 255, 0), make_fp(0, 255, 0), 1);

        // Caso 4: OVERFLOW
        apply_op(make_fp(0, 254, 'h7FFFFF), make_fp(0, 254, 'h7FFFFF), 0);

        // Caso 5: INEXACT
        apply_op(make_fp(0, 127, 1), make_fp(0, 127, 2), 0);

        // Caso 6: Sum de opostos (zero)
        apply_op(make_fp(0, 127, 0), make_fp(1, 127, 0), 0);
        
        // Caso 7: Sub que resulta em negativo
        apply_op(make_fp(0, 127, 0), make_fp(0, 128, 0), 1);

        // Caso 8: Soma com expoentes diferentes: 8.0 + 1.0
        apply_op(make_fp(0, 130, 0), make_fp(0, 127, 0), 0);

        // Caso 9: Infinito + Finito
        apply_op(make_fp(0, 255, 0), make_fp(0, 127, 0), 0);

        // Caso 10: Soma que resulta em negativo: -2.0 - 1.0
        apply_op(make_fp(1, 128, 0), make_fp(0, 127, 0), 1);

        $display("\nTestes com num quebrados");

        // Caso 11: Soma de frac com resultado exato: 1.5 + 2.5 = 4.0
        // 1.5 = 0x3FC00000, 2.5 = 0x40200000
        apply_op(32'h3FC00000, 32'h40200000, 0);

        // Caso 12: Soma de frac com resultado inexato: 1.54 + 1.23 = 2.77
        // 1.54 = 0x3FC51EB8, 1.23 = 0x3F9D70A4
        apply_op(32'h3FC51EB8, 32'h3F9D70A4, 0);

        $display("\nFim do Tb");
        $finish;
    end

endmodule
