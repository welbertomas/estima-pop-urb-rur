# Objetivo: Estimativas das populações municipais por condição de domicilio (urbano ou rural)

# Os Censos Demográficos de 2000, 2010 e 2022 permitem observar população urbana
# e rural. Os períodos entre os censos possuem estimativas de população total. Nesse caso,
# o objetivo é estimar a urbanização para cada ano no período. Cálculo será por taxa geométrica
# de crescimento da população urbana e da população rural entre os censos, para calcular a
# taxa de urbanização em cada ano e multiplicar pela estimativa realizada pelo IBGE.

rm(list=ls())

# Pacotes ----
library(tidyr)
library(dplyr)
library(readxl)

# Preparar dados ----

# Obter informações municipais de população, população urbana e população rural.
# Dados estão no Sidra

install.packages("sidrar")
library(sidrar)

# Censo Demográfico 2022 (universo) ----
populacao_2022 <- get_sidra(api = "/t/9923/n6/all/v/allxp/p/all/c1/all")

# Organizar (seleciona, pivota e renomeia)
pop_2022 <- populacao_2022 |>
  select(`Município (Código)`, `Município`, Ano, Valor, `Situação do domicílio`) |>
  pivot_wider(
    names_from = `Situação do domicílio`,
    values_from = Valor
  ) |>
  rename(
    `poptot_2022` = Total,
    `popurb_2022` = Urbana,
    `poprur_2022` = Rural,
    `codmun` = `Município (Código)`,
    `nome_mun` = `Município`
  ) |>
  select(nome_mun, codmun, popurb_2022, poprur_2022)


# Censo Demográfico 2010 (universo) ----
populacao_2010 <- get_sidra(api = "/t/1378/n6/all/v/allxp/p/all/c1/all/c2/0/c287/0/c455/0")

pop_2010 <- populacao_2010 |>
  select(`Município (Código)`, `Município`, Ano, Valor, `Situação do domicílio`) |>
  pivot_wider(
    names_from = `Situação do domicílio`,
    values_from = Valor
  ) |>
  rename(
    `poptot_2010` = Total,
    `popurb_2010` = Urbana,
    `poprur_2010` = Rural,
    `codmun` = `Município (Código)`,
    `nome_mun` = `Município`
  ) |>
  select(codmun, popurb_2010, poprur_2010)


# Censo Demográfico 2000 (universo) ----
populacao_2000 <- get_sidra(api = "/t/202/n6/all/u/y/v/allxp/p/2000/c2/0/c1/all")

pop_2000 <- populacao_2000 |>
  select(`Município (Código)`, `Município`, Ano, Valor, `Situação do domicílio`)  |>
  pivot_wider(
    names_from = `Situação do domicílio`,
    values_from = Valor
  ) |>
  rename(
    poptot_2000 = Total,
    popurb_2000 = Urbana,
    poprur_2000 = Rural,
    codmun = `Município (Código)`,
    `nome_mun` = `Município`
  ) |> 
  select(codmun, popurb_2000, poprur_2000)

# Organizar em um dataframe -----

popmun_urb_rur <- pop_2022 |>
  left_join(pop_2010, by = "codmun") |>
  left_join(pop_2000, by = "codmun")

# remover tudo menos o dataframe de interesse
rm(list = setdiff(ls(), "popmun_urb_rur"))

# salvar 
saveRDS(popmun_urb_rur, file = path.file(DIR_RAW,"popmun_urb_rur.rds"))
