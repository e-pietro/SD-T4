
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

![image](https://github.com/user-attachments/assets/a0e69c51-36c7-49a1-91b1-0294a23fe145)

