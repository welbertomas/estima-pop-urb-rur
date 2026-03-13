# Objetivo: Estimar população municipal por situação do domicílio (urbano/rural)
# para anos intercensitários entre 2000-2010 e 2010-2022.

rm(list = ls())

library(dplyr)
library(tidyr)
library(openxlsx)

# Caminhos ----
DIR_RAIZ <- normalizePath(file.path(getwd(), ".."), winslash = "/", mustWork = FALSE)
DIR_RAW <- file.path(DIR_RAIZ, "raw_data")
DIR_OUTPUT <- file.path(DIR_RAIZ, "output")
dir.create(DIR_OUTPUT, showWarnings = FALSE, recursive = TRUE)

# Carregar dados ----
estima_pop <- readRDS(file.path(DIR_RAW, "popmun_urb_rur.rds"))

# Grandes regiões ----
estima_pop <- estima_pop |>
  mutate(
    codigo_GR = as.integer(codmun) %/% 1000000,
    nome_GR = case_when(
      codigo_GR == 1 ~ "Norte",
      codigo_GR == 2 ~ "Nordeste",
      codigo_GR == 3 ~ "Sudeste",
      codigo_GR == 4 ~ "Sul",
      codigo_GR == 5 ~ "Centro-Oeste",
      TRUE ~ NA_character_
    )
  )

# Taxas geométricas anuais ----
# Fórmula: taxa = (pop_final / pop_inicial)^(1/n_anos) - 1
estima_pop <- estima_pop |>
  mutate(
    taxa_cresc_urb_00_10 = (popurb_2010 / popurb_2000)^(1 / 10) - 1,
    taxa_cresc_urb_10_22 = (popurb_2022 / popurb_2010)^(1 / 12) - 1,
    taxa_cresc_rur_00_10 = (poprur_2010 / poprur_2000)^(1 / 10) - 1,
    taxa_cresc_rur_10_22 = (poprur_2022 / poprur_2010)^(1 / 12) - 1
  )

# Estimar séries anuais ----
for (ano in 2001:2009) {
  estima_pop[[paste0("popurb_", ano)]] <- round(
    estima_pop$popurb_2000 * (1 + estima_pop$taxa_cresc_urb_00_10)^(ano - 2000)
  )
  estima_pop[[paste0("poprur_", ano)]] <- round(
    estima_pop$poprur_2000 * (1 + estima_pop$taxa_cresc_rur_00_10)^(ano - 2000)
  )
}

for (ano in 2011:2021) {
  estima_pop[[paste0("popurb_", ano)]] <- round(
    estima_pop$popurb_2010 * (1 + estima_pop$taxa_cresc_urb_10_22)^(ano - 2010)
  )
  estima_pop[[paste0("poprur_", ano)]] <- round(
    estima_pop$poprur_2010 * (1 + estima_pop$taxa_cresc_rur_10_22)^(ano - 2010)
  )
}

# Formato longo ----
estima_pop_urbana_emp <- estima_pop |>
  select(nome_mun, codmun, nome_GR, codigo_GR, starts_with("popurb_")) |>
  pivot_longer(
    cols = starts_with("popurb_"),
    names_to = "ano",
    values_to = "populacao_urbana"
  ) |>
  mutate(ano = as.integer(sub("popurb_", "", ano))) |>
  arrange(codmun, ano)

estima_pop_rural_emp <- estima_pop |>
  select(nome_mun, codmun, nome_GR, codigo_GR, starts_with("poprur_")) |>
  pivot_longer(
    cols = starts_with("poprur_"),
    names_to = "ano",
    values_to = "populacao_rural"
  ) |>
  mutate(ano = as.integer(sub("poprur_", "", ano))) |>
  arrange(codmun, ano)

# Consolidar ----
df_final_pop <- estima_pop_urbana_emp |>
  left_join(
    estima_pop_rural_emp |> select(codmun, ano, populacao_rural),
    by = c("codmun", "ano")
  )

# Salvar ----
wb <- createWorkbook()
addWorksheet(wb, "Dados")
writeData(wb, sheet = "Dados", x = df_final_pop)
saveWorkbook(wb, file = file.path(DIR_OUTPUT, "Populacoes.xlsx"), overwrite = TRUE)
