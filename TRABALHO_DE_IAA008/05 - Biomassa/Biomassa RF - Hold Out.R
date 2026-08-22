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

### Treinar Randon Forest com a base de Treino 
set.seed(202650)
rf <- train(biomassa~., data=treino, method="rf")
rf

### Aplicar modelos treinados na base de Teste
predicoes.rf <- predict(rf, teste)


########### CALCULO DE METRICAS #################
# install.packages("Metrics")
library(Metrics)

# Dados reais e preditos
obs <- teste$biomassa
pred <- predicoes.rf
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
r2_val   <- r2(predicoes.rf,teste$biomassa)

# Consolidação em um data frame
resultados <- data.frame(
  R2 = r2_val,
  Syx = syx,
  Pearson_r = r_pearson,
  RMSE = rmse_val,
  MAE = mae_val
)

print(resultados)