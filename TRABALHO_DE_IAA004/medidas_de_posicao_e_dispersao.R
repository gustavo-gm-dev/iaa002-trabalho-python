##### IAA004 - ESTATÍSTICA APLICADA #####
#                                       #
#             TRABALHO FINAL            #
#                                       #
#########################################

# Carregando a Base
load("C:/Users/Gustoso/Documents/UFPR - Conteudo/IAA002 - Linguagem de Programacao Aplicada/trabalho/iaa002-trabalho-python/TRABALHO_DE_IAA004/salarios.RData")

#########################################

# 2a) Calcular a média, mediana e moda das variáveis “age” (idade da esposa) e “husage” 
#    (idade do marido) e comparar os resultados

# Idade da Esposa:

    # Média
    mediaesposa <- mean(salarios$age)
    # A média da idade das esposas é 39.428 anos

    # Mediana
    medianaesposa <- median(salarios$age)
    # A mediana da idade das esposas é 39 anos
    
    # Moda
    modaesposa <- subset(table(salarios$age), 
           table(salarios$age) == max(table(salarios$age)))
    # A moda da idade das esposas é 37 anos com 217 ocorrências
    
# Idade do Marido
    
    # Média
    mediamarido <- mean(salarios$husage)
    # A média da idade dos maridos é 42.453 anos
    
    # Mediana
    medianamarido <- median(salarios$husage)
    # A mediana da idade dos maridos é 41 anos
    
    # Moda
    modamarido <- subset(table(salarios$husage), 
           table(salarios$husage) == max(table(salarios$husage)))
    # A moda da idade dos maridos é 44 anos com 201 ocorrências
    
# Comparação
    
    # Média
    ((mediamarido / mediaesposa)-1)*100
    # A média da idade dos maridos é 7.67% maior que a média da idade das esposas
    
    # Mediana
    (medianamarido / medianaesposa -1)*100
    # A mediana da idade dos maridos é 5% maior que a mediana da idade das esposas
    
    # Moda
    (as.numeric(names(modamarido)) / as.numeric(names(modaesposa)) - 1)*100
    # A moda da idade dos maridos é 19% maior que a moda da idade das esposas.
    # Obs: A função names retorna o rótulo do subset e a função as.numeric transforma ele em numérico
    
#########################################

# 2b) Calcular a variância, desvio padrão e coeficiente de variação das variáveis “age”.
#   (idade da esposa) e “husage” (idade do marido) e comparar os resultados
    
# Idade da Esposa
    
    # Variância
    varianciaesposa <- var(salarios$age)
    # A variância da idade das esposas é de 99.75
    
    # Desvio Padrão
    desvioesposa <- sd(salarios$age)
    # O desvio padrão da idade das esposas é de 9.99
    
    # Coeficiente de Variação
    coeficienteesposa <- (desvioesposa/mediaesposa) * 100
    coeficienteesposa
    # O coeficiente de variação da idade das esposas é de 25%
    
# Idade do Marido

    # Variância
    varianciamarido <- var(salarios$husage)
    varianciamarido
    # A variância da idade dos maridos é de 126.07
    
    # Desvio Padrão
    desviomarido <- sd(salarios$husage)
    desviomarido
    # O desvio padrão da idade dos maridos é de 11.23
    
    # Coeficiente de Variação
    coeficientemarido <- (desviomarido/mediamarido) * 100
    coeficientemarido
    # O coeficiente de variação da idade dos maridos é de 26%
    
# Comparação
    
    # Variância
    (varianciamarido / varianciaesposa - 1) * 100
    # A variância da idade dos maridos é 26% maior que a variância da idade das esposas.
    
    # Desvio Padrão
    (desviomarido / desvioesposa - 1) * 100
    # O desvio padrão da idade dos maridos é 12.42% maior que o desvio padrão da idade das esposas
    
    # Coeficiente de Variação
    # Como, tanto o coeficiente de variação da idade dos maridos, quanto o coeficiente de variação da idade das esposas, fica entre 15 e 30%,
    # considera-se que as idades tenham média dispersão.