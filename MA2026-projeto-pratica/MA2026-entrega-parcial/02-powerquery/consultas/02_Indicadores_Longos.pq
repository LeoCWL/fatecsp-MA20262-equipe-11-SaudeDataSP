// Crie esta consulta depois da consulta Municipios_Consolidados.
let
    Fonte = Municipios_Consolidados,
    Indicadores = Table.UnpivotOtherColumns(Fonte, {"IBGE6", "IBGE7", "Municipio"}, "Indicador", "Valor"),
    Tipos = Table.TransformColumnTypes(Indicadores, {{"Indicador", type text}, {"Valor", Int64.Type}})
in
    Tipos
