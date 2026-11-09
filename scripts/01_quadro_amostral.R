# =============================================================================
# 01 – Quadro amostral
#
# Entrada: top_hits_number_one.csv     (lista original das semanas)
# Saída  : dados/quadro_amostral.csv   (uma linha por semana, com o período)
#
# Como rodar: abra o projeto Top_1_Billboard.Rproj e rode linha a linha
# (Ctrl+Enter) ou o script inteiro (Source).
# =============================================================================

# ---- Bloco 1: pacotes e leitura do arquivo ----------------------------------
library(dplyr)   # manipular tabelas
library(readr)   # ler e salvar CSV

bruto <- read_csv("top_hits_number_one.csv", show_col_types = FALSE)

nrow(bruto)   # deve dar 3560

# ---- Bloco 2: corrigir as 10 semanas sem título/artista ---------------------
# O nome da música aparece no link do YouTube da própria linha.
reparos <- tribble(
  ~date,        ~song_fix,                                          ~artist_fix,
  "1958-12-22", "The Chipmunk Song",                                 "The Chipmunks With David Seville",
  "1959-05-11", "The Happy Organ",                                   "Dave \"Baby\" Cortez",
  "1960-11-14", "Georgia On My Mind",                                "Ray Charles",
  "1969-05-10", "Aquarius/Let The Sunshine In (The Flesh Failures)", "The 5th Dimension",
  "1969-10-18", "I Can't Get Next To You",                           "The Temptations",
  "1970-03-21", "Bridge Over Troubled Water",                        "Simon & Garfunkel",
  "1976-12-04", "Tonight's The Night (Gonna Be Alright)",            "Rod Stewart",
  "1977-03-12", "Evergreen (Love Theme From \"A Star Is Born\")",    "Barbra Streisand",
  "1984-12-22", "Like A Virgin",                                     "Madonna",
  "1985-05-11", "Crazy For You",                                     "Madonna"
)

# ---- Bloco 3: montar o quadro ------------------------------------------------
# coalesce(): usa o valor original; se estiver vazio, usa a correção.
# Período: 1987 %/% 10 = 198 -> 198 * 10 = 1980 -> "1980s".
quadro <- bruto %>%
  mutate(date = as.character(date)) %>%
  left_join(reparos, by = "date") %>%
  mutate(song    = coalesce(song, song_fix),
         artist  = coalesce(artist, artist_fix),
         ano     = as.integer(substr(date, 1, 4)),
         periodo = paste0(ano %/% 10 * 10, "s")) %>%
  select(date, ano, periodo, song, artist) %>%
  arrange(date)

# Conferência: nenhum vazio restante e nenhuma semana repetida
stopifnot(!anyNA(quadro$song), !anyNA(quadro$artist), !anyDuplicated(quadro$date))

# ---- Bloco 4: tamanho de cada estrato e salvar ------------------------------
count(quadro, periodo)   # deve bater com: 74, 521, 522, 522, 521, 522, 523, 355

dir.create("dados", showWarnings = FALSE)
write_csv(quadro, "dados/quadro_amostral.csv")
