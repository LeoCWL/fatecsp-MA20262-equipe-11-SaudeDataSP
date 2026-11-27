-- ============================================================================
-- PROJETO: SaúdeData SP — Infraestrutura de Saúde nos Municípios Paulistas
-- DISCIPLINA: Microinformática Aplicada (ILP590) — Fatec São Paulo (2º/2026)
-- DOCENTE: Prof. Veríssimo
-- ARQUIVO: 01_ddl_schema.sql (Modelagem Relacional Star Schema + Views)
-- COMPATIBILIDADE: SQLite 3.x e PostgreSQL 14+ (SQL Padrão ANSI)
-- ============================================================================

-- Em SQLite, habilita validação rigorosa de chaves estrangeiras:
PRAGMA foreign_keys = ON;

-- Remoção segura para recriação limpa (ordem inversa de dependência)
DROP VIEW IF EXISTS vw_comparativo_capital_interior;
DROP VIEW IF EXISTS vw_leitos_por_natureza_tipo;
DROP VIEW IF EXISTS vw_resumo_estadual;
DROP VIEW IF EXISTS vw_consolidado_municipal;

DROP TABLE IF EXISTS fato_indicadores_longos;
DROP TABLE IF EXISTS fato_leitos;
DROP TABLE IF EXISTS fato_municipal;
DROP TABLE IF EXISTS dim_municipio;

-- ============================================================================
-- 1. TABELA DIMENSÃO: dim_municipio (645 municípios do Estado de São Paulo)
-- Fonte: Tabela de Municípios da Receita Federal / IBGE
-- ============================================================================
CREATE TABLE dim_municipio (
    ibge6       CHAR(6)      NOT NULL,
    ibge7       CHAR(7)      NOT NULL,
    municipio   VARCHAR(100) NOT NULL,
    uf          CHAR(2)      NOT NULL DEFAULT 'SP',
    is_capital  SMALLINT     NOT NULL DEFAULT 0,
    CONSTRAINT pk_dim_municipio PRIMARY KEY (ibge6),
    CONSTRAINT uq_dim_municipio_ibge7 UNIQUE (ibge7),
    CONSTRAINT chk_dim_municipio_uf CHECK (uf = 'SP'),
    CONSTRAINT chk_dim_municipio_capital CHECK (is_capital IN (0, 1))
);

CREATE INDEX idx_dim_municipio_nome ON dim_municipio (municipio);

-- ============================================================================
-- 2. TABELA FATO: fato_municipal (Granularidade: 1 linha por município)
-- Fontes: CNES Estabelecimentos e Relação de UBS (retrato divulgado em 07/11/2026)
-- ============================================================================
CREATE TABLE fato_municipal (
    ibge6             CHAR(6)     NOT NULL,
    competencia_cnes  VARCHAR(10) NOT NULL DEFAULT '2026-11',
    cnes_cadastrados  INTEGER     NOT NULL,
    cnes_ativos       INTEGER     NOT NULL,
    cnes_desativados  INTEGER     NOT NULL,
    ubs_fonte         INTEGER     NOT NULL,
    ubs_ativas        INTEGER     NOT NULL,
    ubs_divergentes   INTEGER     NOT NULL,
    CONSTRAINT pk_fato_municipal PRIMARY KEY (ibge6),
    CONSTRAINT fk_fatomun_municipio FOREIGN KEY (ibge6)
        REFERENCES dim_municipio (ibge6)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_fatomun_nao_negativo CHECK (
        cnes_cadastrados >= 0 AND
        cnes_ativos >= 0 AND
        cnes_desativados >= 0 AND
        ubs_fonte >= 0 AND
        ubs_ativas >= 0 AND
        ubs_divergentes >= 0
    ),
    CONSTRAINT chk_fatomun_soma_cnes CHECK (cnes_cadastrados = cnes_ativos + cnes_desativados),
    CONSTRAINT chk_fatomun_ubs_consistencia CHECK (ubs_ativas <= ubs_fonte AND ubs_divergentes = ubs_fonte - ubs_ativas)
);

-- ============================================================================
-- 3. TABELA FATO: fato_leitos (Granularidade: 1 linha por CNES e competência)
-- Fonte: Hospitais e Leitos — Ministério da Saúde (Competência 202609)
-- ============================================================================
CREATE TABLE fato_leitos (
    cnes                  CHAR(7)      NOT NULL,
    competencia           CHAR(6)      NOT NULL DEFAULT '202609',
    ibge6                 CHAR(6)      NOT NULL,
    municipio_origem      VARCHAR(100) NOT NULL,
    estabelecimento       VARCHAR(200) NOT NULL,
    tipo_estabelecimento  VARCHAR(80)  NOT NULL,
    natureza_juridica     VARCHAR(60)  NOT NULL,
    leitos_existentes     INTEGER      NOT NULL,
    leitos_sus            INTEGER      NOT NULL,
    motivo_desabilitacao  VARCHAR(100) NULL,
    CONSTRAINT pk_fato_leitos PRIMARY KEY (cnes, competencia),
    CONSTRAINT fk_fatoleitos_municipio FOREIGN KEY (ibge6)
        REFERENCES dim_municipio (ibge6)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_fatoleitos_valores CHECK (
        leitos_existentes >= 0 AND
        leitos_sus >= 0 AND
        leitos_sus <= leitos_existentes
    )
);

CREATE INDEX idx_fato_leitos_ibge6 ON fato_leitos (ibge6);
CREATE INDEX idx_fato_leitos_natureza ON fato_leitos (natureza_juridica);
CREATE INDEX idx_fato_leitos_tipo ON fato_leitos (tipo_estabelecimento);

