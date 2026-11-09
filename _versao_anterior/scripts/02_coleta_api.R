# =============================================================================
# 02 – Coleta via API do MusicBrainz (apenas para as semanas sorteadas)
#
# Entrada : dados/amostras/piloto.csv          (semanas sorteadas, colunas vazias)
# Saídas  : dados/processados/cache_api.rds    (respostas da API, para não repetir buscas)
#           dados/amostras/piloto_coletado.csv (amostra com duração e gênero preenchidos)
#           dados/amostras/piloto_faltantes.csv(semanas que precisam de coleta manual)
#
# Baseado no código da Fernanda (me430-amostra-piloto.Rmd), mudando só o que é
# buscado: em vez de todas as músicas da parada, apenas as que foram sorteadas.
#
# Como rodar: abra o projeto Top_1_Billboard.Rproj e clique em "Source".
# A API aceita 1 consulta por segundo, então leva alguns minutos.
# Se parar no meio, é só rodar de novo: o que já foi buscado fica no cache.
# =============================================================================

library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(httr)
library(jsonlite)

# ---------------------------------------------------------------- parâmetros --
ARQ_AMOSTRA   <- "dados/amostras/piloto.csv"
ARQ_COLETADO  <- "dados/amostras/piloto_coletado.csv"
ARQ_FALTANTES <- "dados/amostras/piloto_faltantes.csv"
ARQ_CACHE     <- "dados/processados/cache_api.rds"

# O MusicBrainz pede que o programa se identifique; usamos o endereço do projeto
USER_AGENT <- "ME430-Top1Billboard/1.0 ( https://github.com/isabeladinizcia/Top_1_Billboard )"

# ------------------------------------------------------- funções de consulta --

# Faz uma consulta à API e devolve a resposta em lista (ou NULL se falhar).
# Quando o servidor recusa (ex.: 503 = "muitas consultas") ou a internet falha,
# espera um pouco e tenta de novo, até 4 vezes.
mb_get <- function(endpoint, query, limit = 5, tentativas = 4) {
  for (k in seq_len(tentativas)) {
    Sys.sleep(1.1 * k)  # respeita o limite de 1 consulta/s; espera mais a cada nova tentativa
    r <- tryCatch(
      GET(paste0("https://musicbrainz.org/ws/2/", endpoint),
          query = list(query = query, fmt = "json", limit = limit),
          user_agent(USER_AGENT), timeout(30)),
      error = function(e) NULL)
    if (!is.null(r) && status_code(r) == 200)
      return(fromJSON(content(r, "text", encoding = "UTF-8"), simplifyVector = FALSE))
  }
  NULL
}

# Coloca barra antes de aspas, para não quebrar o texto da busca
esc <- function(x) gsub('(["\\\\])', "\\\\\\1", x)

# "Rihanna featuring Drake" -> "Rihanna"
artista_principal <- function(a) {
  str_trim(str_split(a, regex("\\s+(featuring|feat\\.?)\\s+", ignore_case = TRUE))[[1]][1])
}

# Duração (s): mediana das gravações com título + artista e score >= 90
mb_duracao <- function(song, artist) {
  for (art in unique(c(artist, artista_principal(artist)))) {
    q  <- sprintf('recording:"%s" AND artist:"%s"', esc(song), esc(art))
    js <- mb_get("recording", q, limit = 10)
    if (is.null(js) || length(js$recordings) == 0) next
    len <- map_dbl(js$recordings, function(x)
      if (!is.null(x$score) && x$score >= 90 && !is.null(x$length)) x$length / 1000 else NA_real_)
    len <- len[!is.na(len)]
    if (length(len) > 0) return(median(len))
  }
  NA_real_
}

# Gênero do artista principal: "Feminino", "Masculino", "Grupo/Outro" ou NA
mb_genero <- function(artist) {
  for (art in unique(c(artist, artista_principal(artist)))) {
    js <- mb_get("artist", sprintf('artist:"%s"', esc(art)), limit = 3)
    if (is.null(js) || length(js$artists) == 0) next
    a <- js$artists[[1]]
    if (is.null(a$score) || a$score < 90) next
    g <- a$gender
    if (!is.null(g) && tolower(g) == "female") return("Feminino")
    if (!is.null(g) && tolower(g) == "male")   return("Masculino")
    return("Grupo/Outro")  # bandas, duplas, gênero ausente
  }
  NA_character_
}

# ------------------------------------------------- o que precisa ser buscado --
amostra <- read_csv(ARQ_AMOSTRA, col_types = cols(.default = "c"))

musicas  <- amostra %>% distinct(song, artist)   # cada música uma vez só
artistas <- amostra %>% distinct(artist)

if (file.exists(ARQ_CACHE)) {
  cache <- readRDS(ARQ_CACHE)
} else {
  cache <- list(dur = tibble(song = character(), artist = character(), duracao_s = numeric()),
                gen = tibble(artist = character(), genero = character()))
}

# O que ficou NA numa rodada anterior é buscado de novo (pode ter sido falha de conexão)
cache$dur <- filter(cache$dur, !is.na(duracao_s))
cache$gen <- filter(cache$gen, !is.na(genero))

falta_d <- anti_join(musicas,  cache$dur, by = c("song", "artist"))
falta_g <- anti_join(artistas, cache$gen, by = "artist")
message(nrow(falta_d), " músicas e ", nrow(falta_g), " artistas para buscar (~",
        ceiling((nrow(falta_d) + nrow(falta_g)) * 1.2 / 60), " min)")

# ------------------------------------------------------------------- coleta --
for (i in seq_len(nrow(falta_d))) {
  d <- mb_duracao(falta_d$song[i], falta_d$artist[i])
  cache$dur <- bind_rows(cache$dur, tibble(song = falta_d$song[i], artist = falta_d$artist[i], duracao_s = d))
  if (i %% 20 == 0) { saveRDS(cache, ARQ_CACHE); message("  durações: ", i, "/", nrow(falta_d)) }
}
for (i in seq_len(nrow(falta_g))) {
  g <- mb_genero(falta_g$artist[i])
  cache$gen <- bind_rows(cache$gen, tibble(artist = falta_g$artist[i], genero = g))
  if (i %% 20 == 0) { saveRDS(cache, ARQ_CACHE); message("  gêneros: ", i, "/", nrow(falta_g)) }
}
saveRDS(cache, ARQ_CACHE)

# --------------------------------------------- juntar a coleta com a amostra --
coletado <- amostra %>%
  select(-duracao_s, -genero, -fonte) %>%
  left_join(cache$dur, by = c("song", "artist")) %>%
  left_join(cache$gen, by = "artist") %>%
  mutate(fonte = if_else(!is.na(duracao_s), "MusicBrainz", NA_character_))

write_csv(coletado, ARQ_COLETADO, na = "")

# Precisam de coleta manual: sem duração, sem gênero, ou grupo (classificar à mão)
faltantes <- coletado %>%
  filter(is.na(duracao_s) | is.na(genero) | genero == "Grupo/Outro") %>%
  distinct(song, artist, .keep_all = TRUE) %>%
  select(periodo, song, artist, duracao_s, genero)
write_csv(faltantes, ARQ_FALTANTES, na = "")

# ------------------------------------------------------------------- resumo --
resumo <- coletado %>% group_by(periodo) %>%
  summarise(semanas = n(), com_duracao = sum(!is.na(duracao_s)),
            com_genero = sum(!is.na(genero) & genero != "Grupo/Outro"), .groups = "drop")
print(resumo)
message(nrow(faltantes), " músicas para completar à mão em ", ARQ_FALTANTES)
