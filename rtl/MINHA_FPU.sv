//sem fsm
module MINHA_FPU (
    input logic clk,
    input logic reset_n,
    input logic [31:0] Op_A_in,
    input logic [31:0] Op_B_in,
    input logic op_select, // 0 = soma / 1 = subtracao
    output logic [31:0] data_out,
    output logic [3:0] status_out
);

    // X=8 e Y=23
    localparam int EXP_BITS = 8;
    localparam int MANT_BITS = 23;
    localparam int BIAS = (1 << (EXP_BITS - 1)) - 1;

    // operandos
    logic sign_a, sign_b;
    logic [EXP_BITS-1:0] exp_a, exp_b;
    logic [MANT_BITS:0] mant_a, mant_b; // bit implicito

    assign sign_a = Op_A_in[31];
    assign exp_a = Op_A_in[30 -: EXP_BITS];
    assign mant_a = (|exp_a) ? {1'b1, Op_A_in[22:0]} : {1'b0, Op_A_in[22:0]};

    assign sign_b = Op_B_in[31];
    assign exp_b = Op_B_in[30 -: EXP_BITS];
    assign mant_b = (|exp_b) ? {1'b1, Op_B_in[22:0]} : {1'b0, Op_B_in[22:0]};

    // Variaveis internas
    logic [EXP_BITS-1:0] exp_diff;
    logic [MANT_BITS+4:0] aligned_a, aligned_b; 
    logic [MANT_BITS+5:0] result_mant;          
    logic [EXP_BITS-1:0] result_exp;
    logic result_sign;
    logic [22:0] final_mant;
    logic [EXP_BITS-1:0] final_exp;
    logic [3:0] status;

    logic is_a_nan, is_a_inf;
    logic is_b_nan, is_b_inf;
    
    assign is_a_nan = (exp_a == '1) && (|mant_a[MANT_BITS-1:0]);
    assign is_a_inf = (exp_a == '1) && ~((|mant_a[MANT_BITS-1:0]));

    assign is_b_nan = (exp_b == '1) && (|mant_b[MANT_BITS-1:0]);
    assign is_b_inf = (exp_b == '1) && ~((|mant_b[MANT_BITS-1:0]));

    localparam [3:0] S_EXACT   = 4'b0001;
    localparam [3:0] S_OVERFL  = 4'b0010;
    localparam [3:0] S_UNDERFL = 4'b0100;
    localparam [3:0] S_INEXACT = 4'b1000;
    localparam [3:0] S_INVALID = 4'b1001;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= 0;
            status_out <= 4'b0000;
        end else begin
            //NaN ou inf
            if (is_a_nan || is_b_nan || (is_a_inf && is_b_inf && ((op_select == 0 && sign_a != sign_b) || (op_select == 1 && sign_a == sign_b)))) begin
                // Se qualquer operando = NaN ou = inf-inf
                data_out <= {1'b0, {EXP_BITS{1'b1}}, {1'b1, {(MANT_BITS-1){1'b0}}}}; // qNaN
                status_out <= S_INVALID; 
            end
            else if (is_a_inf || is_b_inf) begin
                 // inf + finito são exatos.
                 data_out <= is_a_inf ? Op_A_in : Op_B_in;
                 status_out <= S_EXACT;
            end
            else begin

                // Alinhamento
                if (exp_a > exp_b) begin
                    exp_diff = exp_a - exp_b;
                    aligned_a = {mant_a, 4'b0};
                    aligned_b = ({mant_b, 4'b0} >> exp_diff);
                    result_exp = exp_a;
                end else begin
                    exp_diff = exp_b - exp_a;
                    aligned_a = ({mant_a, 4'b0} >> exp_diff);
                    aligned_b = {mant_b, 4'b0};
                    result_exp = exp_b;
                end

                // Operacao
                if (op_select == 0) begin // Soma
                    if (sign_a == sign_b) begin
                        result_mant = aligned_a + aligned_b;
                        result_sign = sign_a;
                    end else begin // Sinais diferentes
                        if (aligned_a >= aligned_b) begin
                            result_mant = aligned_a - aligned_b;
                            result_sign = sign_a;
                        end else begin
                            result_mant = aligned_b - aligned_a;
                            result_sign = sign_b;
                        end
                    end
                end else begin // Sub
                    if (sign_a != sign_b) begin // Sinais diferentes 
                        result_mant = aligned_a + aligned_b;
                        result_sign = sign_a;
                    end else begin
                        if (aligned_a >= aligned_b) begin
                            result_mant = aligned_a - aligned_b;
                            result_sign = sign_a;
                        end else begin
                            result_mant = aligned_b - aligned_a;
                            result_sign = ~sign_a;
                        end
                    end
                end

                // Normaliza
                if (result_mant[MANT_BITS+5]) begin
                    result_mant = result_mant >> 1;
                    result_exp = result_exp + 1;
                end else begin
                    while (result_mant[MANT_BITS+4] == 0 && result_exp > 0 && result_mant != 0) begin
                        result_mant = result_mant << 1;
                        result_exp = result_exp - 1;
                    end
                end

                if (result_mant == 0) begin
                    result_exp = 0;
                end
                
                // Montagem da saida numerica
                final_exp = result_exp;
                if (result_exp >= '1) begin 
                    final_exp = '1;
                    final_mant = 0;
                end else begin
                    final_mant = result_mant[MANT_BITS+3 -: MANT_BITS];
                end
                data_out <= {result_sign, final_exp, final_mant};

                // OVERFLOW
                if (result_exp >= '1) begin 
                    status = S_OVERFL;
                // UNDERFLOW
                end else if (result_exp == 0 && result_mant != 0) begin
                    status = S_UNDERFL;
                // INEXACT
                end else if (|result_mant[3:0]) begin // Checa se algum bit de guarda foi usado
                    status = S_INEXACT;
                // EXACT
                end else begin
                    status = S_EXACT;
                end
                status_out <= status;
                
            end
        end
    end

endmodule
