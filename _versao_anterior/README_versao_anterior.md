# Top_1_Billboard

O objetivo do trabalho é estimar, para cada década, a duração média e a proporção de artistas mulheres entre as músicas mais escutadas de cada semana (1º lugar da Billboard Hot 100), de modo a comparar como essas características se modificaram ao longo do tempo.

Trabalho da disciplina ME430 – Técnicas de Amostragem.

## Plano amostral (resumo)

| | |
|---|---|
| População-alvo | Todas as semanas da Billboard Hot 100 de 04/08/1958 a 17/10/2026 (N = 3.560) |
| Unidade elementar | Semana, representada pela música em 1º lugar |
| Variáveis | Duração da música (s) e gênero do artista principal |
| Estratos | 8 períodos: 1958–59, décadas de 1960 a 2010, 2020–26 |
| Seleção | AAS sem reposição, independente em cada estrato |
| Margem de erro | 10 s (duração) e 10 p.p. (proporção), por período, com 95% de confiança |

Os dados de duração e gênero são coletados **apenas para as semanas sorteadas**.

## Estrutura

```
dados/
  brutos/        top_hits_number_one.csv — lista das semanas (original, não editar)
  processados/   quadro_amostral.csv — quadro limpo, uma linha por semana
  amostras/      semanas sorteadas e dados coletados para elas
scripts/
  01_quadro_e_piloto.Rmd   monta o quadro amostral e sorteia a amostra piloto
relatorio/       texto final do trabalho
```

## Como reproduzir

Abra cada script da pasta `scripts/` no RStudio e clique em *Knit*, na ordem da numeração. Os sorteios usam semente fixa, então o resultado é sempre o mesmo.

Pacotes necessários: `dplyr`, `readr`, `knitr`.
