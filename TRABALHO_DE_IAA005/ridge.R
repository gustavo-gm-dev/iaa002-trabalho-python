# ============================================================
# IAA005 - Estatística Aplicada II - UFPR
# Regressão Ridge para predição de salário-hora feminino
# ============================================================

# PASSO 1: Carregar pacote
library(glmnet)

# PASSO 2: Carregar base de dados
load("trabalhosalarios.RData")

# PASSO 3: Preparar variáveis
# X = variáveis explicativas | y = salário-hora em log
X <- as.matrix(trabalhosalarios[, c("husage","husunion","husearns",
     "huseduc","husblck","hushisp","hushrs","kidge6","age","black",
     "educ","hispanic","union","exper","kidlt6")])
y <- trabalhosalarios$lwage

# PASSO 4: Encontrar o melhor Lambda via validação cruzada (10 folds)
set.seed(42)
cv_ridge <- cv.glmnet(X, y, alpha=0, nfolds=10)
lambda_ridge <- cv_ridge$lambda.min
cat("Melhor Lambda Ridge:", lambda_ridge, "\n")

# PASSO 5: Ajustar o modelo Ridge final
mod_ridge <- glmnet(X, y, alpha=0, lambda=lambda_ridge)
cat("\nCoeficientes do modelo Ridge:\n")
print(coef(mod_ridge))

# PASSO 6: Calcular métricas RMSE e R²
pred_ridge <- predict(mod_ridge, s=lambda_ridge, newx=X)
rmse_ridge <- sqrt(mean((y - pred_ridge)^2))
r2_ridge   <- 1 - sum((y - pred_ridge)^2) / sum((y - mean(y))^2)
cat("\nRMSE Ridge:", round(rmse_ridge, 5))
cat("\nR²  Ridge:", round(r2_ridge, 5), "\n")

# PASSO 7: Predição para novo perfil (valores do enunciado)
novo <- matrix(c(40,0,600,13,1,0,40,1,38,0,13,1,0,18,1),
               nrow=1, dimnames=list(NULL, colnames(X)))
pred_log   <- predict(mod_ridge, s=lambda_ridge, newx=novo)[1]
pred_dolar <- exp(pred_log)
cat("\nPredição (log):", round(pred_log, 5))
cat("\nPredição (US$/hora):", round(pred_dolar, 4), "\n")

# PASSO 8: Intervalo de confiança via Bootstrap (1000 reamostras)
set.seed(42)
B <- 1000
n <- nrow(trabalhosalarios)
preds_boot <- numeric(B)
for(b in 1:B){
  idx <- sample(1:n, n, replace=TRUE)
  mod_b <- glmnet(X[idx,], y[idx], alpha=0, lambda=lambda_ridge)
  preds_boot[b] <- predict(mod_b, s=lambda_ridge, newx=novo)[1]
}
ic <- quantile(preds_boot, c(0.025, 0.975))
cat("\nIC 95% (log):", round(ic[1],5), "a", round(ic[2],5))
cat("\nIC 95% (US$/h):", round(exp(ic[1]),2), "a", round(exp(ic[2]),2), "\n")
