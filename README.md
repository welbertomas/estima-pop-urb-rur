# estima-pop-urb-rur

Estimativa de populações municipais por condição de domicílio (urbano e rural) para os períodos intercensitários **2000–2010** e **2010–2022**.

## Estrutura do repositório

- `script/prepare_data.R`: baixa e organiza dados dos Censos (2000, 2010 e 2022) via SIDRA e salva em `raw_data/popmun_urb_rur.rds`.
- `script/estima_pop.R`: calcula taxas geométricas anuais, interpola as populações anuais e exporta planilha final.
- `script/estimacao_pop_urb_rur.qmd`: documento Quarto com metodologia, texto explicativo e gráficos.
- `raw_data/popmun_urb_rur.rds`: base bruta consolidada para estimação.

## Verificação dos caminhos dos scripts

Foram corrigidos e padronizados os caminhos dos scripts para uso relativo à raiz do projeto:

- `prepare_data.R`:
  - raiz definida por `normalizePath(file.path(getwd(), ".."), ...)`;
  - saída gravada em `raw_data/popmun_urb_rur.rds` com `file.path(...)`.
- `estima_pop.R`:
  - leitura em `raw_data/popmun_urb_rur.rds`;
  - saída em `output/Populacoes.xlsx`;
  - criação automática da pasta `output/` com `dir.create(...)`.

## Verificação da taxa geométrica

A taxa geométrica anual está implementada corretamente como:

\[
\text{taxa} = \left(\frac{P_t}{P_0}\right)^{\frac{1}{n}} - 1
\]

com:

- `n = 10` para o intervalo 2000–2010;
- `n = 12` para o intervalo 2010–2022.

As projeções anuais também seguem o formato composto:

\[
P_{ano} = P_{base}\cdot(1+\text{taxa})^{(ano-ano_{base})}
\]

## Como executar

> Execute os scripts a partir da pasta `script/`.

1. Preparar os dados:

```bash
cd script
Rscript prepare_data.R
```

2. Gerar estimativas e planilha final:

```bash
Rscript estima_pop.R
```

3. Renderizar o relatório Quarto:

```bash
quarto render estimacao_pop_urb_rur.qmd
```

## Melhorias significativas implementadas

- Correção de erros de execução (`path.file` -> `file.path`, `ffile.path` -> `file.path`).
- Remoção de instalação de pacote dentro do script (`install.packages("sidrar")`).
- Padronização de caminhos relativos e criação de diretórios de saída.
- Ajuste do mapeamento de Grandes Regiões pelo código municipal IBGE.
- Migração do texto metodológico para Quarto (`.qmd`) mantendo conteúdo e gráficos.
- Inclusão de `.gitignore` para manter foco em `script/`, `raw_data/` e `README.md`.

## Melhorias adicionais recomendadas

- Criar `renv` para congelar versões de pacotes.
- Separar funções auxiliares (cálculo de taxa e projeção) em arquivo de utilitários.
- Adicionar validações automáticas (ex.: conferir se valores de 2010 e 2022 são reproduzidos pela fórmula).
