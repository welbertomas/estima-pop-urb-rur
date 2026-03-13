# estima-pop-urb-rur

Estimativa de populações municipais por condição de domicílio (urbano e rural) para os períodos intercensitários **2000–2010** e **2010–2022**.

## Estrutura do repositório

- `script/prepare_data.R`: baixa e organiza dados dos Censos (2000, 2010 e 2022) via SIDRA e salva em `raw_data/popmun_urb_rur.rds`.
- `script/funcoes_estimacao.R`: centraliza funções compartilhadas para cálculo de taxas, estimativas intercensitárias e transformação para formato longo.
- `script/estima_pop.R`: calcula as estimativas municipais e exporta a planilha final `output/populações.xlsx` com nota metodológica.
- `script/estimacao_pop_urb_rur.qmd`: documento Quarto com metodologia, texto explicativo e gráficos, com saída PDF em `output/estimacao_pop_urb_rur.pdf`.
- `raw_data/popmun_urb_rur.rds`: base bruta consolidada para estimação.
- `renv.lock`: congelamento das versões de pacotes do projeto.

## Fluxo recomendado

1. Execute `script/prepare_data.R` para atualizar a base bruta.
2. Execute `script/estima_pop.R` para gerar a planilha de resultados.
3. Renderize `script/estimacao_pop_urb_rur.qmd` para gerar o relatório em PDF.
