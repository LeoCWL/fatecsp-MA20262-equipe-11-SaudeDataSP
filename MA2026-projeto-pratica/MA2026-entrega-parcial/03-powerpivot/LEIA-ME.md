# SaúdeData SP — 03 Power Pivot

## Situação

Modelo e medidas preparados para implementação. O arquivo não contém um modelo Power Pivot ativo: o Excel disponível informou licença expirada e modo somente leitura. As expressões DAX e os relacionamentos ainda precisam ser criados e testados no Excel habilitado.

## Tabelas

- DimMunicipio: 645 linhas, uma por município. IBGE6 é a chave de texto única.
- FatoMunicipal: 645 linhas, uma por município, com contagens de estabelecimentos e UBS.
- FatoLeitos: 1.032 linhas, uma por estabelecimento com registro de leitos em setembro de 2026. CNES é texto de sete dígitos.

Estes arquivos são extrações estáticas do pacote anterior, não conexões de atualização automática. Os arquivos municipais de estabelecimentos e UBS são retratos publicados em novembro de 2026; os leitos têm competência 202609. A base abrange unidades públicas e privadas.

## Relacionamentos

Crie os dois vínculos abaixo com DimMunicipio no lado de valores únicos:

1. DimMunicipio[IBGE6] (1) para FatoMunicipal[IBGE6] (várias linhas possíveis; nesta extração há uma por município).
2. DimMunicipio[IBGE6] (1) para FatoLeitos[IBGE6] (várias linhas por município).

Não ligue as duas tabelas de fatos diretamente. Use DimMunicipio[Municipio] como campo de filtro nas tabelas dinâmicas. Os códigos IBGE e CNES devem ser importados como texto, para preservar os zeros à esquerda.

## Como montar

1. Em um Excel para Windows com Power Pivot habilitado, importe os três CSVs da pasta dados_modelo com delimitador ponto e vírgula e codificação UTF-8. Carregue cada tabela no Modelo de Dados com os nomes exatos DimMunicipio, FatoMunicipal e FatoLeitos.
2. No Power Pivot, crie os relacionamentos descritos acima. Confira que a dimensão tem IBGE6 único e que cada chave nas tabelas fato encontra um município.
3. Crie individualmente as medidas em medidas/medidas_dax.txt. Conforme a configuração regional, o Excel pode exigir ponto e vírgula no lugar da vírgula entre argumentos de funções. Formate Proporção de Leitos SUS como porcentagem.
4. Crie uma tabela dinâmica a partir do Modelo de Dados, usando Município da dimensão nas linhas e as medidas nos valores. Compare os totais com a seção abaixo e filtre a cidade de São Paulo.
5. Salve a pasta de trabalho com o modelo e as medidas, atualize a documentação e copie o arquivo para 03-powerpivot. Para uma atualização real pelo Power Query, conecte o modelo às consultas ativas depois de validá-las.

## Valores de conferência

- Estado: 116.712 estabelecimentos ativos; 5.844 UBS na fonte e 5.334 com correspondência no cadastro ativo; 1.032 registros de estabelecimentos com leitos; 110.713 leitos existentes e 62.439 leitos SUS.
- Município de São Paulo: 29.741 estabelecimentos ativos; 652 UBS na fonte e 547 com correspondência no cadastro ativo; 233 registros de estabelecimentos com leitos; 37.437 leitos existentes e 18.069 leitos SUS.
- Sem registro de leitos na fonte não comprova inexistência de leitos no município. Proporção de leitos SUS é leitos SUS divididos pelos existentes, não mede ocupação.

## Cuidados

A análise usa números absolutos e não ajusta pela população. Não soma valores de meses diferentes. A condição de ativo é campo CO_MOTIVO_DESAB vazio, conforme o recorte preparado, e a lista de UBS foi cruzada pelo CNES e município. O resultado deve ser revisto ao atualizar os arquivos.
