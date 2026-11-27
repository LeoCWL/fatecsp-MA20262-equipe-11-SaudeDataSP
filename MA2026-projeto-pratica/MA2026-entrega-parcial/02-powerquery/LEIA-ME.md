# SaúdeData SP — etapa 02: Power Query

Este pacote organiza os dados e as consultas para a Parcial 1. Ele contém código M preparado e resultados de referência. **As consultas ainda não foram executadas no Excel**: o Excel disponível estava em modo somente leitura por licença expirada. Assim, não há uma pasta de trabalho com consultas ativas neste pacote. Os CSVs limpos foram gerados separadamente a partir das fontes e comparados com uma agregação independente.

## Conteúdo

- consultas/01_Municipios_Consolidados.pq: código M de leitura, limpeza, integração e agregação.
- consultas/02_Indicadores_Longos.pq: consulta dependente que transforma os indicadores em linhas (unpivot).
- dados_brutos/: extratos das fontes, pré-filtrados para São Paulo e com as colunas necessárias. Não são os arquivos nacionais completos. Os dados de leitos preservam os meses disponíveis de 2026.
- dados_limpos/: resultado de referência por município, detalhe de leitos de setembro, dados em formato longo e resultado de verificações.

## Como ativar em um Excel para Windows habilitado

1. Descompacte o ZIP em uma pasta e mantenha juntas as subpastas consultas e dados_brutos. Exemplo: C:\Projeto\02-powerquery.
2. Em Excel, abra ou crie uma pasta de trabalho. Em Dados > Obter Dados > De Outras Fontes > Consulta Nula, abra o Editor Avançado. A sequência de menus pode variar por versão.
3. Copie o conteúdo de consultas/01_Municipios_Consolidados.pq. Substitua o conteúdo do Editor Avançado e altere somente o valor da variável Pasta para o caminho real da pasta descompactada, sem barra no final. Exemplo: Pasta = "C:\Projeto\02-powerquery",
4. Confirme e, se solicitado, escolha acesso anônimo às fontes locais. Dê à consulta o nome exato Municipios_Consolidados e selecione Fechar e Carregar. A consulta precisa executar sem erro antes da próxima etapa.
5. Crie outra Consulta Nula, abra o Editor Avançado e cole consultas/02_Indicadores_Longos.pq. Nomeie-a Indicadores_Longos e carregue conforme necessário. Ela depende da primeira consulta.
6. Compare os totais e as 645 linhas da primeira consulta com dados_limpos/municipios_consolidados.csv e verificacao_resultados.json. A segunda deve ter 5.160 linhas (645 x 8 indicadores). Salve a pasta de trabalho com as consultas ativas e inclua-a no repositório. A planilha da etapa 01 é uma extração estática separada: ela não será atualizada automaticamente por essas novas consultas.
7. Copie este conteúdo para MA2026-entrega-parcial/02-powerquery/ e inclua o arquivo .xlsx com as consultas. No GitHub, publique os arquivos extraídos e verifique que o caminho local em Pasta deve ser ajustado por cada integrante após clonar.

## Transformações e verificações

Os arquivos são lidos em UTF-8, separados por ponto e vírgula. O código normaliza espaços e identificadores, mantém zeros à esquerda no CNES, elimina linhas integralmente idênticas e interrompe a atualização em caso de chave vazia ou duplicidade conflitante. Filtra SP e a competência 202609, cruza UBS com o mesmo CNES e município ativo, agrupa por município e transforma os indicadores em formato longo. Quantidades vazias ou inválidas na base de leitos são tratadas como erro; não são convertidas em zero. Códigos de município sem correspondência também geram erro.

Na agregação, zero em leitos significa que não foi encontrado registro na base para o município e competência, não uma prova de inexistência de leitos. Campos numéricos nulos após a junção são preenchidos com zero para indicar ausência de registro no extrato.

## Resultados de referência

- 645 municípios; 154.927 estabelecimentos cadastrados e 116.712 com motivo de desabilitação vazio.
- 5.844 UBS na lista de origem; 5.334 com CNES ativo e mesmo município; 510 associadas a cadastro desativado no cruzamento realizado.
- Setembro de 2026: 1.032 estabelecimentos com leitos, 110.713 leitos existentes e 62.439 leitos SUS.
- As bases de estabelecimentos e UBS foram publicadas em novembro; leitos referem-se a setembro. O cadastro inclui estabelecimentos públicos e privados. A atualização de uma base pode alterar essas relações e totais.

## Atualização dos arquivos

As consultas leem os quatro CSVs locais deste pacote; não baixam automaticamente as fontes nacionais. Para atualização, faça novos extratos de SP com os mesmos nomes e cabeçalhos, revise a competência de leitos na consulta, recalcule, documente as datas de extração e compare novamente as chaves. Não substitua um arquivo com formato ou definição diferente sem revisar o M.

## Fontes oficiais consultadas em 09/11/2026

- CNES: https://dadosabertos.saude.gov.br/dataset/cnes-cadastro-nacional-de-estabelecimentos-de-saude/resource/78b91d79-bb6d-43ad-bda5-f015e3575a84
- UBS: https://dadosabertos.saude.gov.br/dataset/unidades-basicas-de-saude-ubs/resource/264326aa-6aa2-4bc9-8dad-21f9aebe5e66
- Leitos: https://dadosabertos.saude.gov.br/dataset/hospitais-e-leitos/resource/5ac78b13-649f-4b09-8a92-0ae829a56d50
- Códigos municipais: https://www.gov.br/receitafederal/dados/municipios.csv/view
