# ============================================================
# IAA005 - Estatística Aplicada II 
# Regressões Ridge, Lasso e ElasticNet (Modelo Vencedor: Lasso)
# ============================================================

# PASSO 1: Carregar pacotes necessários
library(plyr)
library(readr)
library(dplyr)
library(ggplot2)
library(caret)
library(glmnet)

# PASSO 2: Carregar base de dados
load("trabalhosalarios.RData")
dat <- na.omit(trabalhosalarios)

# Selecionando a variável dependente (lwage) e as explicativas do enunciado
cols_reg <- c("husage", "husunion", "husearns", "huseduc", "husblck", 
              "hushisp", "hushrs", "kidge6", "age", "black", "educ", 
              "hispanic", "union", "exper", "kidlt6", "lwage")

dat <- dat[, cols_reg]

# PASSO 3: Divisão em Treino (80%) e Teste (20%)
set.seed(42)
index = sample(1:nrow(dat), 0.8*nrow(dat))
train = dat[index,]  
test = dat[-index,] 

# PASSO 4: Padronização (Center e Scale)
# Excluindo as variáveis binárias (dummies) da padronização
cols_padronizar <- c('husage', 'husearns', 'huseduc', 'hushrs', 'age', 'educ', 'exper', 'lwage')

pre_proc_val <- preProcess(train[, cols_padronizar], method = c("center", "scale"))
train[, cols_padronizar] = predict(pre_proc_val, train[, cols_padronizar])
test[, cols_padronizar]  = predict(pre_proc_val, test[, cols_padronizar])

# PASSO 5: Preparar Matrizes X e y
x = as.matrix(train %>% select(-lwage))
y_train = train$lwage

x_test = as.matrix(test %>% select(-lwage))
y_test = test$lwage

# Função de avaliação (Idêntica à utilizada em aula)
eval_results <- function(true, predicted, df) {
  SSE <- sum((predicted - true)^2)
  SST <- sum((true - mean(true))^2)
  R_square <- 1 - SSE / SST
  RMSE = sqrt(SSE/nrow(df))
  data.frame(RMSE = RMSE, Rsquare = R_square)
}

# ============================================================
# TREINAMENTO DOS 3 MODELOS
# ============================================================

# 1. RIDGE (Alpha = 0)
lambdas <- 10^seq(2, -3, by = -.1)
ridge_lamb <- cv.glmnet(x, y_train, alpha = 0, lambda = lambdas)
best_lambda_ridge <- ridge_lamb$lambda.min
ridge_reg = glmnet(x, y_train, alpha = 0, lambda = best_lambda_ridge)
pred_ridge_test <- predict(ridge_reg, s = best_lambda_ridge, newx = x_test)
res_ridge <- eval_results(y_test, pred_ridge_test, test)

# 2. LASSO (Alpha = 1) - MODELO VENCEDOR
lasso_lamb <- cv.glmnet(x, y_train, alpha = 1, lambda = lambdas)
best_lambda_lasso <- lasso_lamb$lambda.min 
lasso_model <- glmnet(x, y_train, alpha = 1, lambda = best_lambda_lasso)
pred_lasso_test <- predict(lasso_model, s = best_lambda_lasso, newx = x_test)
res_lasso <- eval_results(y_test, pred_lasso_test, test)

# 3. ELASTICNET (Caret)
train_cont <- trainControl(method = "repeatedcv", number = 10, repeats = 5, search = "random")
elastic_reg <- train(lwage ~ ., data = train, method = "glmnet", tuneLength = 10, trControl = train_cont)
pred_elastic_test <- predict(elastic_reg, x_test)
res_elastic <- eval_results(y_test, pred_elastic_test, test)

# ============================================================
# COMPARAÇÃO DOS MODELOS (Tabela para o PDF)
# ============================================================
tabela_metricas <- data.frame(
  Modelo = c("Ridge", "Lasso", "ElasticNet"),
  RMSE_Teste = c(res_ridge$RMSE, res_lasso$RMSE, res_elastic$RMSE),
  R2_Teste = c(res_ridge$Rsquare, res_lasso$Rsquare, res_elastic$Rsquare)
)

cat("\n--- ESTATÍSTICAS DOS MODELOS NA BASE DE TESTE ---\n")
print(tabela_metricas)

# ============================================================
# PREDIÇÃO PARA O NOVO PERFIL (Utilizando o modelo LASSO)
# ============================================================

# Padronizando os valores contínuos do enunciado usando a mesma escala do treino
husage_pred   <- (40  - pre_proc_val[["mean"]][["husage"]])   / pre_proc_val[["std"]][["husage"]]
husearns_pred <- (600 - pre_proc_val[["mean"]][["husearns"]]) / pre_proc_val[["std"]][["husearns"]]
huseduc_pred  <- (13  - pre_proc_val[["mean"]][["huseduc"]])  / pre_proc_val[["std"]][["huseduc"]]
hushrs_pred   <- (40  - pre_proc_val[["mean"]][["hushrs"]])   / pre_proc_val[["std"]][["hushrs"]]
age_pred      <- (38  - pre_proc_val[["mean"]][["age"]])      / pre_proc_val[["std"]][["age"]]
educ_pred     <- (13  - pre_proc_val[["mean"]][["educ"]])     / pre_proc_val[["std"]][["educ"]]
exper_pred    <- (18  - pre_proc_val[["mean"]][["exper"]])    / pre_proc_val[["std"]][["exper"]]

# Matriz do exemplo combinando valores padronizados com binários puros
our_pred = as.matrix(data.frame(husage = husage_pred, husunion = 0, husearns = husearns_pred, 
                                huseduc = huseduc_pred, husblck = 1, hushisp = 0, hushrs = hushrs_pred, 
                                kidge6 = 1, age = age_pred, black = 0, educ = educ_pred, 
                                hispanic = 1, union = 0, exper = exper_pred, kidlt6 = 1))

cat("\n--- RESULTADO DA PREDIÇÃO (Modelo Vencedor: Lasso) ---\n")
predict_our_lasso <- predict(lasso_model, s = best_lambda_lasso, newx = our_pred)

# Revertendo a padronização para encontrar o Log original
lwage_pred_lasso <- (predict_our_lasso * pre_proc_val[["std"]][["lwage"]]) + pre_proc_val[["mean"]][["lwage"]]

cat("Predição Salário-Hora em Log:", round(lwage_pred_lasso, 5), "\n")
cat("Predição Salário-Hora (Antilog US$):", round(exp(lwage_pred_lasso), 2), "\n")

# ============================================================
# INTERVALO DE CONFIANÇA 95% 
# ============================================================
n <- nrow(train) 
m <- lwage_pred_lasso 
s <- pre_proc_val[["std"]][["lwage"]] 
dam <- s/sqrt(n) 

CIlwr_lasso <- m + (qnorm(0.025))*dam 
CIupr_lasso <- m - (qnorm(0.025))*dam 

cat("\n--- INTERVALO DE CONFIANÇA 95% ---\n")
cat("IC 95% (Log): [", round(CIlwr_lasso, 5), ";", round(CIupr_lasso, 5), "]\n")
cat("IC 95% (US$): [", round(exp(CIlwr_lasso), 2), ";", round(exp(CIupr_lasso), 2), "]\n")
