install.packages("glmnet")
install.packages("caret")

# ==========================
# BLOCO 1 — carregar bibliotecas e base
# ==========================

# Limpar ambiente
rm(list=ls())

# Definir pasta do projeto
setwd("C:/Users/deuss/Documents/IAA/IAA004/iaa002-trabalho-python/TRABALHO_DE_IAA005")

# Carregar bibliotecas
library(glmnet)
library(caret)

# Carregar base
load("trabalhosalarios.RData")

# Verificar nome do objeto carregado
ls()


# ==========================
# BLOCO 2 — preparação dos dados
# ==========================

dados <- trabalhosalarios

dados <- na.omit(dados)

# Remover variável earns
dados <- subset(dados, select = -earns)

# Variável dependente
y <- dados$lwage

# Matriz com variáveis explicativas
x <- model.matrix(lwage ~ ., dados)[,-1]


# ==========================
# BLOCO 3 — treino e Lasso
# ==========================

# Dividir treino/teste (80/20)
set.seed(42)

treino <- createDataPartition(
  y,
  p=0.8,
  list=FALSE
)

x_train <- x[treino,]
x_test <- x[-treino,]

y_train <- y[treino]
y_test <- y[-treino]


# Ajustar Lasso usando validação cruzada
lasso.cv <- cv.glmnet(
  x_train,
  y_train,
  alpha = 1
)

# Melhor lambda encontrado
best_lambda <- lasso.cv$lambda.min

print(best_lambda)


# Modelo final
modelo_lasso <- glmnet(
  x_train,
  y_train,
  alpha = 1,
  lambda = best_lambda
)


# ==========================
# BLOCO 4 — métricas
# ==========================

pred <- predict(
  modelo_lasso,
  s = best_lambda,
  newx = x_test
)

# RMSE
rmse <- sqrt(mean((y_test-pred)^2))

cat("RMSE =",rmse,"\n")


# R²
r2 <- cor(y_test,pred)^2

cat("R2 =",r2,"\n")


# Coeficientes selecionados
coef(modelo_lasso)


# ==========================
# BLOCO 5 — predição solicitada
# ==========================

novo <- data.frame(
  
  husage=40,
  husunion=0,
  husearns=600,
  huseduc=13,
  husblck=1,
  hushisp=0,
  hushrs=40,
  kidge6=1,
  age=38,
  black=0,
  educ=13,
  hispanic=1,
  union=0,
  exper=18,
  kidlt6=1
  
)

novo_x <- model.matrix(~., novo)[,-1]


pred_log <- predict(
  modelo_lasso,
  s = best_lambda,
  newx = novo_x
)

cat("Predição em log =",pred_log,"\n")


# Aplicar antilog
pred_salario <- exp(pred_log)

cat("Salário previsto por hora =",pred_salario,"\n")


# ==========================
# Limpar análise
# ==========================

rm(list=ls())
cat("\014")
