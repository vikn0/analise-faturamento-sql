# 📊 Pipeline de Dados: Engenharia, Tratamento e Análise de Vendas (SQL Server)

Este projeto apresenta um fluxo de trabalho end-to-end de engenharia e análise de dados utilizando **SQL Server (T-SQL)**. O script cobre desde a reestruturação e tipagem da base bruta, passando por etapas críticas de limpeza, normalização de texto e deduplicação de registros, até a entrega de consultas de Inteligência de Negócio (BI).

## 🚀 Habilidades Técnicas Demonstradas
* **Data Cleaning & Manipulação:** `ALTER TABLE`, `UPDATE`, tratamento de valores nulos/vazios e correção de encoding de caracteres.
* **Deduplicação de Registros:** Técnicas de identificação (`GROUP BY` + `HAVING`) e eliminação de redundância (`DISTINCT` para tabela final).
* **Análise Avançada e BI:** Funções agregadoras, expressões lógicas (`CASE WHEN`), Expressões de Tabela Comuns (`CTEs`) e funções de janela analíticas (`LAG`, `OVER`).

## 📂 Arquitetura do Script SQL

O pipeline está estruturado nas seguintes fases organizadas:

1. **Adequação de Tipagem:** Conversão de strings brutas para formatos nativos adequados (`DATE`, `MONEY`, `INT`).
2. **Tratamento de Dados:** 
   * Eliminação de campos obsoletos (`Data_Base`).
   * Preenchimento de lacunas de dados vazios atribuindo canais padrão (`Online`).
   * Correção ortográfica e de corrupção de caracteres de texto (`SÃ£o Paulo` para `São Paulo`).
3. **Mapeamento e Remoção de Duplicatas:** Processo de auditoria para medir redundâncias e isolamento de chaves únicas.
4. **Queries Estratégicas:** Consultas de faturamento por filial, faturamento por produto e curva de sazonalidade.
5. **Inteligência de Tempo (MoM):** Cálculo automatizado do ritmo de crescimento percentual das vendas mês a mês.
6. **Métricas de Performance Comercial:** Cruzamento de tabelas via `INNER JOIN` para validar dinamicamente quais gerentes atingiram as metas corporativas.

## 🏁 Como Executar
1. Certifique-se de possuir as tabelas iniciais `vendas_tech` e `gerentes_lojas` no seu banco de dados.
2. Execute o arquivo `script_pipeline_vendas.sql` em seu ambiente de gerência (SSMS).
