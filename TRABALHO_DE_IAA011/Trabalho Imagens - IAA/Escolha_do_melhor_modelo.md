# TRABALHO DE IAA011 – Visão Computacional
## Escolha do melhor modelo em cada exercício e justificativa

### Métrica utilizada na comparação

Em ambos os exercícios a métrica principal de decisão é o **F1-Score macro** (média aritmética do F1 das
quatro classes). A escolha se justifica porque:

- o problema tem **4 classes** com quantidades parecidas de imagens, e a média macro dá o **mesmo peso**
  para todas elas, evitando que o bom desempenho nas classes fáceis (0 e 3+) esconda o mau desempenho
  nas classes intermediárias (1+ e 2+);
- o F1 combina em um único número a **sensibilidade** (quantos positivos reais foram encontrados) e a
  precisão, ou seja, penaliza simultaneamente falsos negativos e falsos positivos;
- a **especificidade macro** é pouco discriminante neste problema: em um cenário de 4 classes, os
  verdadeiros negativos de cada classe incluem as outras três classes, o que mantém a especificidade
  sempre alta (acima de 0,85 em todos os modelos testados) e com pouca variação entre eles.

A sensibilidade e a especificidade por classe foram calculadas e são reportadas nos CSVs, mas o
ordenamento final dos modelos usa o F1 macro.

---

## Exercício 1 – Extração de Características

Resultados na base de **Teste** (6 combinações: 2 extratores x 3 classificadores):

| Extrator | Modelo | Sensibilidade macro | Especificidade macro | F1 macro |
|---|---|---|---|---|
| VGG16 | **RNA (MLP)** | 0,8197 | 0,9410 | **0,8180** |
| VGG16 | Random Forest | 0,7984 | 0,9345 | 0,7897 |
| VGG16 | SVM | 0,7882 | 0,9312 | 0,7771 |
| LBP | SVM | 0,6018 | 0,8663 | 0,6083 |
| LBP | Random Forest | 0,5855 | 0,8608 | 0,5887 |
| LBP | RNA (MLP) | 0,5679 | 0,8554 | 0,5772 |

### Melhor modelo: **VGG16 (penúltima camada, 4096 características) + RNA (MLP)** — F1 macro = 0,8180

**Justificativa:**

1. **O extrator domina o resultado.** Todas as três combinações com VGG16 (0,777 a 0,818) superam com
   folga as três combinações com LBP (0,577 a 0,608). O LBP descreve apenas textura em escala de cinza
   com um histograma de 10 posições, enquanto a imuno-histoquímica HER2 depende fortemente da
   **intensidade e distribuição da coloração marrom da membrana** — informação de cor que o LBP descarta.
   As 4096 características da camada `fc2` da VGG16 pré-treinada capturam padrões de cor, textura e
   estrutura muito mais ricos.
2. **Entre os classificadores, a RNA aproveita melhor o vetor da VGG16.** Com 4096 dimensões, a camada
   oculta do MLP consegue recombinar as características de forma não linear, obtendo o melhor F1 na
   classe mais difícil (1+: F1 = 0,643, contra 0,540 do Random Forest e 0,564 do SVM).
3. A RNA também lidera nas três métricas macro simultaneamente (sensibilidade, especificidade e F1), o
   que torna a escolha robusta e não dependente da métrica adotada.

**Limitação observada:** a classe **1+** é o gargalo de todos os modelos (sensibilidade de apenas 0,46 a
0,60), sendo confundida principalmente com 2+ e com 0 — comportamento esperado, pois 1+ é justamente a
fronteira visual entre "sem marcação" e "marcação moderada".

---

## Exercício 2 – Redes Neurais Convolucionais (Transfer Learning)

Treinamento de 10 épocas, base convolucional congelada (pesos ImageNet) e novas camadas *Fully
Connected* para 4 classes. Resultados na base de **Teste**:

| Arquitetura | Data Augmentation | Sensibilidade macro | Especificidade macro | F1 macro |
|---|---|---|---|---|
| **ResNet50** | **Sim** | 0,9117 | 0,9715 | **0,9104** |
| ResNet50 | Não | 0,8947 | 0,9661 | 0,8932 |
| VGG16 | Não | 0,7855 | 0,9304 | 0,7779 |
| VGG16 | Sim | 0,7882 | 0,9310 | 0,7719 |

F1-Score por classe:

| Configuração | 0 | 1+ | 2+ | 3+ |
|---|---|---|---|---|
| ResNet50 com augmentation | 0,9802 | **0,8667** | 0,8372 | 0,9574 |
| ResNet50 sem augmentation | 0,9804 | 0,7879 | 0,8211 | 0,9836 |
| VGG16 com augmentation | 0,9038 | 0,4604 | 0,7290 | 0,9945 |
| VGG16 sem augmentation | 0,9353 | 0,5621 | 0,6667 | 0,9474 |

### Melhor modelo: **ResNet50 com Data Augmentation** — F1 macro = 0,9104

**Justificativa:**

1. **Maior F1 macro entre as quatro configurações** (0,9104), e também a maior sensibilidade macro
   (0,9117) e a maior especificidade macro (0,9715) — portanto é o melhor modelo independentemente de
   qual das três métricas exigidas seja adotada como critério.
2. **A ResNet50 é claramente superior à VGG16 neste problema** (0,89–0,91 contra 0,77–0,78). Como apenas
   as camadas novas são treinadas, o resultado depende da qualidade das características que a base
   congelada produz: as conexões residuais e a maior profundidade da ResNet50 geram representações mais
   discriminativas para a textura e a coloração da imuno-histoquímica.
3. **O Data Augmentation ajudou a ResNet50** (+0,017 de F1 macro), com ganho concentrado exatamente na
   classe mais difícil: a sensibilidade da classe **1+ subiu de 0,722 para 0,867**. Os históricos de
   treino sugerem o motivo: sem augmentation a acurácia de treino chega a **100%** já na 7ª época e
   termina com perda de treino de apenas 0,006, indicando **memorização** do conjunto de treinamento;
   com augmentation o modelo termina em 98,5% de treino e perda 0,057, ou seja, não decora a base e
   mantém margem para generalizar.

   É importante registrar que a **validação não antecipa esse ganho**: a configuração sem augmentation
   termina com val_loss 0,114 e val_accuracy 0,974, melhores que os 0,219 e 0,940 da versão com
   augmentation, e a curva de validação com augmentation é bastante instável (val_loss oscila entre
   0,142 e 0,444 ao longo das 10 épocas). Com apenas 117 imagens de validação, provenientes de poucos
   pacientes, essa métrica tem variância alta. A evidência que sustenta a escolha é, portanto, o
   desempenho na **base de Teste** (independente e com pacientes distintos), e não a curva de validação.
4. **Na VGG16 o augmentation foi neutro/levemente negativo** (0,7779 → 0,7719). Com apenas 10 épocas e
   somente a cabeça densa sendo treinada, o augmentation torna a tarefa mais difícil e a VGG16 — que já
   parte de características menos discriminativas — não teve épocas suficientes para compensar. Isso
   reforça que o ganho do augmentation depende da capacidade de representação da base utilizada.

**Observações:**

- O *Data Augmentation* foi deliberadamente **conservador quanto à cor** (apenas espelhamento
  horizontal, rotação de ±4%, translação de 5% e zoom de 8%), sem alterações de brilho, contraste ou
  matiz, porque a classificação HER2 é baseada justamente na intensidade da coloração — distorcer as
  cores destruiria a informação diagnóstica, conforme alertado no enunciado.
- A classe **3+** é reconhecida com sensibilidade 1,000 por todas as configurações (marcação intensa e
  visualmente inconfundível), e a classe **0** fica acima de 0,93; as confusões restantes concentram-se
  entre **1+ e 2+**, classes adjacentes na escala.
- A divisão 80/20 foi feita **por paciente** (`StratifiedGroupKFold` agrupado por XX, `random_state=42`),
  idêntica à do exercício 1, garantindo que nenhum paciente apareça simultaneamente em treino e
  validação, e que nenhum paciente de treino/validação apareça no teste.
- As imagens de 250x250x3 foram redimensionadas para 224x224x3, entrada esperada por ambas as redes.

---

## Conclusão geral

A melhor abordagem do trabalho como um todo é a do exercício 2: **ResNet50 com Transfer Learning e Data
Augmentation (F1 macro = 0,9104)**, que supera em cerca de 9 pontos percentuais o melhor modelo do
exercício 1 (VGG16 + RNA, F1 macro = 0,8180). Treinar uma cabeça de classificação diretamente sobre a
base convolucional congelada, com augmentation leve, aproveita melhor os pesos pré-treinados do que
extrair um vetor fixo de características e entregá-lo a um classificador clássico.
