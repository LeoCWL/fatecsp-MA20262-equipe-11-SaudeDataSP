# Etapa 4 — Banco de Dados Relacional SQL (`02-bancodedados-sql`)

**Projeto:** SaúdeData SP — Infraestrutura de Saúde nos Municípios Paulistas  
**Disciplina:** Microinformática Aplicada (ILP590) — Fatec São Paulo (2º/2026)  
**Docente:** Prof. Veríssimo  

## Arquivos Entregues

1. **`saudedata_sp.db`**: Banco de dados SQLite 3 pronto para uso, já populado e validado com integridade referencial (`PRAGMA foreign_keys = ON`). Pode ser aberto diretamente no **DB Browser for SQLite**, **DBeaver**, **VS Code (extensão SQLite)** ou conectado via ODBC ao Power BI.
2. **`01_ddl_schema.sql`**: Script DDL (SQL Padrão ANSI compatível com SQLite e PostgreSQL) contendo:
   - `dim_municipio` (645 municípios paulistas, PK `ibge6`, UNIQUE `ibge7`, flag `is_capital`)
   - `fato_municipal` (645 registros consolidados de CNES e UBS — retrato 07/11/2026, com `CHECK` constraints de consistência aritmética)
   - `fato_leitos` (1.032 registros de estabelecimentos com leitos — competência `202609`, PK composta `(cnes, competencia)`, `CHECK (leitos_sus <= leitos_existentes)`)
   - `fato_indicadores_longos` (5.160 registros normalizados no formato longo `645 x 8 indicadores`)
   - 4 Views analíticas: `vw_consolidado_municipal`, `vw_resumo_estadual`, `vw_leitos_por_natureza_tipo`, `vw_comparativo_capital_interior`.
3. **`02_dml_carga_dados.sql`**: Script DML (`BEGIN TRANSACTION` + `INSERT INTO`) com todos os 7.482 registros validados.
4. **`03_consultas_analiticas.sql`**: 10 consultas analíticas cobrindo auditoria de totais, comparativo Capital vs. Interior, rankings com Window Functions (`RANK() OVER`), agrupamentos por natureza jurídica e tipo de estabelecimento, diagnóstico dos 294 municípios sem leitos registrados, auditoria das 510 UBS divergentes e classificação por CTE + `CASE WHEN`.

## Números de Controle Validados

- **Municípios:** 645
- **CNES Cadastrados / Ativos / Desativados:** 154.927 / 116.712 / 38.215
- **UBS Fonte / Compatíveis com CNES Ativo / Divergentes:** 5.844 / 5.334 / 510
- **Estabelecimentos com Registro de Leitos (202609):** 1.032
- **Leitos Existentes / Leitos SUS / Proporção SUS:** 110.713 / 62.439 / 56,40%
