# =============================================================================
# 02 – Sorteio da amostra piloto
#
# Entrada: dados/quadro_amostral.csv   (gerado pelo script 01)
# Saída  : dados/amostras/piloto.csv   (semanas sorteadas, colunas vazias para a coleta)
#
# AAS sem reposição de N_PILOTO semanas em cada período, sorteios independentes.
# As semanas do piloto serão aproveitadas na amostra final.
# =============================================================================

# ---- Bloco 1: parâmetros e leitura do quadro --------------------------------
library(dplyr)
library(readr)

N_PILOTO <- 30     # semanas sorteadas por período
SEMENTE  <- 2026   # semente do sorteio (reprodutibilidade)

# Todas as colunas como texto ("c"), exceto ano (inteiro, "i"): sem isso o R
# lê "1950s" como o número 1950.
quadro <- read_csv("dados/quadro_amostral.csv",
                   col_types = cols(.default = "c", ano = "i"))

# ---- Bloco 2: o sorteio ------------------------------------------------------
# group_by(periodo) separa os 8 estratos; slice_sample sorteia dentro de cada um.
set.seed(SEMENTE)
piloto <- quadro %>%
  group_by(periodo) %>%
  slice_sample(n = N_PILOTO, replace = FALSE) %>%
  ungroup() %>%
  arrange(periodo, date)

count(piloto, periodo)   # deve dar 30 em cada período

# ---- Bloco 3: preparar a planilha de coleta e salvar ------------------------
# duracao_s: duração em segundos | genero: Feminino, Masculino ou Grupo/Outro
# fonte: de onde veio a informação (MusicBrainz, Spotify, Wikipedia...)
piloto <- piloto %>%
  mutate(duracao_s = NA_real_, genero = NA_character_, fonte = NA_character_)

dir.create("dados/amostras", showWarnings = FALSE)
write_csv(piloto, "dados/amostras/piloto.csv", na = "")
