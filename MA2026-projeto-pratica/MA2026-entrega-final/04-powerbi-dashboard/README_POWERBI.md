# Etapa 6 — Dashboard Interativo Power BI (`04-powerbi-dashboard`)

**Projeto:** SaúdeData SP — Infraestrutura de Saúde nos Municípios Paulistas  
**Disciplina:** Microinformática Aplicada (ILP590) — Fatec São Paulo (2º/2026)  
**Docente:** Prof. Veríssimo  

## Arquivos Entregues

1. **`SaudeDataSP_Dashboard.pbit`**: Modelo de Template oficial do Power BI Desktop contendo:
   - **Dados já embutidos no Power Query M (UTF-8 Base64):** abre em qualquer computador Windows sem exigir alteração de caminho de pasta (`C:\CAMINHO\...`).
   - **Modelagem Star Schema:** `DimMunicipio` (1) -> (*) `FatoMunicipal` e `DimMunicipio` (1) -> (*) `FatoLeitos`, além da tabela dedicada `_Medidas`.
   - **17 Medidas DAX:** todas as 10 medidas propostas (`Estabelecimentos Ativos`, `UBS com CNES Ativo`, `UBS não Correspondentes ao CNES Ativo`, `Leitos Existentes`, `Leitos SUS`, `Proporção de Leitos SUS`, etc.) + 7 indicadores complementares.
   - **3 Páginas de Relatório:**
     - *Página 1 — Visão Geral Estadual:* 6 cartões KPI, segmentadores por município e recorte Capital/Interior, Top 10 municípios por leitos e por CNES ativos, e distribuição por natureza jurídica.
     - *Página 2 — Rede Hospitalar e Leitos SUS:* filtros por município, natureza e tipo; gráfico por tipo de estabelecimento; tabela detalhada dos 1.032 estabelecimentos e notas metodológicas.
     - *Página 3 — Auditoria e Consolidação Municipal:* indicadores de auditoria CNES/UBS e tabela consolidada completa dos 645 municípios.
2. **`SaudeDataSP_PBIP/`**: Projeto Power BI moderno (`SaudeDataSP.pbip`, `SaudeDataSP.SemanticModel`, `SaudeDataSP.Report`) para versionamento direto no GitHub.
3. **`scripts_apoio/`**: Arquivos avulsos (`medidas_dax_completas.dax`, `consultas_powerquery_m.pq`, `tema_saudedata_sp.json`) para consulta e apresentação oral.

## Como Abrir e Salvar como `.pbix`

1. Instale ou abra o **Microsoft Power BI Desktop** no Windows.
2. Dê duplo clique em **`SaudeDataSP_Dashboard.pbit`** (ou abra **`SaudeDataSP_PBIP/SaudeDataSP.pbip`**).
3. O Power BI Desktop carregará automaticamente as tabelas, relacionamentos, medidas DAX e os 3 painéis visuais.
4. Clique em **Arquivo -> Salvar como** para gerar o arquivo `.pbix` final na máquina da apresentação.
