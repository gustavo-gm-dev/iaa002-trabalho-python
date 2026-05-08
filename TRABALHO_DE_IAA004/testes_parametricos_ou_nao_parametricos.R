#################################################################
#            Trabalho: Comparação de Idades (Esposas x Maridos) #
#            Teste Não Paramétrico (Mann-Whitney / Wilcoxon)    #
#################################################################

# Carregando os pacotes necessarios (exatamente os usados em aula)
library("dplyr")
library("ggpubr")
library("rstatix")
library("DescTools")
library("tidyverse")

# 1. PREPARANDO OS DADOS
# ---------------------------------------------------------------
# Carrega a base de dados
load("C:/Users/Gustoso/Documents/UFPR - Conteudo/IAA002 - Linguagem de Programacao Aplicada/trabalho/iaa002-trabalho-python/TRABALHO_DE_IAA004/salarios.RData")

# criando uma coluna para quem é a pessoa e outra para a idade.
dat <- salarios %>%
  select(age, husage) %>%
  gather(key = "conjuge", value = "idade", age, husage) %>%
  convert_as_factor(conjuge)

# Vamos ver alguns registros dos dados organizados
head(dat, 3)


# 2. ESTATÍSTICAS DESCRITIVAS E INTERVALOS DE CONFIANÇA
# ---------------------------------------------------------------
# Calculando algumas estatisticas descritivas por grupo, 
# inclusive o intervalo de confianca das medianas, exigido na Obs 2.
descritiva <- dat %>% group_by(conjuge) %>% 
  summarise(n=n(), 
            mean=mean(idade, na.rm = TRUE), 
            sd=sd(idade, na.rm = TRUE),
            stderr=sd/sqrt(n),
            median=median(idade, na.rm = TRUE),
            min=min(idade, na.rm = TRUE), 
            max=max(idade, na.rm = TRUE),
            IQR=IQR(idade, na.rm = TRUE),
            LCLmed = MedianCI(idade, na.rm=TRUE)[2],
            UCLmed = MedianCI(idade, na.rm=TRUE)[3])

# Vamos visualizar a tabela descritiva no console
print(descritiva)
# Os intervalos de confianca inferiores sao LCLmed e superiores sao UCLmed.


# 3. TESTE DE NORMALIDADE (JUSTIFICATIVA DA OBS 1)
# ---------------------------------------------------------------
# Como N > 5000, aplicamos Kolmogorov-Smirnov para justificar 
# o teste nao parametrico.
ks.test(salarios$age, "pnorm", mean(salarios$age, na.rm=TRUE), sd(salarios$age, na.rm=TRUE))
ks.test(salarios$husage, "pnorm", mean(salarios$husage, na.rm=TRUE), sd(salarios$husage, na.rm=TRUE))
# P-valor < 0.05 indica que os dados nao sao normais.


# 4. TESTE DE HIPÓTESES (MANN-WHITNEY / WILCOXON)
# ---------------------------------------------------------------
# H0: nao existe diferenca entre as medianas dos diferentes grupos
# Ha: existe diferenca entre as medianas dos diferentes grupos

# Usaremos o teste de postos de Wilcoxon para amostras independentes
teste_wilcoxon <- wilcox.test(idade ~ conjuge, data = dat, conf.int = TRUE)
print(teste_wilcoxon)

# Como o p-value < 0.05, rejeitamos H0. 
# Existe diferenca significativa entre as idades de maridos e esposas.


# 5. VISUALIZAÇÃO DOS DADOS (BOX-PLOT)
# ---------------------------------------------------------------
# Vamos vizualizar algumas observacoes e criar o box-plot,
# mantendo o padrao de cores e layout ensinado nas Secoes 5.4 e 5.5
grafico_sino <- ggdensity(dat, x = "idade",
          add = "mean", rug = TRUE,
          color = "conjuge", fill = "conjuge",
          palette = c("#00AFBB", "#FC4E07"),
          xlab = "Idade (anos)", ylab = "Densidade",
          title = "Curva de Densidade das Idades")

print(grafico_sino)

#################################################################