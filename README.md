# 📊 Análise de Faturamento e Performance de Metas em SQL

Este repositório contém uma sequência de consultas analíticas desenvolvidas em **SQL Server (T-SQL)** para extrair insights estratégicos de uma base de dados de vendas. O projeto simula demandas reais de Business Intelligence (BI), cobrindo desde agrupamentos básicos até análises avançadas de tempo e performance comercial.

## 🚀 Tecnologias Utilizadas
* **Banco de Dados:** SQL Server
* **Linguagem:** T-SQL (Transact-SQL)
* **Conceitos Aplicados:** Funções de Agregação (`SUM`, `COUNT`), Expressões Condicionais (`CASE WHEN`), CTEs (`WITH`) e Funções de Janela (`LAG`, `OVER`).

## 📊 Estrutura das Análises

O script principal está dividido em 6 etapas estratégicas:

1. **Visão Geral dos Dados:** Extração analítica do faturamento calculado linha a linha.
2. **Ranking de Lojas:** Identificação de filiais líderes em faturamento e volume absoluto de pedidos.
3. **Desempenho de Produtos:** Análise focada na representatividade financeira de cada produto.
4. **Visão Mensal Histórica:** Agrupamento cronológico básico para entender a sazonalidade de vendas.
5. **Inteligência de Tempo (MoM):** Utilização de `CTE` e da função de janela `LAG` para calcular a variação percentual de crescimento mês a mês de forma dinâmica.
6. **Auditoria de Metas:** Uso de `INNER JOIN` para cruzar tabelas de vendas e cadastro de gerentes, avaliando de forma condicional se a meta mensal de janeiro/2024 foi atingida.

