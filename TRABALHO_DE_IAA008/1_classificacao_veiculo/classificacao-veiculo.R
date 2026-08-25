### 0. Instalação (descomente se precisar) e carregamento dos pacotes
# install.packages("caret") 
# install.packages("e1071") 
# install.packages("mlbench") 
# install.packages("mice")
# install.packages("randomForest")
# install.packages("nnet")
# install.packages("kernlab")

library(caret) 
library(e1071) 
library(mlbench) 
library(mice)
library(randomForest)
library(nnet)
library(kernlab)

### 1. Obter e preparar os dados
# Lembre-se de ajustar o setwd() para a sua pasta real, se necessário
# setwd("/Users/seu_usuario/sua_pasta")
dados <- read.csv("6 - Veiculos - Dados.csv")

# Ajuste fundamental para o código ficar igual ao seu:
dados$a <- NULL # Remove a coluna de ID numérico para não atrapalhar o modelo
colnames(dados)[colnames(dados) == "tipo"] <- "y" # Renomeia 'tipo' para 'y'
dados$y <- as.factor(dados$y) # Converte para fator

### 2. Criar bases de Treino e Teste
set.seed(1912)
indices <- createDataPartition(dados$y, p=0.80, list=FALSE)
treino <- dados[indices,] 
teste <- dados[-indices,]


### ==========================================
### KNN
### ==========================================
tuneGrid <- expand.grid(k = c(1,3,5,7,9))
set.seed(1912)
knn <- train(y ~ ., data = treino, method = "knn", tuneGrid=tuneGrid)
knn # Mostra o melhor K

## Faz a predição e mostra a matriz de confusão
predict.knn <- predict(knn, teste)
confusionMatrix(predict.knn, as.factor(teste$y)) # Mostra a Acurácia


### ==========================================
### REDES NEURAIS (RNA)
### ==========================================
### RNA - Hold-out
set.seed(1912)
rna <- train(y~., data=treino, method="nnet", trace=FALSE)
rna # Mostra size e decay

### Matriz de confusão RNA Hold-out
predict.rna <- predict(rna, teste)
confusionMatrix(predict.rna, as.factor(teste$y)) # Mostra a Acurácia

### RNA - Cross-Validation (CV)
ctrl <- trainControl(method = "cv", number = 10)
grid <- expand.grid(size = seq(from = 1, to = 35, by = 10), decay = seq(from = 0.1, to = 0.6, by = 0.3))

set.seed(1912)
rna <- train(form = y~., data = treino, method = "nnet", tuneGrid = grid, trControl = ctrl, maxit = 2000, trace=FALSE) 
rna # Mostra o melhor size e decay

### Matriz de confusão RNA CV
predict.rna <- predict(rna, teste)
confusionMatrix(predict.rna, as.factor(teste$y)) # Mostra a Acurácia


### ==========================================
### SVM
### ==========================================
### SVM - Hold-out
set.seed(1912)
svm <- train(y~., data=treino, method="svmRadial") 
svm # Mostra C e sigma

### Matriz de confusão SVM Hold-out
predict.svm <- predict(svm, teste)
confusionMatrix(predict.svm, as.factor(teste$y)) # Mostra a Acurácia

### SVM - Cross-Validation (CV)
ctrl <- trainControl(method = "cv", number = 10)
tuneGrid = expand.grid(C=c(1, 2, 10, 50, 100), sigma=c(.01, .015, 0.2))

set.seed(1912)
svm <- train(y~., data=treino, method="svmRadial", trControl=ctrl, tuneGrid=tuneGrid)
svm # Mostra os melhores C e sigma

### Matriz de confusão SVM CV
predict.svm <- predict(svm, teste)
confusionMatrix(predict.svm, as.factor(teste$y)) # Mostra a Acurácia


### ==========================================
### RANDOM FOREST (RF)
### ==========================================
### RF - Hold-out
set.seed(1912)
rf <- train(y~., data=treino, method="rf")
rf # Mostra mtry

### Matriz de confusão RF Hold-out
predict.rf <- predict(rf, teste)
confusionMatrix(predict.rf, as.factor(teste$y)) # Mostra a Acurácia

### RF - Cross-Validation (CV)
ctrl <- trainControl(method = "cv", number = 10)
tuneGrid = expand.grid(mtry=c(2, 5, 7, 9))

set.seed(1912)
rf <- train(y~., data=treino, method="rf", trControl=ctrl, tuneGrid=tuneGrid)
rf # Mostra o melhor mtry

### Matriz de confusão RF CV
predict.rf <- predict(rf, teste)
confusionMatrix(predict.rf, as.factor(teste$y)) # Mostra a Acurácia


### ==========================================
### PREDIÇÕES DE NOVOS CASOS (Para o melhor modelo)
### ==========================================
# Passo Extra: Como você precisa de um arquivo com 3 novos casos (conforme o PDF pede: "criar um arquivo com novos casos à sua escolha"), o comando abaixo salva 3 linhas da própria base original em um arquivo CSV para simularmos isso, para não dar erro de leitura no código abaixo.
casos_ficticios <- dados[c(20, 40, 60), ] # Pegando as linhas 20, 40 e 60
casos_ficticios$y <- NULL # Removemos a resposta certa
write.csv(casos_ficticios, "6 - Veiculos - Novos Casos.csv", row.names = FALSE)


### CÓDIGO IDÊNTICO AO SEU:
dados_novos_casos <- read.csv("6 - Veiculos - Novos Casos.csv")
View(dados_novos_casos)

# OBS IMPORTANTE: Troque a variável 'rf' na linha abaixo pelo modelo de MAIOR acurácia. 
# Se a maior foi do svm, escreva predict(svm, dados_novos_casos). 
# Se foi random forest, escreva predict(rf, dados_novos_casos).
predict_novos <- predict(rf, dados_novos_casos)

resultado <- cbind(dados_novos_casos, predict_novos)
View(resultado)