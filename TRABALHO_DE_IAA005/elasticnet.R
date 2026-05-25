##############################################################
#           Trabalho de Estatística Aplicada II.             #
#                  Regressao ElasticNet                      # 
##############################################################

# Instalando os pacotes necessarios (descomente se precisar)
 install.packages("plyr")
 install.packages("readr")
 install.packages("dplyr")
 install.packages("ggplot2")
 install.packages("repr")
 install.packages("glmnet")
 install.packages("caret")

# Carregando os pacotes necessarios
library(plyr)
library(readr)
library(dplyr)
library(ggplot2)
library(repr)
library(glmnet)
library(caret)

# Carregando o dataset
load("~/Documents/Estatistica 2/Scripts do R Usados nas Aulas Práticas/trabalhosalarios.RData")
basecompleta <- trabalhosalarios

# Visualizando o dataset
glimpse(basecompleta)

# Definindo a seed para particionamento do dataset conforme acordado com Matheus e Amanda
set.seed(42)

# Indice para particionamento do dataset (80% treino e 20 teste)
index = sample(1:nrow(basecompleta), 0.8*nrow(basecompleta))

# Criando as bases de treino e teste
train = basecompleta[index,]
test = basecompleta[-index,]

# vendo se tá tudo certinho com elas
dim(train)
dim(test)

# Separando as variaveis continuas
cols = c('husage', 'husearns', 'huseduc', 'hushrs', 'age', 'educ', 'exper', 'lwage')
basecompleta

# Padronizando a base de treinamento e teste, usando o metodo center e scale
pre_proc_val <- preProcess(train[,cols], method = c("center", "scale"))
train[,cols] = predict(pre_proc_val, train[,cols])
test[,cols] = predict(pre_proc_val, test[,cols])

# Conferindo se esta tudo ok
summary(train)
summary(test)


#############################################################
#                    REGRESSAO ELASTICNET                   #
#############################################################

# criando o conjunto de todas as variaveis do modelo
cols_reg = c('husage', 'husunion', 'husearns', 'huseduc', 'husblck', 'hushisp', 
             'hushrs', 'kidge6', 'age', 'black', 'educ', 'hispanic', 
             'union', 'exper', 'kidlt6', 'lwage')

# Gerando variaveis dummies pra transformar as categorias textuais em colunas 1 e 0
dummies <- dummyVars(lwage ~ husage + husunion + husearns + huseduc + husblck + hushisp + 
                       hushrs + kidge6 + age + black + educ + hispanic + 
                       union + exper + kidlt6, 
                     data = basecompleta[,cols_reg])

train_dummies = predict(dummies, newdata = train[,cols_reg])
test_dummies = predict(dummies, newdata = test[,cols_reg])

# Verificando as categorias
print(dim(train_dummies)); print(dim(test_dummies))

# Guardando a matriz de dados explicativos (x) e vetor dependente (y)
x = as.matrix(train_dummies)
y_train = train$lwage

x_test = as.matrix(test_dummies)
y_test = test$lwage

# Configurando o treinamento do modelo por cross validation, com 10 folders e 5 repeticoes
train_cont <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 5,
                           search = "random",
                           verboseIter = TRUE)

# Treinando o modelo
elastic_reg <- train(lwage ~ husage + husunion + husearns + huseduc + husblck + hushisp + 
                       hushrs + kidge6 + age + black + educ + hispanic + 
                       union + exper + kidlt6,
                     data = train,
                     method = "glmnet",
                     tuneLength = 10,
                     trControl = train_cont)

# O melhor parametro alpha escolhido eh:
elastic_reg$bestTune

# E os parametros sao:
elastic_reg[["finalModel"]][["beta"]]

# Avaliando a performance do modelo
predictions_train <- predict(elastic_reg, x)

# Calculo do R^2 e RMSE
eval_results <- function(true, predicted, df) {
  SSE <- sum((predicted - true)^2)
  SST <- sum((true - mean(true))^2)
  R_square <- 1 - SSE / SST
  RMSE = sqrt(SSE/nrow(df))
  
  data.frame(
    RMSE = RMSE,
    Rsquare = R_square
  )
}

# Metricas de performance na base de treinamento:
eval_results(y_train, predictions_train, train) 
# RMSE 0.5534138
# Rsquare 0.6935843

# Predicoes na base de teste
predictions_test <- predict(elastic_reg, x_test)

# Metricas de performance na base de teste sao:
eval_results(y_test, predictions_test, test)
# RMSE 0.849   
# Rsquare 0.300

# Como os resultados entre treino e teste ficaram proximos, comprova-se que o modelo nao sofreu overfitting