### Instalação dos pacotes (são os mesmos da classificação)
### Pacotes necessários:
#install.packages("e1071")
#install.packages("kernlab")
#install.packages("caret")
#install.packages("Metrics")
library(caret)

### Leitura dos dados
setwd("~/IAA008 Aprendizado de Maquina/dados/05 - Biomassa")
dados <- read.csv("5 - Biomassa - Dados.csv", header=T)
View(dados)

### Cria arquivo de treino e teste
set.seed(202650)
indices <- createDataPartition(dados$biomassa, p=0.80, list=FALSE) 
treino <- dados[indices,]
teste <- dados[-indices,]

#### Vários C e sigma
ctrl <- trainControl(method = "cv", number = 10)
tuneGrid = expand.grid(C=c(1, 2, 10, 50, 100), sigma=c(.01, .015, 0.2))
set.seed(202650)
svm <- train(biomassa~., data=treino, method="svmRadial", trControl=ctrl, tuneGrid=tuneGrid)
svm

### Aplicar modelos treinados na base de Teste
predicoes.svm <- predict(svm, teste)

########### CALCULO DE METRICAS #################
# install.packages("Metrics")
library(Metrics)

# Dados reais e preditos
obs <- teste$biomassa
pred <- predicoes.svm
n <- length(obs)
k <- 1 # Graus de liberdade 1 conforme aula do professor

# Métricas de Erro e Correlação
mae_val   <- mae(obs, pred)
rmse_val  <- rmse(obs, pred)
r_pearson <- cor(obs, pred)

# Erro Padrão da Estimativa (Syx) e Syx%
syx      <- sqrt(sum((obs - pred)^2) / (n - k))

# R2 ajustado/simples
r2 <- function(predito, observado) {
  return(1 - (sum((predito-observado)^2) / sum((observado-mean(observado))^2)))
}
r2_val   <- r2(predicoes.svm,teste$biomassa)

# Consolidação em um data frame
resultados <- data.frame(
  R2 = r2_val,
  Syx = syx,
  Pearson_r = r_pearson,
  RMSE = rmse_val,
  MAE = mae_val
)

print(resultados)