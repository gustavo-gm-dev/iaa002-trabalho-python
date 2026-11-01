Ministério da Educação  
UNIVERSIDADE FEDERAL DO PARANÁ  
SEPT – Setor de Educação Profissional e Tecnológica  
Especialização em Inteligência Artificial Aplicada

# TRABALHO DE IAA011 – Visão Computacional

**O que deve ser entregue:**

- Um documento PDF contendo o(s) programa(s) desenvolvidos com suas respectivas saídas
- O(s) programa(s) que foram executados por vocês e os arquivos (csv) gerados
- Um texto com a escolha do melhor modelo em cada exercício e a justificativa do porquê

## 1 Extração de Características

Os bancos de imagens fornecidos são conjuntos de imagens de 250x250 pixels de imuno-histoquímica (biópsia) de câncer de mama. No total são 4 classes (0, 1+, 2+ e 3+) que estão divididas em diretórios. O objetivo é classificar as imagens nas categorias correspondentes. Uma base de imagens será utilizada para o treinamento e outra para o teste do treino.

As imagens fornecidas são recortes de uma imagem maior do tipo WSI (*Whole Slide Imaging*) disponibilizada pela Universidade de Warwick ([link](https://pubmed.ncbi.nlm.nih.gov/28771788/)). A nomenclatura das imagens segue o padrão XX_HER_YYYY.png, onde XX é o número do paciente e YYYY é o número da imagem recortada. Separe a base de treino em 80% para treino e 20% para validação. **Separe por pacientes (XX), não utilize a separação randômica! Pois, imagens do mesmo paciente não podem estar na base de treino e de validação, pois isso pode gerar um viés.** No caso da CNN VGG16 remova a última camada de classificação e armazene os valores da penúltima camada como um vetor de características. Após o treinamento, os modelos treinados devem ser validados na base de teste.

Tarefas:

1. Carregue a base de dados de **Treino**.
2. Crie partições contendo 80% para treino e 20% para validação (atenção aos pacientes).
3. Extraia características utilizando LBP e a CNN VGG16 (gerando um csv para cada extrator).
4. Treine modelos Random Forest, SVM e RNA para predição dos dados extraídos (nessa tarefa utilize todas as imagens para o treinamento).
5. Carregue a base de Teste e execute a tarefa 3 nesta base.
6. Aplique os modelos treinados nos dados de teste.
7. Calcule as métricas de Sensibilidade, Especificidade e F1-Score com base em suas matrizes de confusão.
8. Indique qual modelo dá o melhor o resultado e a métrica utilizada
9. Utilize a base de dados de Treino já separadas em treino e validação do exercício anterior.

## 2 Redes Neurais

Utilize as duas bases do exercício anterior para treinar as Redes Neurais Convolucionais VGG16 e a Resnet50. Utilize os pesos pré-treinados (*Transfer Learning*), refaça as camadas *Fully Connected* para o problema de 4 classes. Treine só as novas camadas. Compare os treinos de 10 épocas com e sem *Data Augmentation*. Tanto a VGG16 quanto a Resnet50 têm como camada de entrada uma imagem 224x224x3, ou seja, uma imagem de 224x224 pixels coloridos (3 canais de cores). Portanto, será necessário fazer uma transformação de 250x250x3 para 224x224x3. Ao fazer o *Data Augmentation* cuidado para não alterar demais as cores das imagens e atrapalhar na classificação.

Tarefas:

1. Treine modelos VGG16 e Resnet50 adaptadas com e sem *Data Augmentation*
2. Aplique os modelos treinados nas imagens da base de **Teste**
3. Calcule as métricas de Sensibilidade, Especificidade e F1-Score com base em suas matrizes de confusão.
4. Indique qual modelo dá o melhor o resultado e a métrica utilizada

---

www.iaa.ufpr.br  
Rua Dr. Alcides Vieira Arcoverde, 1225  
CEP 81520-260 – Jardim das Américas  
Curitiba/PR - Brasil
