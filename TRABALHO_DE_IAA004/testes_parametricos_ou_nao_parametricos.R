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

# View(dat)

# 2. ESTATÍSTICAS DESCRITIVAS E INTERVALOS DE CONFIANÇA
# ---------------------------------------------------------------
# Calculando algumas estatisticas descritivas por grupo, 
# inclusive o intervalo de confianca das medianas, exigido na Obs 2.
descritiva <- dat %>% 
  group_by(conjuge) %>% 
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

# 3. TESTE DE HIPÓTESES (MANN-WHITNEY / WILCOXON)
# ---------------------------------------------------------------
# H0: nao existe diferenca entre as medianas dos diferentes grupos
# Ha: existe diferenca entre as medianas dos diferentes grupos

# Usaremos o teste de postos de Wilcoxon para amostras independentes
teste_wilcoxon <- wilcox.test(idade ~ conjuge, data = dat, conf.int = TRUE)

print(teste_wilcoxon)

# Como o p-value < 0.05, rejeitamos H0. 
# Existe diferenca significativa entre as idades de maridos e esposas.


# 4. VISUALIZAÇÃO DOS DADOS (BOX-PLOT)
# ---------------------------------------------------------------
# Vamos vizualizar algumas observacoes e criar o box-plot,
# mantendo o padrao de cores e layout ensinado nas Secoes 5.4 e 5.5
grafico <- ggboxplot(dat, x="conjuge", y="idade", 
          color = "conjuge", palette = c("#00AFBB", "#FC4E07"),
          ylab = "Idade (anos)", xlab = "Cônjuge",
          title = "Comparação das Medianas: Esposas (age) vs Maridos (husage)")

# Exibe o grafico
print(grafico)