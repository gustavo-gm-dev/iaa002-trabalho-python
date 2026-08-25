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

############################################
### RNA - CV

controle_cv <- trainControl(
  method = "cv",
  number = 9
)

rna_cv <- train(
  x = X_train,
  y = y_train,
  method = "nnet",
  trControl = controle_cv,
  linout = TRUE,
  trace = FALSE
)

rna_cv


### Predição no conjunto de teste

pred_rna_cv <- predict(
  rna_cv,
  X_test
)


############################################
## MÉTRICAS RNA - CV

obs <- y_test
pred <- pred_rna_cv

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

resultados_rna_cv <- data.frame(
  R2 = r2_val,
  Syx = syx,
  Pearson = r_pearson,
  RMSE = rmse_val,
  MAE = mae_val
)

print(resultados_rna_cv)