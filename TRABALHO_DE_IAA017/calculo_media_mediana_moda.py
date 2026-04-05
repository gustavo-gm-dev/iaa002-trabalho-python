import pandas as pd

# Ler o arquivo Excel
df = pd.read_excel("Dados_Sneakers_World3.xlsx", sheet_name="Sales")

# Garantir que são números
df["Sales"] = pd.to_numeric(df["Sales"], errors="coerce")
df["Quantity"] = pd.to_numeric(df["Quantity"], errors="coerce")

# Remover nulos (caso tenha sobrado algo)
df = df.dropna(subset=["Sales", "Quantity"])

# Calcular medidas
resultados = {
    "Variável": ["Sales", "Quantity"],
    "Média": [
        df["Sales"].mean(),
        df["Quantity"].mean()
    ],
    "Mediana": [
        df["Sales"].median(),
        df["Quantity"].median()
    ],
    "Moda": [
        df["Sales"].mode()[0],
        df["Quantity"].mode()[0]
    ]
}

tabela = pd.DataFrame(resultados)

print("\nResultados:\n")
print(tabela)