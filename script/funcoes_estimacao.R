# Funções compartilhadas para estimativa populacional municipal urbano/rural.

library(dplyr)
library(tidyr)

adicionar_regioes_e_taxas <- function(base) {
  base |>
    mutate(
      codigo_GR = as.integer(codmun) %/% 1000000,
      nome_GR = case_when(
        codigo_GR == 1 ~ "Norte",
        codigo_GR == 2 ~ "Nordeste",
        codigo_GR == 3 ~ "Sudeste",
        codigo_GR == 4 ~ "Sul",
        codigo_GR == 5 ~ "Centro-Oeste",
        TRUE ~ NA_character_
      ),
      taxa_cresc_urb_00_10 = (popurb_2010 / popurb_2000)^(1 / 10) - 1,
      taxa_cresc_urb_10_22 = (popurb_2022 / popurb_2010)^(1 / 12) - 1,
      taxa_cresc_rur_00_10 = (poprur_2010 / poprur_2000)^(1 / 10) - 1,
      taxa_cresc_rur_10_22 = (poprur_2022 / poprur_2010)^(1 / 12) - 1
    )
}

adicionar_anos_intercensitarios <- function(base) {
  for (ano in 2001:2009) {
    base[[paste0("popurb_", ano)]] <- round(
      base$popurb_2000 * (1 + base$taxa_cresc_urb_00_10)^(ano - 2000)
    )
    base[[paste0("poprur_", ano)]] <- round(
      base$poprur_2000 * (1 + base$taxa_cresc_rur_00_10)^(ano - 2000)
    )
  }

  for (ano in 2011:2021) {
    base[[paste0("popurb_", ano)]] <- round(
      base$popurb_2010 * (1 + base$taxa_cresc_urb_10_22)^(ano - 2010)
    )
    base[[paste0("poprur_", ano)]] <- round(
      base$poprur_2010 * (1 + base$taxa_cresc_rur_10_22)^(ano - 2010)
    )
  }

  base
}

preparar_estimativas <- function(base) {
  base |>
    adicionar_regioes_e_taxas() |>
    adicionar_anos_intercensitarios()
}

montar_bases_longas <- function(base) {
  estima_pop_urbana_emp <- base |>
    select(nome_mun, codmun, nome_GR, codigo_GR, starts_with("popurb_")) |>
    pivot_longer(
      cols = starts_with("popurb_"),
      names_to = "ano",
      values_to = "populacao_urbana"
    ) |>
    mutate(ano = as.integer(sub("popurb_", "", ano))) |>
    arrange(codmun, ano)

  estima_pop_rural_emp <- base |>
    select(nome_mun, codmun, nome_GR, codigo_GR, starts_with("poprur_")) |>
    pivot_longer(
      cols = starts_with("poprur_"),
      names_to = "ano",
      values_to = "populacao_rural"
    ) |>
    mutate(ano = as.integer(sub("poprur_", "", ano))) |>
    arrange(codmun, ano)

  list(
    urbana = estima_pop_urbana_emp,
    rural = estima_pop_rural_emp
  )
}
