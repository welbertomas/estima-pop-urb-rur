# estima-pop-urb-rur

Estimativa de populações municipais por condição de domicílio (urbano e rural) para os períodos intercensitários **2000–2010** e **2010–2022**.

## Estrutura do repositório

- `script/prepare_data.R`: baixa e organiza dados dos Censos (2000, 2010 e 2022) via SIDRA e salva em `raw_data/popmun_urb_rur.rds`.
- `script/estima_pop.R`: calcula taxas geométricas anuais, interpola as populações anuais e exporta planilha final.
- `script/estimacao_pop_urb_rur.qmd`: documento Quarto com metodologia, texto explicativo e gráficos.
- `raw_data/popmun_urb_rur.rds`: base bruta consolidada para estimação.


