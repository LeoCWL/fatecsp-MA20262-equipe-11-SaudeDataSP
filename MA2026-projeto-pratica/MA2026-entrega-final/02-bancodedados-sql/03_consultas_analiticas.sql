-- ============================================================================
-- PROJETO: SaúdeData SP — Infraestrutura de Saúde nos Municípios Paulistas
-- DISCIPLINA: Microinformática Aplicada (ILP590) — Fatec São Paulo (2º/2026)
-- ARQUIVO: 03_consultas_analiticas.sql (Consultas Analíticas DML e Auditoria)
-- ============================================================================

PRAGMA foreign_keys = ON;

-- ----------------------------------------------------------------------------
-- CONSULTA 1: Auditoria de Integridade e Totais de Controle (Estado de SP)
-- Objetivo: Conferir se o banco relacional reproduz 100% dos totais auditados
-- em verificacao_resultados.json e no Relatório Parcial.
-- ----------------------------------------------------------------------------
SELECT
    total_municipios,
    total_cnes_cadastrados,
    total_cnes_ativos,
    total_cnes_desativados,
    total_ubs_fonte,
    total_ubs_ativas,
    total_ubs_divergentes,
    total_estab_com_leitos,
    total_leitos_existentes,
    total_leitos_sus,
    proporcao_leitos_sus_pct
FROM vw_resumo_estadual;

-- ----------------------------------------------------------------------------
-- CONSULTA 2: Comparativo Capital (São Paulo) vs. Interior (644 Municípios)
-- Objetivo: Medir a concentração da infraestrutura de saúde na capital paulista.
-- ----------------------------------------------------------------------------
SELECT
    regiao_comparativa,
    qtd_municipios,
    cnes_ativos,
    ROUND(cnes_ativos * 100.0 / (SELECT SUM(cnes_ativos) FROM vw_consolidado_municipal), 2) AS pct_cnes_ativos_sp,
    ubs_fonte,
    ubs_ativas,
    estab_com_leitos,
    leitos_existentes,
    ROUND(leitos_existentes * 100.0 / (SELECT SUM(leitos_existentes) FROM vw_consolidado_municipal), 2) AS pct_leitos_exist_sp,
    leitos_sus,
    ROUND(leitos_sus * 100.0 / (SELECT SUM(leitos_sus) FROM vw_consolidado_municipal), 2) AS pct_leitos_sus_sp,
    proporcao_leitos_sus_pct
FROM vw_comparativo_capital_interior
ORDER BY leitos_existentes DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 3: Top 15 Municípios por Leitos Existentes e Proporção de Leitos SUS
-- Objetivo: Identificar os principais polos hospitalares do Estado de São Paulo.
-- ----------------------------------------------------------------------------
SELECT
    RANK() OVER (ORDER BY leitos_existentes DESC) AS ranking_leitos,
    ibge6,
    municipio,
    estab_com_leitos,
    leitos_existentes,
    leitos_sus,
    leitos_nao_sus,
    proporcao_leitos_sus_pct
FROM vw_consolidado_municipal
ORDER BY leitos_existentes DESC
LIMIT 15;

-- ----------------------------------------------------------------------------
-- CONSULTA 4: Distribuição de Leitos por Natureza Jurídica (Setembro/2026)
-- Objetivo: Avaliar o peso das redes Pública, Filantrópica e Privada no SUS.
-- ----------------------------------------------------------------------------
SELECT
    natureza_juridica,
    COUNT(*) AS qtd_estabelecimentos,
    SUM(leitos_existentes) AS leitos_existentes,
    SUM(leitos_sus) AS leitos_sus,
    SUM(leitos_existentes - leitos_sus) AS leitos_nao_sus,
    ROUND(SUM(leitos_sus) * 100.0 / NULLIF(SUM(leitos_existentes), 0), 2) AS proporcao_leitos_sus_pct,
    ROUND(SUM(leitos_sus) * 100.0 / (SELECT SUM(leitos_sus) FROM fato_leitos), 2) AS participacao_no_sus_sp_pct
FROM fato_leitos
WHERE competencia = '202609'
GROUP BY natureza_juridica
ORDER BY leitos_existentes DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 5: Distribuição de Leitos por Tipo de Estabelecimento
-- Objetivo: Diferenciar hospitais gerais, especializados, prontos-socorros e unidades mistas.
-- ----------------------------------------------------------------------------
SELECT
    tipo_estabelecimento,
    COUNT(*) AS qtd_estabelecimentos,
    SUM(leitos_existentes) AS leitos_existentes,
    SUM(leitos_sus) AS leitos_sus,
    ROUND(SUM(leitos_sus) * 100.0 / NULLIF(SUM(leitos_existentes), 0), 2) AS proporcao_leitos_sus_pct
