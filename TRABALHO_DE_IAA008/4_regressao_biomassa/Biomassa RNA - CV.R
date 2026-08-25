### Instalação dos pacotes (são os mesmos da classificação)
#install.packages("caret") 
#install.packages("e1071") 
#install.packages("mlbench")
#install.packages("mice")
library(mlbench) 
library(caret) 
library(mice)

### Leitura dos dados
setwd("~/IAA008 Aprendizado de Maquina/dados/05 - Biomassa")
dados <- read.csv("5 - Biomassa - Dados.csv", header=T)
View(dados)

### Cria arquivo de treino e teste
set.seed(202650)
indices <- createDataPartition(dados$biomassa, p=0.80, list=FALSE) 
treino <- dados[indices,]
teste <- dados[-indices,]

### Treino com CV
set.seed(202650)
control <- trainControl(method = "cv", number = 10)
tuneGrid <- expand.grid(size = seq(from = 1, to = 10, by = 1), decay = seq(from = 0.1, to = 0.9, by = 0.3))
set.seed(202650)
rna <- train(biomassa~., data=treino, method="nnet", trControl=control, tuneGrid=tuneGrid, linout=T, 
             MaxNWts=10000, maxit=2000, trace=F)
rna

### Predições
predicoes.rna <- predict(rna, teste)


########### CALCULO DE METRICAS #################
# install.packages("Metrics")
library(Metrics)

# Dados reais e preditos
obs <- teste$biomassa
pred <- predicoes.rna
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
r2_val   <- r2(predicoes.rna,teste$biomassa)

# Consolidação em um data frame
resultados <- data.frame(
  R2 = r2_val,
  Syx = syx,
  Pearson_r = r_pearson,
  RMSE = rmse_val,
  MAE = mae_val
)

print(resultados)