###Pacotes necessários: 

install.packages("e1071") 

install.packages("kernlab") 

install.packages("caret") 

library("caret") 
install.packages("mice") 
library(mice) 

###Leitura dos dados (RStudio online) 
X10_Diabetes_Dados <- read_csv("10 - Diabetes - Dados.csv")  

###Criar bases de Treino e Teste 

set.seed(202650) 
indices <- createDataPartition 
(X10_Diabetes_Dados$diabetes, p=0.80,list=FALSE) 
treino <- X10_Diabetes_Dados[indices,]  
teste <- X10_Diabetes_Dados[-indices,] 

###Treinar SVM com a base de Treino 

set.seed(202650)  
svm <- train(diabetes~., data=treino, method="svmRadial")  
svm 

###Aplicar modelos treinados na base de Teste 

predict.svm <- predict(svm, teste) 
confusionMatrix(predict.svm, as.factor(teste$diabetes))  

###PREDIÇÕES DE NOVOS CASOS 

dados_novos_casos <- read.csv("Diabetes - Novos Casos.csv")  
dados_novos_casos$num <- NULL View(dados_novos_casos)  
predict.svm <- predict(svm, dados_novos_casos)  
resultado <- cbind(dados_novos_casos, predict.svm)  
resultado$diabetes <- NULL  
View(resultado) 