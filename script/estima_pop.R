# Objetivo: Estimar população municipal por situação do domicílio (urbano/rural)
# para anos intercensitários entre 2000-2010 e 2010-2022.
#
# Etapas do script:
# 1) Carregar a base consolidada dos censos (2000, 2010 e 2022).
# 2) Calcular taxas geométricas e estimar anos intercensitários.
# 3) Organizar base final em formato longo.
# 4) Exportar planilha com nomes de colunas mais descritivos e nota metodológica.

rm(list = ls())

library(dplyr)
library(openxlsx)

# Caminhos ----
DIR_RAIZ <- normalizePath(file.path(getwd(), ".."), winslash = "/", mustWork = FALSE)
DIR_RAW <- file.path(DIR_RAIZ, "raw_data")
DIR_OUTPUT <- file.path(DIR_RAIZ, "output")
dir.create(DIR_OUTPUT, showWarnings = FALSE, recursive = TRUE)

# Funções compartilhadas ----
source(file.path(getwd(), "funcoes_estimacao.R"))

# Carregar dados ----
base <- readRDS(file.path(DIR_RAW, "popmun_urb_rur.rds"))

# Estimativas e transformação ----
base_estim <- preparar_estimativas(base)
bases_longas <- montar_bases_longas(base_estim)

df_final_pop <- bases_longas$urbana |>
  left_join(
    bases_longas$rural |> select(codmun, ano, populacao_rural),
    by = c("codmun", "ano")
  ) |>
  rename(
    `Município` = nome_mun,
    `Código do Município` = codmun,
    `Grande Região` = nome_GR,
    `Código da Grande Região` = codigo_GR,
    `Ano` = ano,
    `População Urbana` = populacao_urbana,
    `População Rural` = populacao_rural
  )

# Exportação para Excel ----
wb <- createWorkbook()
addWorksheet(wb, "Dados")
writeData(wb, sheet = "Dados", x = df_final_pop)

ultima_linha_dados <- nrow(df_final_pop) + 1
writeData(wb, "Dados", x = "Nota metodológica:", startCol = 1, startRow = ultima_linha_dados + 2)
writeData(
  wb,
  "Dados",
  x = "Populações municipais de 2000, 2010 e 2020: Censo Demográfico (IBGE). Demais anos, estimativas.",
  startCol = 1,
  startRow = ultima_linha_dados + 3
)

saveWorkbook(wb, file = file.path(DIR_OUTPUT, "populações.xlsx"), overwrite = TRUE)
