library(kernlab)
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

### SVM - HOLD-OUT

svm_holdout <- train(
  x = X_train,
  y = y_train,
  method = "svmRadial",
  trControl = trainControl(method = "none")
)

svm_holdout


### Predição no conjunto de teste
pred_svm <- predict(
  svm_holdout,
  X_test
)


## MÉTRICAS SVM - HOLD-OUT
obs <- y_test
pred <- pred_svm

n <- length(obs)
gl <- 1

mae_val <- mae(obs, pred)

rmse_val <- rmse(obs, pred)

r_pearson <- cor(obs, pred)

syx <- sqrt(sum((obs - pred)^2) / (n - gl))

r2_val <- 1 - (
  sum((pred - obs)^2) /
    sum((obs - mean(obs))^2)
)

resultados_svm_holdout <- data.frame(
  R2 = r2_val,
  Syx = syx,
  Pearson = r_pearson,
  RMSE = rmse_val,
  MAE = mae_val
)

print(resultados_svm_holdout)