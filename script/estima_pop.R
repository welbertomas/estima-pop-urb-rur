# Objetivo: Estimativas de população por situação do domicílio (urbano ou rural) entre
# censos de 2000 a 2022.

rm(list=ls())

library(tidyverse)
library(dplyr)
library(openxlsx)

# Caminho ----
DIR_RAIZ   <- normalizePath("..", winslash = "/", mustWork = FALSE)
DIR_RAW    <- file.path(DIR_RAIZ, "data_raw")
DIR_OUTPUT <- file.path(DIR_RAIZ, "output")

# Carregar dados ----
estima_pop <- readRDS(file.path(DIR_RAW,"populacao_urb_rur.rds"))

# Calcular taxas de crescimento anual geométrica ----

# Urbana entre 2000 e 2010
estima_pop$taxa_cresc_urb_00_10 <- (estima_pop$popurb_2010 / estima_pop$popurb_2000)^(1/10) - 1

# Urbana entre 2010 e 2022
estima_pop$taxa_cresc_urb_10_22 <- (estima_pop$popurb_2022 / estima_pop$popurb_2010)^(1/12) - 1

# Rural entre 2000 e 2010
estima_pop$taxa_cresc_rur_00_10 <- (estima_pop$poprur_2010 / estima_pop$poprur_2000)^(1/10) - 1

# Rural entre 2010 e 2022
estima_pop$taxa_cresc_rur_10_22 <- (estima_pop$poprur_2022 / estima_pop$poprur_2010)^(1/12) - 1


# Calcular populações -----

# Urbana entre 2000 e 2010
for (ano in 2001:2009) {
  nome_coluna <- paste0("popurb_", ano)
  estima_pop[[nome_coluna]] <- round(
    estima_pop$popurb_2000 * ((1 + estima_pop$taxa_cresc_urb_00_10)^(ano-2000)))
}

# Urbana entre 2010 e 2022
for (ano in 2011:2022) {
  nome_coluna <- paste0("popurb_", ano)
  estima_pop[[nome_coluna]] <- round(
    estima_pop$popurb_2010 * ((1 + estima_pop$taxa_cresc_urb_10_22)^(ano-2010)))
}

# Rural entre 2000 e 2010
for (ano in 2001:2009) {
  nome_coluna <- paste0("poprur_", ano)
  estima_pop[[nome_coluna]] <- round(
    estima_pop$poprur_2000 * ((1 + estima_pop$taxa_cresc_rur_00_10)^(ano-2000)))
}

# Rural entre 2010 e 2022
for (ano in 2011:2022) {
  nome_coluna <- paste0("poprur_", ano)
  estima_pop[[nome_coluna]] <- round(
    estima_pop$poprur_2010 * ((1 + estima_pop$taxa_cresc_rur_10_22)^(ano-2010)))
}


# Manter apenas colunas de população urbana ----
estima_pop_urbana <- estima_pop |>
  select(nome_mun, codmun, nome_GR, codigo_GR, all_of(sort(grep("^popurb_", names(estima_pop), value = TRUE)))) |>
  arrange(codmun)

estima_pop_rural <- estima_pop |>
  select(nome_mun, codmun, nome_GR, codigo_GR, all_of(sort(grep("^poprur_", names(estima_pop), value = TRUE)))) |>
  arrange(codmun)

# Nomear grandes regiões ----
estima_pop <- estima_pop |>
  mutate(
    codigo_GR = as.integer(codmun) %/% 1000000
  )


estima_pop <- estima_pop |>
  mutate(
    nome_GR = case_when(
      codigo_GR == 1 ~ "Norte",
      codigo_GR == 2 ~ "Nordeste",
      codigo_GR == 3 ~ "Centro-Oeste",
      codigo_GR == 4 ~ "Sudeste",
      codigo_GR == 5 ~ "Sul"
    )
  )

# Fazer dataframe no formato "longo" (painel empilhado) ----

estima_pop_urbana_emp <- estima_pop |>
  select(nome_mun, codmun, nome_GR, codigo_GR, starts_with("popurb_")) |>
  pivot_longer(
    cols = starts_with("popurb_"),
    names_to = "ano",
    values_to = "populacao_urbana"
  ) |>
  mutate(
    ano = as.integer(sub("popurb_", "", ano))
  ) |>
  arrange(codmun, ano)



estima_pop_rural_emp <- estima_pop |>
  select(nome_mun, codmun, nome_GR, codigo_GR, starts_with("poprur_")) |>
  pivot_longer(
    cols = starts_with("poprur_"),
    names_to = "ano",
    values_to = "populacao_rural"
  ) |>
  mutate(
    ano = as.integer(sub("poprur_", "", ano))
  ) |>
  arrange(codmun, ano)

# remover
rm(list = c("estima_pop", "ano", "nome_coluna"))

# Salvar ----
# Pega todos os objetos que começam com "estima_pop_"
populacoes <- ls(pattern = "^estima_pop_")


df_final_pop <- estima_pop_urbana_emp %>%
  left_join(
    estima_pop_rural_emp %>% select(codmun, ano, populacao_rural),
    by = c("codmun", "ano")
  )


wb <- createWorkbook()
addWorksheet(wb, "Dados")
writeData(wb, sheet = "Dados", x = df_final_pop)
saveWorkbook(wb, file = ffile.path(DIR_OUTPUT, "Populações.xlsx"), overwrite = TRUE)



