# SaúdeData SP — Relatório parcial

Fatec São Paulo — Análise e Desenvolvimento de Sistemas  
Microinformática Aplicada (ILP590) — Prof. Veríssimo — 2º semestre de 2026

**Estado do trabalho:** versão para revisão da equipe. Os dados foram consolidados e conferidos fora do Power Query; as consultas M e as medidas DAX estão preparadas, mas ainda não foram executadas no Excel. A divisão de tarefas apresentada é uma proposta e precisa ser confirmada pela equipe.

## 1. Problema e objetivo

O projeto investiga a distribuição de estabelecimentos de saúde, unidades básicas de saúde (UBS) e leitos entre os municípios paulistas. A consulta separada de bases públicas com formatos e períodos distintos dificulta a comparação dos dados disponíveis.

**Pergunta central:** como se distribuem os estabelecimentos, as UBS e os leitos hospitalares entre os municípios do estado de São Paulo, e quais diferenças podem ser identificadas a partir desses dados?

O objetivo é organizar os registros por município e construir indicadores que apoiem essa comparação. Os números são de infraestrutura cadastrada; não demonstram, sozinhos, acesso efetivo, qualidade do atendimento ou necessidade da população.

## 2. Fontes e recorte

| Fonte | Uso e período |
| --- | --- |
| CNES — estabelecimentos | Retrato divulgado em 07/11/2026; contagem por município e situação de desabilitação. |
| Relação de UBS | Retrato divulgado em 07/11/2026; identificação de UBS por CNES e município. |
| Hospitais e leitos | Competência setembro de 2026; quantidades existentes e destinadas ao SUS. |
| Receita Federal — tabela de municípios | Códigos e nomes para associar os registros ao município. |

Coleta em 09/11/2026. As fontes de estabelecimentos e UBS são retratos de novembro; os leitos são de setembro. O cadastro inclui estabelecimentos públicos e privados.

## 3. Preparação e qualidade dos dados

Os arquivos nacionais foram filtrados para o estado de São Paulo e as colunas necessárias foram selecionadas. Os códigos de estabelecimento foram tratados como texto com sete dígitos; o código municipal de seis dígitos serviu para o cruzamento. Os resultados municipais foram conferidos por uma segunda agregação dos mesmos extratos.

A condição de estabelecimento ativo foi definida, para este trabalho, pelo campo de motivo de desabilitação vazio. Uma UBS foi classificada como compatível com o cadastro ativo quando havia correspondência do código CNES e do município em um registro ativo. Essa regra e as diferenças entre datas devem ser revistas em cada atualização.

| Verificação | Resultado de referência |
| --- | --- |
| Municípios na tabela | 645 códigos únicos |
| Registros CNES em SP | 154.927 cadastrados; 116.712 ativos; 38.215 desativados |
| Lista de UBS | 5.844 registros; 5.334 compatíveis com CNES ativo; 510 vinculados a CNES desativado |
| Leitos em setembro de 2026 | 1.032 registros de estabelecimentos; nenhum com leitos SUS maior que o total |
| Chaves | Sem duplicidade de CNES nos extratos e sem município de origem fora da tabela usada |

A lista de UBS e o cadastro geral podem ter diferenças de atualização. Os 510 casos são uma divergência entre os recortes usados e não permitem, isoladamente, concluir que há erro no cadastro oficial.

## 4. Resultados iniciais

| Indicador | Estado de SP | Município de São Paulo |
| --- | ---: | ---: |
| Estabelecimentos ativos | 116.712 | 29.741 |
| UBS na lista de origem | 5.844 | 652 |
| UBS compatíveis com CNES ativo | 5.334 | 547 |
| Estabelecimentos com registro de leitos | 1.032 | 233 |
| Leitos existentes | 110.713 | 37.437 |
| Leitos SUS | 62.439 | 18.069 |

O exemplo compara números absolutos, sem ajustar pela população. A ausência de registro de leitos na fonte para um município não comprova ausência de leitos.

## 5. Modelo e indicadores propostos

O modelo proposto reúne uma dimensão de municípios e duas tabelas de fatos: uma com contagens municipais de estabelecimentos e UBS e outra com um registro por estabelecimento com leitos na competência selecionada. A dimensão se relaciona com cada tabela de fatos pelo código municipal.

As medidas DAX propostas incluem estabelecimentos ativos, UBS com correspondência no CNES ativo, leitos existentes, leitos SUS e proporção de leitos SUS sobre os existentes. A proporção não representa taxa de ocupação. As medidas e relacionamentos ainda precisam ser criados e testados no Power Pivot.

## 6. Entregas preparadas e pendências

| Componente | Situação |
| --- | --- |
| Excel | Planilha com consulta por município, tabelas, fórmulas e verificações; dados estáticos. |
| Power Query | Arquivos de origem, resultados de referência e consultas M preparados. Falta executar as consultas e salvar uma pasta de trabalho com elas ativas. |
| Power Pivot / DAX | Tabelas, desenho de relacionamentos e medidas preparados. Falta criar e validar o modelo no Excel. |
| Relatório e slides | Material parcial para revisão. Confirmar tarefas por integrante e atualizar os resultados após a execução real. |
| GitHub e apresentação | Publicar e revisar os arquivos no repositório. Preparar defesa oral de 10 a 15 minutos com participação de todos. |

## 7. Equipe e responsabilidades

A proposta do repositório identifica quatro integrantes. Leonardo consta como responsável pela criação do repositório. A distribuição abaixo é sugerida para o trabalho restante e deve ser confirmada; não representa tarefas concluídas.

| Nome e RA | Tarefa proposta |
| --- | --- |
| João Pedro Pinto — 0020482422014 | Coordenação, integração e validação técnica |
| Matheus Rodrigues Felix da Silva — 0020482413091 | Revisão das fontes, cruzamentos e auditoria |
| Leonardo Lee — 0020482422023 | Repositório e organização das entregas |
| Enzo Oliveira Malzone — 00204822021 | Revisão do relatório, slides e apresentação |

## 8. Limitações e próximos passos

Os recortes não representam a mesma competência temporal. As contagens absolutas favorecem municípios maiores em população e não demonstram cobertura ou suficiência dos serviços. O recorte de leitos não inclui uma estimativa populacional; portanto, não foi calculada uma taxa por habitante.

Antes da entrega, é necessário executar as consultas M, conferir os totais, criar e testar os relacionamentos e medidas DAX, confirmar as responsabilidades, conferir os RAs e publicar a versão final dos arquivos. O professor poderá fazer perguntas individuais sobre qualquer parte da solução.

## 9. Referências

- BRASIL. Ministério da Saúde. [CNES — estabelecimentos](https://dadosabertos.saude.gov.br/dataset/cnes-cadastro-nacional-de-estabelecimentos-de-saude). Acesso em: 9 nov. 2026.
- BRASIL. Ministério da Saúde. [Unidades Básicas de Saúde — UBS](https://dadosabertos.saude.gov.br/dataset/unidades-basicas-de-saude-ubs). Acesso em: 9 nov. 2026.
- BRASIL. Ministério da Saúde. [Hospitais e leitos](https://dadosabertos.saude.gov.br/dataset/hospitais-e-leitos). Acesso em: 9 nov. 2026.
- BRASIL. Receita Federal. [Tabela de municípios](https://www.gov.br/receitafederal/dados/municipios.csv/view). Acesso em: 9 nov. 2026.
- FATEC SÃO PAULO. Guia de orientação e evolução do Projeto Evolutivo de Dados. Microinformática Aplicada, 2º semestre de 2026.
