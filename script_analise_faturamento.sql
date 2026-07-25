-- =========================================================================
-- PROJETO: Pipeline de Dados - Engenharia, Tratamento e Análise de Vendas
-- AUTOR: Felipe Souza
-- DESCRIÇÃO: Script completo contendo alteração de tipos, limpeza de texto,
--            deduplicação de registros e consultas analíticas de negócio.
-- =========================================================================

-- -------------------------------------------------------------------------
-- ETAPA 1: ADEQUAÇÃO DE TIPAGEM E CARGA INICIAL
-- -------------------------------------------------------------------------

-- Ajustando os tipos de dados na tabela original para garantir consistência
ALTER TABLE vendas_tech ALTER COLUMN Data DATE;
ALTER TABLE vendas_tech ALTER COLUMN Preco_Unitario MONEY;
ALTER TABLE vendas_tech ALTER COLUMN Qtd INT;

-- Criando a tabela de staging para manipulação e limpeza
SELECT
    ID_Pedido,
    Data,
    Loja,
    Produto,
    Preco_Unitario,
    Qtd,
    Cliente,
    Data_Base
INTO analise_tech
FROM vendas_tech;

-- -------------------------------------------------------------------------
-- ETAPA 2: TRATAMENTO E LIMPEZA DE DADOS (DATA CLEANING)
-- -------------------------------------------------------------------------

-- 1. Remoção de colunas irrelevantes para o negócio
ALTER TABLE analise_tech DROP COLUMN Data_Base;

-- 2. Tratamento de valores vazios/nulos na identificação das lojas
UPDATE analise_tech
SET Loja = 'Online'
WHERE Loja = '' OR Loja IS NULL;

-- 3. Correção de espaçamentos e erros de encoding (Caracteres Especiais)
UPDATE analise_tech
SET Loja = 'São Paulo'
WHERE Loja = '  SÃ£o Paulo ';

-- 4. Padronização de caixa de texto (Case Standardization)
UPDATE analise_tech
SET Loja = 'Rio de Janeiro' -- Correção ortográfica aplicada aqui
WHERE Loja = 'RIO DE JANEIRO';

-- -------------------------------------------------------------------------
-- ETAPA 3: TRATAMENTO DE REGISTROS DUPLICADOS
-- -------------------------------------------------------------------------

-- Auditoria preventiva para mapear volume de duplicatas
SELECT 
    ID_Pedido,
    Preco_Unitario,
    Qtd,
    Cliente,
    COUNT(*) AS Total_Repeticoes
FROM analise_tech
GROUP BY ID_Pedido, Preco_Unitario, Qtd, Cliente
HAVING COUNT(*) > 1;

-- Criação da tabela final consolidada eliminando as linhas duplicadas
SELECT DISTINCT
    ID_Pedido,
    Data,
    Loja,
    Produto,
    Preco_Unitario,
    Qtd,
    Cliente
INTO analise_tech2
FROM analise_tech;

-- -------------------------------------------------------------------------
-- ETAPA 4: QUERIES ANALÍTICAS E INTELIGÊNCIA DE NEGÓCIO
-- -------------------------------------------------------------------------

-- 1. Visão Geral com Cálculo de Faturamento de Linha
SELECT
    ID_Pedido,
    Data,
    Loja,
    Produto,
    Preco_Unitario,
    Qtd,
    (Preco_Unitario * Qtd) AS Faturamento
FROM analise_tech2;

-- 2. Desempenho e Ranking de Lojas
SELECT
    Loja,
    SUM(Preco_Unitario * Qtd) AS Faturamento,
    COUNT(*) AS Total_Pedidos
FROM analise_tech2
GROUP BY Loja
ORDER BY Faturamento DESC;

-- 3. Desempenho e Ranking de Produtos
SELECT
    Produto,
    SUM(Preco_Unitario * Qtd) AS Faturamento
FROM analise_tech2
GROUP BY Produto
ORDER BY Faturamento ASC;

-- 4. Evolução Cronológica Mensal Básica
SELECT
    YEAR(Data) AS Ano,
    MONTH(Data) AS Mes,
    SUM(Preco_Unitario * Qtd) AS Faturamento
FROM analise_tech2
GROUP BY YEAR(Data), MONTH(Data)
ORDER BY Faturamento ASC;

-- 5. Inteligência de Tempo Avançada: Crescimento Mês a Mês (Month-over-Month)
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

-- 6. Análise Comercial de Metas: Realizado vs Planejado por Gerente
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

