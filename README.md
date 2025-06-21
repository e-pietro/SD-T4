
1. Introdução
Este projeto consiste no desenvolvimento de uma Unidade de Ponto Flutuante (FPU) simplificada em SystemVerilog. O objetivo é implementar as operações de soma e subtração para números de ponto flutuante de 32 bits, com uma estrutura de expoente e mantissa customizada, além de um sistema de flags de status para indicar condições especiais como Overflow, Underflow, Inexatidão e operações Inválidas.

2. Definição da FPU (Cálculo de X e Y)
Sendo a matrícula 241064070
Somatório dos dígitos: 2 + 4 + 1 + 0 + 6 + 4 + 0 + 7 + 0 = 24 % 4 = 0

Sinal: X = 8 - 0

X = 8 bits expoente

Y = 31 – 8 = 23 bits (mantissa)

3. Arquitetura do Módulo

Visão Geral:

O módulo MINHA_FPU é uma FPU síncrona projetada para executar adição ou subtração em dois operandos de 32 bits em ponto flutuante. A unidade também lida com casos especiais como NaN (Not a Number) e Infinito, e fornece um código de status detalhado como saída, indicando o resultado da operação.

Extração de Campos: O sinal, expoente e mantissa são extraídos dos operandos de entrada. O bit implícito da mantissa é adicionado.

Tratamento de Casos Especiais: A lógica primeiramente verifica a presença de operandos NaN ou Infinito e trata esses casos com a devida prioridade. Por exemplo, a subtração de dois infinitos com o mesmo sinal (inf - inf) resulta em uma operação inválida (qNaN).

Alinhamento das Mantissas: O operando com o menor expoente tem sua mantissa deslocada para a direita até que os expoentes de ambos os operandos sejam iguais.

Soma/Subtração: As mantissas alinhadas são somadas ou subtraídas com base no sinal dos operandos e na operação selecionada (op_select).

Normalização: O resultado (mantissa e expoente) é normalizado para se adequar novamente ao formato IEEE 754. Isso pode envolver múltiplos deslocamentos para a esquerda (em caso de subtração com resultado pequeno) ou um único deslocamento para a direita (em caso de overflow na soma).

Geração da Saída e Status: O resultado final é montado e enviado para data_out. Simultaneamente um código de status é gerado em status_out para indicar a natureza do resultado.

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

