# Objetivo: Preparar base com população urbana e rural municipal (2000, 2010 e 2022)

rm(list = ls())

# Pacotes ----
library(dplyr)
library(tidyr)
library(sidrar)

# Caminhos ----
DIR_RAIZ <- normalizePath(file.path(getwd(), ".."), winslash = "/", mustWork = FALSE)
DIR_RAW <- file.path(DIR_RAIZ, "raw_data")
dir.create(DIR_RAW, showWarnings = FALSE, recursive = TRUE)

# Censo Demográfico 2022 ----
populacao_2022 <- get_sidra(api = "/t/9923/n6/all/v/allxp/p/all/c1/all")

pop_2022 <- populacao_2022 |>
  select(`Município (Código)`, `Município`, Valor, `Situação do domicílio`) |>
  pivot_wider(
    names_from = `Situação do domicílio`,
    values_from = Valor
  ) |>
  rename(
    poptot_2022 = Total,
    popurb_2022 = Urbana,
    poprur_2022 = Rural,
    codmun = `Município (Código)`,
    nome_mun = `Município`
  ) |>
  select(nome_mun, codmun, popurb_2022, poprur_2022)

# Censo Demográfico 2010 ----
populacao_2010 <- get_sidra(api = "/t/1378/n6/all/v/allxp/p/all/c1/all/c2/0/c287/0/c455/0")

pop_2010 <- populacao_2010 |>
  select(`Município (Código)`, Valor, `Situação do domicílio`) |>
  pivot_wider(
    names_from = `Situação do domicílio`,
    values_from = Valor
  ) |>
  rename(
    poptot_2010 = Total,
    popurb_2010 = Urbana,
    poprur_2010 = Rural,
    codmun = `Município (Código)`
  ) |>
  select(codmun, popurb_2010, poprur_2010)

# Censo Demográfico 2000 ----
populacao_2000 <- get_sidra(api = "/t/202/n6/all/u/y/v/allxp/p/2000/c2/0/c1/all")

pop_2000 <- populacao_2000 |>
  select(`Município (Código)`, Valor, `Situação do domicílio`) |>
  pivot_wider(
    names_from = `Situação do domicílio`,
    values_from = Valor
  ) |>
  rename(
    poptot_2000 = Total,
    popurb_2000 = Urbana,
    poprur_2000 = Rural,
    codmun = `Município (Código)`
  ) |>
  select(codmun, popurb_2000, poprur_2000)

# Consolidar ----
popmun_urb_rur <- pop_2022 |>
  left_join(pop_2010, by = "codmun") |>
  left_join(pop_2000, by = "codmun")

# Salvar ----
saveRDS(popmun_urb_rur, file = file.path(DIR_RAW, "popmun_urb_rur.rds"))
