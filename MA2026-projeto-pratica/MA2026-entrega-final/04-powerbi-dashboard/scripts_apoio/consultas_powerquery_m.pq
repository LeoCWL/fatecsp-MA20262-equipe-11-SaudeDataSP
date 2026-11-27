// ============================================================================
// PROJETO: SaúdeData SP — Consultas Power Query M (Conexão Externa CSV / SQLite)
// NOTA: O arquivo SaudeDataSP_Dashboard.pbit e o projeto SaudeDataSP_PBIP já
// possuem os dados embutidos em Base64 UTF-8 para abrir sem erro de caminho em
// qualquer computador. Utilize este script apenas se desejar apontar para uma
// pasta local de CSVs ou para o banco SQLite via ODBC.
// ============================================================================

// 1) Consulta DimMunicipio (via pasta CSV)
let
    PastaDados = "C:\CAMINHO\PARA\DADOS",
    Fonte = Csv.Document(File.Contents(PastaDados & "\DimMunicipio.csv"), [Delimiter=";", Columns=3, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    CabecalhosPromovidos = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    LimparTexto = Table.TransformColumns(CabecalhosPromovidos, {
        {"IBGE6", each Text.Trim(Text.Clean(_)), type text},
        {"IBGE7", each Text.Trim(Text.Clean(_)), type text},
        {"Municipio", each Text.Trim(Text.Clean(_)), type text}
    }),
    AdicionarRegiao = Table.AddColumn(LimparTexto, "Regiao_Comparativa", each if [IBGE6] = "355030" then "Capital (São Paulo)" else "Interior (644 Municípios)", type text)
in
    AdicionarRegiao

// 2) Consulta FatoMunicipal (via pasta CSV)
let
    PastaDados = "C:\CAMINHO\PARA\DADOS",
    Fonte = Csv.Document(File.Contents(PastaDados & "\FatoMunicipal.csv"), [Delimiter=";", Columns=6, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    CabecalhosPromovidos = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    TiposAlterados = Table.TransformColumnTypes(CabecalhosPromovidos, {
        {"IBGE6", type text},
        {"CNES_Cadastrados", Int64.Type},
        {"CNES_Ativos", Int64.Type},
        {"CNES_Desativados", Int64.Type},
        {"UBS_Fonte", Int64.Type},
        {"UBS_Ativas", Int64.Type}
    })
in
    TiposAlterados

// 3) Consulta FatoLeitos (via pasta CSV)
let
    PastaDados = "C:\CAMINHO\PARA\DADOS",
    Fonte = Csv.Document(File.Contents(PastaDados & "\FatoLeitos.csv"), [Delimiter=";", Columns=9, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    CabecalhosPromovidos = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    Padronizar = Table.TransformColumns(CabecalhosPromovidos, {
        {"CNES", each Text.PadStart(Text.Trim(Text.Clean(_)), 7, "0"), type text},
        {"IBGE6", each Text.Trim(Text.Clean(_)), type text}
    }),
    TiposAlterados = Table.TransformColumnTypes(Padronizar, {
        {"Leitos_Existentes", Int64.Type},
        {"Leitos_SUS", Int64.Type}
    })
in
    TiposAlterados
