# TRABALHO FINAL - APRENDIZADO DE MÁQUINA
# REGRAS DE ASSOCIAÇÃO - MUSCULAÇÃO

# Carregar os pacotes
library(arules)
library(readxl)

# Definir a Seed
set.seed(202650)
# Importar a base de Musculação
dados <- read_excel(file.choose(), col_names = FALSE)
# Conferir a importação
dim(dados)
head(dados, 10)
View(dados)
# Transformar cada linha em uma transação
transacoes_lista <- apply(dados, 1, function(x) {
  x <- as.character(x)
  x <- x[!is.na(x)]
  x <- trimws(x)
  x <- x[x != ""]
  unique(x)
})

# Remover possíveis transações vazias
transacoes_lista <- transacoes_lista[lengths(transacoes_lista) > 0]
# Converter para o formato de transações
transacoes <- as(transacoes_lista, "transactions")
# Resumo das transações
summary(transacoes)
# Mostrar as 10 primeiras transações
inspect(head(transacoes, 10))
# Gerar as Regras de Associação com o algoritmo Apriori
# Suporte mínimo = 10%
# Confiança mínima = 60%

regras <- apriori(
  transacoes,
  parameter = list(
    supp = 0.10,
    conf = 0.60,
    minlen = 2
  )
)
# Quantidade de regras encontradas
length(regras)
# Mostrar as regras encontradas
inspect(regras)
# Ordenar as regras pela confiança
regras_conf <- sort(regras, by = "confidence", decreasing = TRUE)

# Mostrar as 10 regras com maior confiança
inspect(head(regras_conf, 10))
# Ordenar as regras pelo Lift
regras_lift <- sort(regras, by = "lift", decreasing = TRUE)

# Mostrar as 10 regras com maior Lift
inspect(head(regras_lift, 10))
# Criar tabela com as regras e suas métricas
resultado <- data.frame(
  Regra = labels(regras_lift),
  Suporte = quality(regras_lift)$support,
  Confianca = quality(regras_lift)$confidence,
  Lift = quality(regras_lift)$lift
)

# Mostrar as 10 primeiras
head(resultado, 10)
View(resultado)
write.csv(
  resultado,
  "regras_musculacao.csv",
  row.names = FALSE
)
top10 <- head(resultado, 10)

print(
  top10,
  row.names = FALSE
)
View(top10)