-- ============================================================================
-- 4. TABELA FATO NORMALIZADA: fato_indicadores_longos (Formato Longo / Unpivot)
-- Espelha a consulta M 02_Indicadores_Longos.pq (645 municípios x 8 indicadores)
-- ============================================================================
CREATE TABLE fato_indicadores_longos (
    ibge6      CHAR(6)     NOT NULL,
    indicador  VARCHAR(40) NOT NULL,
    valor      INTEGER     NOT NULL,
    CONSTRAINT pk_fato_indicadores_longos PRIMARY KEY (ibge6, indicador),
    CONSTRAINT fk_indlong_municipio FOREIGN KEY (ibge6)
        REFERENCES dim_municipio (ibge6)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT chk_indlong_valor CHECK (valor >= 0)
);

CREATE INDEX idx_ind_longo_indicador ON fato_indicadores_longos (indicador);

-- ============================================================================
-- 5. VIEWS ANALÍTICAS (Camada Semântica SQL)
-- ============================================================================

-- View 1: Consolidação Municipal Completa (645 municípios)
CREATE VIEW vw_consolidado_municipal AS
SELECT
    m.ibge6,
    m.ibge7,
    m.municipio,
    CASE WHEN m.is_capital = 1 THEN 'Capital' ELSE 'Interior' END AS regiao_comparativa,
    fm.cnes_cadastrados,
    fm.cnes_ativos,
    fm.cnes_desativados,
    ROUND(fm.cnes_ativos * 100.0 / NULLIF(fm.cnes_cadastrados, 0), 2) AS pct_cnes_ativos,
    fm.ubs_fonte,
    fm.ubs_ativas,
    fm.ubs_divergentes,
    ROUND(fm.ubs_ativas * 100.0 / NULLIF(fm.ubs_fonte, 0), 2) AS pct_ubs_compativeis,
    COALESCE(fl.estab_com_leitos, 0) AS estab_com_leitos,
    COALESCE(fl.leitos_existentes, 0) AS leitos_existentes,
    COALESCE(fl.leitos_sus, 0) AS leitos_sus,
    COALESCE(fl.leitos_existentes - fl.leitos_sus, 0) AS leitos_nao_sus,
    ROUND(COALESCE(fl.leitos_sus, 0) * 100.0 / NULLIF(COALESCE(fl.leitos_existentes, 0), 0), 2) AS proporcao_leitos_sus_pct
FROM dim_municipio m
INNER JOIN fato_municipal fm ON fm.ibge6 = m.ibge6
LEFT JOIN (
    SELECT
        ibge6,
        COUNT(*) AS estab_com_leitos,
        SUM(leitos_existentes) AS leitos_existentes,
        SUM(leitos_sus) AS leitos_sus
    FROM fato_leitos
    WHERE competencia = '202609'
    GROUP BY ibge6
) fl ON fl.ibge6 = m.ibge6;

-- View 2: Resumo Consolidado do Estado de São Paulo (KPIs Globais)
CREATE VIEW vw_resumo_estadual AS
SELECT
    COUNT(*) AS total_municipios,
    SUM(cnes_cadastrados) AS total_cnes_cadastrados,
    SUM(cnes_ativos) AS total_cnes_ativos,
    SUM(cnes_desativados) AS total_cnes_desativados,
    SUM(ubs_fonte) AS total_ubs_fonte,
    SUM(ubs_ativas) AS total_ubs_ativas,
    SUM(ubs_divergentes) AS total_ubs_divergentes,
    SUM(estab_com_leitos) AS total_estab_com_leitos,
    SUM(leitos_existentes) AS total_leitos_existentes,
    SUM(leitos_sus) AS total_leitos_sus,
    ROUND(SUM(leitos_sus) * 100.0 / NULLIF(SUM(leitos_existentes), 0), 2) AS proporcao_leitos_sus_pct
FROM vw_consolidado_municipal;

-- View 3: Distribuição de Leitos por Natureza Jurídica e Tipo de Estabelecimento
CREATE VIEW vw_leitos_por_natureza_tipo AS
SELECT
    natureza_juridica,
    tipo_estabelecimento,
    COUNT(*) AS qtd_estabelecimentos,
    SUM(leitos_existentes) AS leitos_existentes,
    SUM(leitos_sus) AS leitos_sus,
    SUM(leitos_existentes - leitos_sus) AS leitos_nao_sus,
    ROUND(SUM(leitos_sus) * 100.0 / NULLIF(SUM(leitos_existentes), 0), 2) AS proporcao_leitos_sus_pct
FROM fato_leitos
WHERE competencia = '202609'
GROUP BY natureza_juridica, tipo_estabelecimento;

-- View 4: Comparativo Capital (São Paulo) vs. Interior (644 Municípios)
CREATE VIEW vw_comparativo_capital_interior AS
SELECT
    regiao_comparativa,
    COUNT(*) AS qtd_municipios,
    SUM(cnes_ativos) AS cnes_ativos,
    SUM(ubs_fonte) AS ubs_fonte,
    SUM(ubs_ativas) AS ubs_ativas,
    SUM(estab_com_leitos) AS estab_com_leitos,
    SUM(leitos_existentes) AS leitos_existentes,
    SUM(leitos_sus) AS leitos_sus,
    ROUND(SUM(leitos_sus) * 100.0 / NULLIF(SUM(leitos_existentes), 0), 2) AS proporcao_leitos_sus_pct
FROM vw_consolidado_municipal
GROUP BY regiao_comparativa;
