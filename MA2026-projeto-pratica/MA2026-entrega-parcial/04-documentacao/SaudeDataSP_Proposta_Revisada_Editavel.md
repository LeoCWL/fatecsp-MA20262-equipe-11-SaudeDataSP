# SaúdeData SP — Proposta técnica revisada

Fatec São Paulo — Análise e Desenvolvimento de Sistemas  
Microinformática Aplicada (ILP590) — Prof. Veríssimo — 2º semestre de 2026

**Projeto:** análise da distribuição de estabelecimentos de saúde, UBS e leitos nos municípios paulistas.  
**Repositório:** https://github.com/LeoCWL/fatecsp-MA20262-equipe-11-SaudeDataSP

## 1. Equipe e distribuição proposta

A tabela apresenta uma divisão sugerida para finalizar e defender o projeto. Ela não declara essas tarefas como concluídas; precisa ser confirmada pela equipe. A criação do repositório é atribuída a Leonardo na proposta anterior.

| Integrante | RA conforme a proposta | Tarefa proposta |
| --- | --- | --- |
| João Pedro Pinto | 0020482422014 | Coordenação principal, integração das etapas, planilha e validação técnica. |
| Matheus Rodrigues Felix da Silva | 0020482413091 | Revisão das fontes, das regras de tratamento e da auditoria dos dados. |
| Leonardo Lee | 0020482422023 | Organização do repositório, controle das versões e publicação das entregas. |
| Enzo Oliveira Malzone | 00204822021 | Revisão da documentação, preparação dos slides e apoio à apresentação. |

Todos devem compreender o conjunto da solução e participar da apresentação. O RA do Enzo deve ser conferido com o aluno; ele aparece acima como está na proposta recebida.

## 2. Contexto e problema

A análise da infraestrutura de saúde exige consultar cadastros que usam formatos e períodos de referência diferentes. A consolidação por município facilita a comparação dos recursos registrados no estado de São Paulo. A base CNES abrange estabelecimentos públicos e privados; os indicadores de leitos SUS identificam uma parcela específica dos leitos existentes.

**Pergunta central:** como se distribuem os estabelecimentos de saúde, as UBS e os leitos hospitalares entre os municípios paulistas, e quais diferenças podem ser identificadas com a análise integrada desses indicadores?

## 3. Objetivo e escopo

Organizar os dados públicos de estabelecimentos, UBS e leitos por município e desenvolver uma solução evolutiva de análise. O recorte inicial abrange os 645 municípios paulistas. A interpretação deve distinguir estabelecimentos cadastrados de recursos destinados ao SUS e registrar os períodos das fontes.

Objetivos específicos:

1. Estruturar e auditar os dados no Excel, com fórmulas, tabelas e validação.
2. Executar consultas no Power Query para padronizar, verificar e consolidar as bases.
3. Construir um modelo no Power Pivot e validar medidas DAX iniciais.
4. Nas etapas posteriores, desenvolver a automação em VBA, implementar o banco relacional e consultas SQL, integrar uma API e criar um painel no Power BI.

## 4. Dados e método

- **CNES — estabelecimentos:** retrato divulgado em 07/11/2026, com recorte para São Paulo e situação de desabilitação.
- **UBS:** relação divulgada em 07/11/2026. Cruzamento com o cadastro geral por CNES e código do município.
- **Hospitais e leitos:** competência setembro de 2026, sem somar meses diferentes.
- **Municípios:** códigos e nomes da tabela da Receita Federal; o código de seis dígitos é a chave de integração.

Os extratos foram coletados em 09/11/2026. Os códigos CNES são tratados como texto com sete dígitos. A definição provisória de estabelecimento ativo é motivo de desabilitação vazio. Os indicadores não medem cobertura por habitante nem qualidade do atendimento.

## 5. Solução técnica

O projeto seguirá a sequência prevista na disciplina: dados brutos, Excel, Power Query, Power Pivot/DAX, VBA, SQL, API/Web e Power BI. No modelo proposto, DimMunicipio se relaciona com FatoMunicipal, que guarda contagens de estabelecimentos e UBS, e com FatoLeitos, que guarda um registro por estabelecimento e competência.

As medidas iniciais propostas são estabelecimentos ativos, UBS compatíveis com cadastro ativo, leitos existentes, leitos SUS e proporção de leitos SUS. A proporção relaciona leitos SUS aos existentes e não é uma taxa de ocupação. Uma taxa por mil habitantes depende de uma fonte populacional compatível e ainda não foi calculada.

## 6. Situação para o checkpoint 1

A planilha, os extratos, as consultas M, as tabelas propostas para o modelo, o relatório e os slides foram preparados. Os valores de referência foram conferidos por agregação independente. Ainda é necessário executar as consultas no Excel, construir e testar o Power Pivot/DAX, confirmar as responsabilidades e os RAs, publicar os arquivos e preparar a apresentação.

O arquivo Excel preparado é uma extração estática. Os scripts M e as medidas DAX são propostas e ainda não foram executados no Excel. Os dados de novembro e setembro não representam a mesma fotografia temporal.

## 7. Fontes

- Ministério da Saúde, [CNES — estabelecimentos](https://dadosabertos.saude.gov.br/dataset/cnes-cadastro-nacional-de-estabelecimentos-de-saude).
- Ministério da Saúde, [Unidades Básicas de Saúde — UBS](https://dadosabertos.saude.gov.br/dataset/unidades-basicas-de-saude-ubs).
- Ministério da Saúde, [Hospitais e leitos](https://dadosabertos.saude.gov.br/dataset/hospitais-e-leitos).
- Receita Federal, [Tabela de municípios](https://www.gov.br/receitafederal/dados/municipios.csv/view).

Fontes acessadas em 09/11/2026.
