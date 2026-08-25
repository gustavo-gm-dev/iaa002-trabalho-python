library(caret)
library(Metrics)

set.seed(202650)

### Leitura dos dados
df <- read.csv("C:/Users/igorn/OneDrive/Documentos/IAA/IAA008/9 - Admissao - Dados(in).csv")
head(df)
str(df)
summary(df)

### remove num
df$num <- NULL
head(df)

y <- df$ChanceOfAdmit
X <- df[, names(df) != "ChanceOfAdmit"]


### Normaliza os dados
scaler <- preProcess(X, method = "range")
X_scaled <- predict(scaler, X)
head(X_scaled)


### separa os dados de treino e teste
indice <- createDataPartition(
  y,
  p = 0.7,
  list = FALSE
)

X_train <- X_scaled[indice, ]
X_test  <- X_scaled[-indice, ]

y_train <- y[indice]
y_test  <- y[-indice]


### Define o KNN - Grid Search e treina o modelo
grid_knn <- expand.grid(k = c(1,3,5,7,9))

controle_cv <- trainControl(
  method = "cv",
  number = 9
)

modelo_knn <- train(
  x = X_train,
  y = y_train,
  method = "knn",
  trControl = controle_cv,
  tuneGrid = grid_knn
)

modelo_knn$bestTune

## Predição no conjunto de teste
pred_knn <- predict(modelo_knn, X_test)

## MÉTRICAS

obs <- y_test
pred <- pred_knn

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

resultados_knn <- data.frame(
  R2 = r2_val,
  Syx = syx,
  Pearson = r_pearson,
  RMSE = rmse_val,
  MAE = mae_val
)

print(resultados_knn)