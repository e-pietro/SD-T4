module MINHA_FPU_FSM (
    input logic clk,
    input logic reset_n,
    input logic [31:0] Op_A_in,
    input logic [31:0] Op_B_in,
    input logic op_select,
    output logic [31:0] data_out,
    output logic [3:0] status_out
);

    typedef enum logic [2:0] {
        S_IDLE,         // Esperando para começar
        S_DECODE_ALIGN, // Decodifica entradas e alinha mantissas
        S_ADD_SUB,      // Realiza a soma/subtracao
        S_NORMALIZE,    // Normaliza o resultado
        S_FINALIZE      // Calcula status e finaliza
    } state_t;

    state_t current_state, next_state;

    // REGISTRADORES
    logic       op_select_reg;
    logic [31:0] data_out_reg;
    logic [3:0] status_out_reg;

    // Registradores DECODE_ALIGN
    logic       sign_a_reg, sign_b_reg;
    logic [7:0] exp_a_reg, exp_b_reg;
    logic [23:0] mant_a_reg, mant_b_reg;

    // Registradores ADD_SUB
    logic [7:0] result_exp_reg;
    logic [28:0] aligned_a_reg, aligned_b_reg;

    // Registradores NORMALIZE
    logic       result_sign_reg;
    logic [29:0] result_mant_reg;

    always_comb begin
        next_state = current_state; 
        case (current_state)
            S_IDLE:         next_state = S_DECODE_ALIGN;
            S_DECODE_ALIGN: next_state = S_ADD_SUB;
            S_ADD_SUB:      next_state = S_NORMALIZE;
            S_NORMALIZE:    next_state = S_FINALIZE;
            S_FINALIZE:     next_state = S_IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= S_IDLE;
            data_out_reg <= 0;
            status_out_reg <= 0;
        end else begin

            current_state <= next_state;

            case (current_state)
                
                S_IDLE: begin
                    op_select_reg <= op_select;
                    sign_a_reg <= Op_A_in[31];
                    exp_a_reg  <= Op_A_in[30:23];
                    mant_a_reg <= {1'b1, Op_A_in[22:0]};
                    
                    sign_b_reg <= Op_B_in[31];
                    exp_b_reg  <= Op_B_in[30:23];
                    mant_b_reg <= {1'b1, Op_B_in[22:0]};
                end

                S_DECODE_ALIGN: begin
                    logic [7:0] exp_diff;
                    if (exp_a_reg > exp_b_reg) begin
                        exp_diff = exp_a_reg - exp_b_reg;
                        aligned_a_reg <= {mant_a_reg, 5'b0};
                        aligned_b_reg <= ({mant_b_reg, 5'b0} >> exp_diff);
                        result_exp_reg <= exp_a_reg;
                    end else begin
                        exp_diff = exp_b_reg - exp_a_reg;
                        aligned_a_reg <= ({mant_a_reg, 5'b0} >> exp_diff);
                        aligned_b_reg <= {mant_b_reg, 5'b0};
                        result_exp_reg <= exp_b_reg;
                    end
                end

                S_ADD_SUB: begin
                    if (sign_a_reg == sign_b_reg) begin
                        if (op_select_reg == 1) begin // Subtracao de sinais iguais
                            if (aligned_a_reg >= aligned_b_reg) begin
                                result_mant_reg <= aligned_a_reg - aligned_b_reg;
                                result_sign_reg <= sign_a_reg;
                            end else begin
                                result_mant_reg <= aligned_b_reg - aligned_a_reg;
                                result_sign_reg <= ~sign_a_reg;
                            end
                        end 
                        
                        else begin // Soma de sinais iguais
                            result_mant_reg <= aligned_a_reg + aligned_b_reg;
                            result_sign_reg <= sign_a_reg;
                        end
                    end 
                    
                    else begin
                        if (op_select_reg == 1) begin // Subtracao de sinais diferentes
                           result_mant_reg <= aligned_a_reg + aligned_b_reg;
                           result_sign_reg <= sign_a_reg;
                        end 
                        
                        else begin // Soma de sinais diferentes
                           if(aligned_a_reg >= aligned_b_reg) begin
                               result_mant_reg <= aligned_a_reg - aligned_b_reg;
                               result_sign_reg <= sign_a_reg;
                           end 
                           
                           else begin
                               result_mant_reg <= aligned_b_reg - aligned_a_reg;
                               result_sign_reg <= sign_b_reg;
                           end
                        end
                    end
                end

                S_NORMALIZE: begin
                    logic [29:0] temp_mant; //Declaracao
                    logic [7:0]  temp_exp;

                    temp_mant = result_mant_reg; // Atribuicao
                    temp_exp  = result_exp_reg;
 

                    if (temp_mant[29]) begin
                        temp_mant = temp_mant >> 1;
                        temp_exp = temp_exp + 1;
                    end else begin
                        while (temp_mant[28] == 0 && |temp_mant) begin
                           temp_mant = temp_mant << 1;
                           temp_exp = temp_exp - 1;
                        end
                    end
                    result_mant_reg <= temp_mant;
                    result_exp_reg  <= temp_exp;
                end

                S_FINALIZE: begin
                    logic [22:0] final_mant;
                    
                    final_mant = result_mant_reg[27:5];
                    
                    data_out_reg <= {result_sign_reg, result_exp_reg, final_mant};
                    
                    if (result_exp_reg >= 255) begin
                        status_out_reg <= 4'b0010; // OVERFLOW
                    end else begin
                        status_out_reg <= 4'b0001; // EXACT 
                    end
                end

            endcase
        end
    end
    
    assign data_out = data_out_reg;
    assign status_out = status_out_reg;

endmodule