FROM fato_leitos
WHERE competencia = '202609'
GROUP BY tipo_estabelecimento
ORDER BY leitos_existentes DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 6: Auditoria de Divergência entre Base UBS e CNES Ativo (510 casos)
-- Objetivo: Listar os 15 municípios com maior número de UBS vinculadas a CNES desativado.
-- ----------------------------------------------------------------------------
SELECT
    m.ibge6,
    m.municipio,
    fm.ubs_fonte,
    fm.ubs_ativas,
    fm.ubs_divergentes,
    ROUND(fm.ubs_ativas * 100.0 / NULLIF(fm.ubs_fonte, 0), 2) AS pct_ubs_compativeis
FROM dim_municipio m
INNER JOIN fato_municipal fm ON fm.ibge6 = m.ibge6
WHERE fm.ubs_divergentes > 0
ORDER BY fm.ubs_divergentes DESC, fm.ubs_fonte DESC
LIMIT 15;

-- ----------------------------------------------------------------------------
-- CONSULTA 7: Municípios sem Registro de Leitos na Competência 202609
-- Objetivo: Quantificar municípios que dependem de polos regionais para internação,
-- mantendo atenção básica via UBS.
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*) AS municipios_sem_leitos_registrados,
    SUM(cnes_ativos) AS total_cnes_ativos_nesses_municipios,
    SUM(ubs_ativas) AS total_ubs_ativas_nesses_municipios,
    ROUND(AVG(ubs_ativas), 2) AS media_ubs_ativas_por_municipio
FROM vw_consolidado_municipal
WHERE estab_com_leitos = 0;

-- ----------------------------------------------------------------------------
-- CONSULTA 8: Classificação de Porte de Infraestrutura Hospitalar Municipal (CTE + CASE)
-- Objetivo: Segmentar os 645 municípios paulistas por capacidade instalada de leitos.
-- ----------------------------------------------------------------------------
WITH perfil_municipal AS (
    SELECT
        ibge6,
        municipio,
        cnes_ativos,
        ubs_ativas,
        leitos_existentes,
        leitos_sus,
        CASE
            WHEN leitos_existentes = 0 THEN '1. Sem registro de leitos (202609)'
            WHEN leitos_existentes BETWEEN 1 AND 50 THEN '2. Pequeno porte (1 a 50 leitos)'
            WHEN leitos_existentes BETWEEN 51 AND 250 THEN '3. Médio porte (51 a 250 leitos)'
            WHEN leitos_existentes BETWEEN 251 AND 1000 THEN '4. Grande porte (251 a 1.000 leitos)'
            ELSE '5. Polo de alta complexidade (> 1.000 leitos)'
        END AS faixa_infraestrutura
    FROM vw_consolidado_municipal
)
SELECT
    faixa_infraestrutura,
    COUNT(*) AS qtd_municipios,
    SUM(cnes_ativos) AS cnes_ativos,
    SUM(ubs_ativas) AS ubs_ativas,
    SUM(leitos_existentes) AS leitos_existentes,
    SUM(leitos_sus) AS leitos_sus,
    ROUND(SUM(leitos_sus) * 100.0 / NULLIF(SUM(leitos_existentes), 0), 2) AS proporcao_leitos_sus_pct
FROM perfil_municipal
GROUP BY faixa_infraestrutura
ORDER BY faixa_infraestrutura;

-- ----------------------------------------------------------------------------
-- CONSULTA 9: Top 15 Maiores Hospitais do Estado de SP em Leitos SUS (Competência 202609)
-- Objetivo: Identificar os estabelecimentos individuais com maior oferta de leitos SUS.
-- ----------------------------------------------------------------------------
SELECT
    fl.cnes,
    fl.estabelecimento,
    m.municipio,
    fl.tipo_estabelecimento,
    fl.natureza_juridica,
    fl.leitos_existentes,
    fl.leitos_sus,
    ROUND(fl.leitos_sus * 100.0 / NULLIF(fl.leitos_existentes, 0), 2) AS proporcao_sus_pct
FROM fato_leitos fl
INNER JOIN dim_municipio m ON m.ibge6 = fl.ibge6
WHERE fl.competencia = '202609'
ORDER BY fl.leitos_sus DESC, fl.leitos_existentes DESC
LIMIT 15;

-- ----------------------------------------------------------------------------
-- CONSULTA 10: Consulta sobre Tabela Normalizada (fato_indicadores_longos)
-- Objetivo: Demonstrar agregação via formato longo (espelhando 02_Indicadores_Longos.pq).
-- ----------------------------------------------------------------------------
SELECT
    indicador,
    COUNT(*) AS municipios_avaliados,
    SUM(valor) AS soma_estadual,
    ROUND(AVG(valor), 2) AS media_municipal,
    MAX(valor) AS maximo_municipal
FROM fato_indicadores_longos
GROUP BY indicador
ORDER BY soma_estadual DESC;
