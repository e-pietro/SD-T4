
1. Introdução
Este projeto consiste no desenvolvimento de uma Unidade de Ponto Flutuante (FPU) simplificada em SystemVerilog. O objetivo é implementar as operações de soma e subtração para números de ponto flutuante de 32 bits, com uma estrutura de expoente e mantissa customizada, além de um sistema de flags de status para indicar condições especiais como Overflow, Underflow, Inexatidão e operações Inválidas.

A implementação final utiliza uma arquitetura de Máquina de Estados Finitos (FSM) de múltiplos ciclos, que divide o complexo processo de cálculo em etapas sequenciais e bem definidas, facilitando o entendimento e a depuração da lógica.

2. Definição da FPU (Cálculo de X e Y)
Sendo a matrícula 241064070
Somatório dos dígitos: 2 + 4 + 1 + 0 + 6 + 4 + 0 + 7 + 0 = 24 % 4 = 0

Sinal: X = 8 - 0

X = 8 bits expoente

Y = 31 – 8 = 23 bits (mantissa)

3. Arquitetura do Módulo
A FPU foi projetada como uma Máquina de Estados Finitos (FSM) com 5 estágiosonde cada um executa uma tarefa específica por ciclo de clock:

S_IDLE: Estado ocioso, aguardando para capturar as entradas (Op_A_in, Op_B_in).

S_DECODE_ALIGN: Decodifica as entradas e realiza o alinhamento das mantissas, deslocando a do menor expoente para que ambas fiquem na mesma escala.

S_ADD_SUB: Com as mantissas alinhadas, realiza a operação de soma ou subtração.

S_NORMALIZE: Pega o resultado bruto e o normaliza, ajustando-o ao formato padrão de ponto flutuante (1.xxxx... * 2^exp).

S_FINALIZE: Monta o dado de saída de 32 bits e calcula o status final da operação (Overflow, Exact, etc.).

4. Espectro Numérico

1. Introdução
Este projeto consiste no desenvolvimento de uma Unidade de Ponto Flutuante (FPU) simplificada em SystemVerilog. O objetivo é implementar as operações de soma e subtração para números de ponto flutuante de 32 bits, com uma estrutura de expoente e mantissa customizada, além de um sistema de flags de status para indicar condições especiais como Overflow, Underflow, Inexatidão e operações Inválidas.

A implementação final utiliza uma arquitetura de Máquina de Estados Finitos (FSM) de múltiplos ciclos, que divide o complexo processo de cálculo em etapas sequenciais e bem definidas, facilitando o entendimento e a depuração da lógica.

2. Definição da FPU (Cálculo de X e Y)
Sendo a matrícula 241064070
Somatório dos dígitos: 2 + 4 + 1 + 0 + 6 + 4 + 0 + 7 + 0 = 24 % 4 = 0

Sinal: X = 8 - 0

X = 8 bits expoente

Y = 31 – 8 = 23 bits (mantissa)

3. Arquitetura do Módulo
A FPU foi projetada como uma Máquina de Estados Finitos (FSM) com 5 estágiosonde cada um executa uma tarefa específica por ciclo de clock:

S_IDLE: Estado ocioso, aguardando para capturar as entradas (Op_A_in, Op_B_in).
S_DECODE_ALIGN: Decodifica as entradas e realiza o alinhamento das mantissas, deslocando a do menor expoente para que ambas fiquem na mesma escala.
S_ADD_SUB: Com as mantissas alinhadas, realiza a operação de soma ou subtração.
S_NORMALIZE: Pega o resultado bruto e o normaliza, ajustando-o ao formato padrão de ponto flutuante (1.xxxx... * 2^exp).
S_FINALIZE: Monta o dado de saída de 32 bits e calcula o status final da operação (Overflow, Exact, etc.).
Essa arquitetura, embora leve 5 ciclos para produzir um resultado, torna o código extremamente organizado e mais fácil de depurar em comparação com um design de ciclo único.

4. Espectro Numérico

Representação de Números em Ponto Flutuante (IEEE 754 - 32 bits)

| Tipo de Número      | Bit de Sinal (S) | Expoente (E) | Mantissa (M)         | Valor Aproximado da Magnitude                       |
|---------------------|------------------|--------------|----------------------|-----------------------------------------------------|
| Inválido            | 0 ou 1           | 255          | Diferente de zero    | N/A                                                 |
| Overflow            | 0 ou 1           | 255          | Igual a zero         | ∞                                                   |
| Normais             | 0 ou 1           | 1 a 254      | Qualquer valor       | ~1.175 × 10⁻³⁸ a ~3.4028 × 10³⁸                     |
| Underflow           | 0 ou 1           | 0            | Diferente de zero    | ~1.4 × 10⁻⁴⁵ a ~1.175 × 10⁻³⁸                       |
| Zeros               | 0 ou 1           | 0            | Igual a zero         | 0                                                   |


Expoente (real): -126 a +127 para números normais (armazenado como 00000001 até 11111110)

Maior valor positivo representável: (2− 2^−23) × 2^127 ≈ 3.402823×10^38
 
Menor valor positivo representável: 2^−23 × 2^−126 ≈ 1.4013×10^−45

5. Simulação
   
Instruções de Execução
Para simular o projeto, utilize o simulador  Questa. Carregue os arquivos do projeto (MINHA_FPU.sv e o testbench MINHA_FPU_tb.sv).

No console do simulador, execute o script de simulação sim.do com o seguinte comando:
do sim.do

