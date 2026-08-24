library(caret)
library(Metrics)
library(nnet)

set.seed(202650)

### Leitura dos dados
df <- read.csv("C:/Users/igorn/OneDrive/Documentos/IAA/IAA008/9 - Admissao - Dados(in).csv")

head(df)
str(df)
summary(df)


### Remove num
df$num <- NULL
head(df)


### Separa X e Y
y <- df$ChanceOfAdmit
X <- df[, names(df) != "ChanceOfAdmit"]


### Normaliza os dados
scaler <- preProcess(X, method = "range")
X_scaled <- predict(scaler, X)

head(X_scaled)


### Separa os dados de treino e teste
indice <- createDataPartition(
  y,
  p = 0.7,
  list = FALSE
)

X_train <- X_scaled[indice, ]
X_test  <- X_scaled[-indice, ]

y_train <- y[indice]
y_test  <- y[-indice]


### RNA - HOLD-OUT

rna <- train(
  x = X_train,
  y = y_train,
  method = "nnet",
  linout = TRUE,
  trace = FALSE
)

rna


### Predição no conjunto de teste
pred_rna <- predict(
  rna,
  X_test
)


### MÉTRICAS

obs <- y_test
pred <- pred_rna

n <- length(obs)
gl <- 1

mae_val <- mae(obs, pred)

rmse_val <- rmse(obs, pred)

r_pearson <- cor(obs, pred)

syx <- sqrt(sum((obs - pred)^2) / (n - gl))

r2 <- function(predito, observado) {
  return(
    1 - (
      sum((predito - observado)^2) /
        sum((observado - mean(observado))^2)
    )
  )
}

r2_val <- r2(pred, obs)


### Consolidação das métricas
resultados_rna <- data.frame(
  R2 = r2_val,
  Syx = syx,
  Pearson = r_pearson,
  RMSE = rmse_val,
  MAE = mae_val
)

print(resultados_rna)


############################################
### PREVISÃO DOS NOVOS CASOS

novos_casos <- data.frame(
  `GRE Score` = c(212, 324, 200),
  `TOEFL Score` = c(118, 58, 104),
  `University Rating` = c(4, 4, 3),
  SOP = c(4.5, 4, 3),
  LOR = c(4.5, 4.5, 3.5),
  CGPA = c(7.65, 2.87, 8),
  Research = c(1, 1, 1)
)

print(novos_casos)

### Aplica o scaler utilizado no treinamento
novos_casos_scaled <- predict(
  scaler,
  novos_casos
)

print(novos_casos_scaled)


### Faz as novas previsões
predicoes_novos <- predict(
  rna,
  novos_casos_scaled
)

print(predicoes_novos)


### Adiciona as previsões aos casos
resultado_novos <- novos_casos

resultado_novos$ChanceOfAdmit <- predicoes_novos


### Mostra o resultado final
print(resultado_novos)