// Altere apenas o caminho abaixo para a pasta descompactada 02-powerquery.
let
    Pasta = "C:\CAMINHO\02-powerquery",
    Ler = (arquivo as text) as table =>
        Table.PromoteHeaders(
            Csv.Document(File.Contents(Pasta & "\dados_brutos\" & arquivo),
                [Delimiter=";", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
            [PromoteAllScalars=true]),
    Limpar = (x as nullable text) as text => if x = null then "" else Text.Trim(Text.Clean(x)),
    CodigoCNES = (x as nullable text) as text => if Limpar(x) = "" then "" else Text.PadStart(Limpar(x), 7, "0"),

    Municipio0 = Ler("municipios_sp.csv"),
    Municipio1 = Table.TransformColumns(Municipio0, {{"IBGE6", Limpar, type text}, {"IBGE7", Limpar, type text}, {"Municipio", Limpar, type text}}),
    Municipio2 = Table.Distinct(Municipio1),
    Municipios = if List.Contains(Municipio2[IBGE6], "") or Table.RowCount(Municipio2) <> List.Count(List.Distinct(Municipio2[IBGE6])) then error "Código municipal vazio ou duplicado." else Municipio2,

    CNES0 = Ler("cnes_sp.csv"),
    CNES1 = Table.TransformColumns(CNES0, {{"CO_CNES", CodigoCNES, type text}, {"CO_UF", Limpar, type text}, {"CO_IBGE", Limpar, type text}, {"NO_FANTASIA", Limpar, type text}, {"CO_MOTIVO_DESAB", Limpar, type text}}),
    CNES2 = Table.Distinct(Table.SelectRows(CNES1, each [CO_UF] = "35")),
    CNES = if List.Contains(CNES2[CO_CNES], "") or List.Contains(CNES2[CO_IBGE], "") or Table.RowCount(CNES2) <> List.Count(List.Distinct(CNES2[CO_CNES])) then error "CNES com chave vazia ou duplicada: revise os dados de origem." else CNES2,
    CNESStatus = Table.AddColumn(CNES, "Ativo", each [CO_MOTIVO_DESAB] = "", type logical),
    CNESGrupo = Table.Group(CNESStatus, {"CO_IBGE"}, {
        {"CNES_Cadastrados", each Table.RowCount(_), Int64.Type},
        {"CNES_Ativos", each Table.RowCount(Table.SelectRows(_, each [Ativo])), Int64.Type},
        {"CNES_Desativados", each Table.RowCount(Table.SelectRows(_, each not [Ativo])), Int64.Type}}),

    UBS0 = Ler("ubs_sp.csv"),
    UBS1 = Table.TransformColumns(UBS0, {{"CNES", CodigoCNES, type text}, {"UF", Limpar, type text}, {"IBGE", Limpar, type text}, {"NOME", Limpar, type text}}),
    UBS2 = Table.Distinct(Table.SelectRows(UBS1, each [UF] = "35")),
    UBS = if List.Contains(UBS2[CNES], "") or List.Contains(UBS2[IBGE], "") or Table.RowCount(UBS2) <> List.Count(List.Distinct(UBS2[CNES])) then error "UBS com chave vazia ou duplicada: revise os dados de origem." else UBS2,
    CruzarUBS = Table.NestedJoin(UBS, {"CNES", "IBGE"}, Table.SelectRows(CNESStatus, each [Ativo]), {"CO_CNES", "CO_IBGE"}, "CNES_Ativo", JoinKind.LeftOuter),
    UBSMarcada = Table.AddColumn(CruzarUBS, "Ativa", each Table.RowCount([CNES_Ativo]) = 1, type logical),
    UBSGrupo = Table.Group(UBSMarcada, {"IBGE"}, {
        {"UBS_Fonte", each Table.RowCount(_), Int64.Type},
        {"UBS_Ativas", each Table.RowCount(Table.SelectRows(_, each [Ativa])), Int64.Type}}),

    Leitos0 = Ler("leitos_sp_2026.csv"),
    Leitos1 = Table.TransformColumns(Leitos0, {{"COMP", Limpar, type text}, {"UF", Limpar, type text}, {"CO_IBGE", Limpar, type text}, {"CNES", CodigoCNES, type text}, {"NOME_ESTABELECIMENTO", Limpar, type text}, {"LEITOS_EXISTENTES", Limpar, type text}, {"LEITOS_SUS", Limpar, type text}, {"MOTIVO_DESABILITACAO", Limpar, type text}}),
    Leitos2 = Table.Distinct(Table.SelectRows(Leitos1, each [UF] = "SP" and [COMP] = "202609")),
    Leitos3 = Table.AddColumn(Leitos2, "Chave", each [COMP] & "-" & [CNES], type text),
    Leitos4 = if List.Contains(Leitos3[CNES], "") or List.Contains(Leitos3[CO_IBGE], "") or List.Contains(Leitos3[LEITOS_EXISTENTES], "") or List.Contains(Leitos3[LEITOS_SUS], "") or Table.RowCount(Leitos3) <> List.Count(List.Distinct(Leitos3[Chave])) then error "Leitos com chave/valor vazio ou duplicado: revise a origem." else Leitos3,
    Leitos5 = Table.TransformColumnTypes(Leitos4, {{"LEITOS_EXISTENTES", Int64.Type}, {"LEITOS_SUS", Int64.Type}}, "pt-BR"),
    Leitos = if Table.RowCount(Table.SelectRows(Leitos5, each [LEITOS_SUS] > [LEITOS_EXISTENTES] or [LEITOS_SUS] < 0 or [LEITOS_EXISTENTES] < 0)) > 0 then error "Quantidade de leitos inválida." else Leitos5,
    LeitosGrupo = Table.Group(Leitos, {"CO_IBGE"}, {
        {"Estab_Com_Leitos", each Table.RowCount(_), Int64.Type},
        {"Leitos_Existentes", each List.Sum([LEITOS_EXISTENTES]), Int64.Type},
        {"Leitos_SUS", each List.Sum([LEITOS_SUS]), Int64.Type}}),

    CodigosOrigem = List.Union({CNESGrupo[CO_IBGE], UBSGrupo[IBGE], LeitosGrupo[CO_IBGE]}),
    Base = if List.Count(List.Difference(CodigosOrigem, Municipios[IBGE6])) > 0 then error "Existem municípios da fonte sem correspondência na tabela municipal." else Municipios,
    J1 = Table.NestedJoin(Base, {"IBGE6"}, CNESGrupo, {"CO_IBGE"}, "c", JoinKind.LeftOuter),
    E1 = Table.ExpandTableColumn(J1, "c", {"CNES_Cadastrados", "CNES_Ativos", "CNES_Desativados"}),
    J2 = Table.NestedJoin(E1, {"IBGE6"}, UBSGrupo, {"IBGE"}, "u", JoinKind.LeftOuter),
    E2 = Table.ExpandTableColumn(J2, "u", {"UBS_Fonte", "UBS_Ativas"}),
    J3 = Table.NestedJoin(E2, {"IBGE6"}, LeitosGrupo, {"CO_IBGE"}, "l", JoinKind.LeftOuter),
    E3 = Table.ExpandTableColumn(J3, "l", {"Estab_Com_Leitos", "Leitos_Existentes", "Leitos_SUS"}),
    Zeros = Table.ReplaceValue(E3, null, 0, Replacer.ReplaceValue, {"CNES_Cadastrados", "CNES_Ativos", "CNES_Desativados", "UBS_Fonte", "UBS_Ativas", "Estab_Com_Leitos", "Leitos_Existentes", "Leitos_SUS"}),
    Tipos = Table.TransformColumnTypes(Zeros, {{"CNES_Cadastrados", Int64.Type}, {"CNES_Ativos", Int64.Type}, {"CNES_Desativados", Int64.Type}, {"UBS_Fonte", Int64.Type}, {"UBS_Ativas", Int64.Type}, {"Estab_Com_Leitos", Int64.Type}, {"Leitos_Existentes", Int64.Type}, {"Leitos_SUS", Int64.Type}}),
    Resultado = Table.Sort(Tipos, {{"Municipio", Order.Ascending}})
in
    Resultado
