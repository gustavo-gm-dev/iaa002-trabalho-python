#################################################################
#            Trabalho: Comparação de Idades (Esposas x Maridos) #
#            Teste Não Paramétrico (Mann-Whitney / Wilcoxon)    #
#################################################################

# Carregando os pacotes necessarios
library("dplyr")
library("ggpubr")
library("rstatix")
library("DescTools")
library("tidyverse")

# 1. PREPARANDO OS DADOS
# ---------------------------------------------------------------
# Carrega a base de dados
load("C:/Users/Gustoso/Documents/UFPR - Conteudo/IAA002 - Linguagem de Programacao Aplicada/trabalho/iaa002-trabalho-python/TRABALHO_DE_IAA004/salarios.RData")

# Criando uma coluna para quem é a pessoa e outra para a idade.
dat <- salarios %>%
  select(age, husage) %>%
  gather(key = "conjuge", value = "idade", age, husage) %>%
  convert_as_factor(conjuge)


# 2. ESTATÍSTICAS DESCRITIVAS E INTERVALOS DE CONFIANÇA
# ---------------------------------------------------------------
# Calculando estatisticas descritivas e o IC das medianas (Obs 2)
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

print(descritiva)


# 3. JUSTIFICATIVA VISUAL (CURVA DE SINO)
# ---------------------------------------------------------------
# Como removemos o teste matematico, este grafico prova visualmente
# que os dados sao assimetricos (trazendo seguranca para a escolha)
grafico_sino <- ggdensity(dat, x = "idade",
          add = "mean", rug = TRUE,
          color = "conjuge", fill = "conjuge",
          palette = c("#00AFBB", "#FC4E07"),
          xlab = "Idade (anos)", ylab = "Densidade",
          title = "Curva de Densidade: Prova Visual da Assimetria")

print(grafico_sino)


# 4. TESTE DE HIPÓTESES (MANN-WHITNEY / WILCOXON)
# ---------------------------------------------------------------
# H0: nao existe diferenca entre as medianas dos diferentes grupos
# Ha: existe diferenca entre as medianas dos diferentes grupos

teste_wilcoxon <- wilcox.test(idade ~ conjuge, data = dat, conf.int = TRUE)
print(teste_wilcoxon)


# 5. VISUALIZAÇÃO DOS RESULTADOS (BOX-PLOT)
# ---------------------------------------------------------------
grafico_box <- ggboxplot(dat, x="conjuge", y="idade", 
          color = "conjuge", palette = c("#00AFBB", "#FC4E07"),
          ylab = "Idade (anos)", xlab = "Cônjuge",
          title = "Comparação das Medianas: Esposas (age) vs Maridos (husage)")

print(grafico_box)