-- =========================================================================
-- PROJETO: Análise de Faturamento e Desempenho de Metas (SQL Server)
-- AUTOR: Seu Nome
-- DESCRIÇÃO: Scripts para auditoria, inteligência de tempo e métricas comerciais.
-- =========================================================================

-- 1. Visão Geral dos Dados com Faturamento Linha a Linha
SELECT
    ID_Pedido,
    Data,
    Loja,
    Produto,
    Preco_Unitario,
    Qtd,
    Preco_Unitario * Qtd AS Faturamento
FROM analise_tech2;

-- 2. Ranking de Lojas por Faturamento e Volume de Pedidos
SELECT
    Loja,
    SUM(Preco_Unitario * Qtd) AS Faturamento,
    COUNT(*) AS Total_Pedidos
FROM analise_tech2
GROUP BY Loja
ORDER BY Faturamento DESC;

-- 3. Análise de Faturamento por Produto (Curva de Valor)
SELECT
    Produto,
    SUM(Preco_Unitario * Qtd) AS Faturamento
FROM analise_tech2
GROUP BY Produto
ORDER BY Faturamento ASC;

-- 4. Consolidado Mensal Histórico (Visão Simples)
SELECT
    YEAR(Data) AS Ano,
    MONTH(Data) AS Mes,
    SUM(Preco_Unitario * Qtd) AS Faturamento
FROM analise_tech2
GROUP BY YEAR(Data), MONTH(Data)
ORDER BY Faturamento ASC;

-- 5. Inteligência de Tempo Avançada: Variação Mês a Mês (Month-over-Month)
WITH int_mes AS (
    SELECT
        YEAR(Data) AS Ano,
        MONTH(Data) AS Mes,
        SUM(Preco_Unitario * Qtd) AS Faturamento
    FROM analise_tech2
    GROUP BY YEAR(Data), MONTH(Data)
), 
int_mes2 AS (
    SELECT
        Ano,
        Mes,
        Faturamento,
        LAG(Faturamento, 1) OVER (ORDER BY Ano, Mes) AS Faturamento_Anterior,
        SUM(Faturamento) OVER (ORDER BY Ano, Mes) AS Faturamento_Acumulado
    FROM int_mes
)
SELECT
    Ano,
    Mes,
    Faturamento,
    Faturamento_Anterior,
    CASE 
        WHEN Faturamento_Anterior IS NULL THEN 0.00
        ELSE ROUND(((Faturamento - Faturamento_Anterior) / Faturamento_Anterior) * 100, 2) 
    END AS Pct_Crescimento_MoM
FROM int_mes2
ORDER BY Ano, Mes;

-- 6. Análise de Performance: Cruzamento de Vendas vs Metas dos Gerentes
WITH meta_analise AS (
    SELECT 
        YEAR(t1.Data) AS Ano,
        MONTH(t1.Data) AS Mes,
        t2.Loja AS Loja,
        t2.Gerente AS Gerente,
        t2.Meta_Mensal AS Meta_Mensal,
        SUM(t1.Preco_Unitario * t1.Qtd) AS Faturamento
    FROM analise_tech2 AS t1
    INNER JOIN gerentes_lojas AS t2 ON t1.Loja = t2.Loja 
    WHERE YEAR(t1.Data) = 2024 AND MONTH(t1.Data) = 1
    GROUP BY 
        YEAR(t1.Data),
        MONTH(t1.Data),
        t2.Loja,
        t2.Gerente,
        t2.Meta_Mensal
)
SELECT
    Ano,
    Mes,
    Gerente,
    Meta_Mensal,
    Faturamento,
    CASE
        WHEN Faturamento > Meta_Mensal THEN 'Sim' 
        ELSE 'Não' 
    END AS Bateu_a_meta
FROM meta_analise
ORDER BY Faturamento DESC;
