# Duração e presença feminina entre os 1º lugares da Billboard Hot 100 (1960–2026)

Trabalho da disciplina **ME430 – Técnicas de Amostragem**.

O objetivo é estimar, para cada década, a **duração média** das músicas que chegaram
ao 1º lugar da Billboard Hot 100 e a **proporção de semanas com uma artista mulher**
no topo, e comparar como essas características mudaram ao longo do tempo.

## Desenho amostral

- **Unidade elementar:** a semana da parada (uma música que ficou 10 semanas no topo conta 10 vezes).
- **Quadro amostral:** a lista completa das 3.560 semanas da parada, de 04/08/1958 a 17/10/2026.
- **Plano:** amostragem aleatória estratificada por período, com AAS sem reposição em cada estrato.
- **Planejamento:** uma amostra piloto indicou 656 semanas para margens de 10 s e 10 p.p.; com
  um orçamento de 240 semanas, uma simulação de Monte Carlo comparou as alocações proporcional,
  de Neyman e igual, e a **alocação igual** foi escolhida por proteger os períodos menores.
- **Etapa 1:** 30 semanas por período (semente 2026), resultados apresentados em sala.
- **Etapa 2:** mais 30 semanas por período (semente 2027), com a duração recoletada pela
  versão single. A análise final usa 60 semanas por período, de 1960 a 2026.

## Principais resultados

- A duração média cresceu de cerca de **2:44** nos anos 1960 até **4:31** nos anos 1990 e caiu
  para **3:22** em 2020–2026.
- A proporção de semanas com artista mulher passou de **18,9%** em 1960–1989 para **39,1%**
  em 1990–2026 (diferença de 20,2 p.p., IC 95% de 12,2 a 28,2 p.p.).

Os detalhes, as tabelas e os gráficos estão no relatório.

## Estrutura do projeto

```
Top_1_Billboard/
├── relatorio.Rmd          relatório: código do sorteio, da simulação e das estimativas
├── relatorio.html         relatório compilado
├── referencias.bib        referências bibliográficas
├── _bookdown.yml          configuração das legendas (Figura / Tabela)
├── Top_1_Billboard.Rproj  projeto do RStudio
└── dados/
    ├── top_hits_number_one.csv     quadro amostral (3.560 semanas)
    ├── semanas_sorteadas.csv       480 semanas sorteadas nas duas etapas, com duração e gênero
    └── dados_enriquecidos_api.rds  dados automáticos da API MusicBrainz (piloto e simulação)
```

Na planilha `semanas_sorteadas.csv`, a coluna `etapa_sorteio` indica a etapa em que a semana
foi sorteada (1 ou 2), `analisado` indica as semanas de 1960–2026 usadas na análise final e
`duracao_etapa1_s` guarda a duração da coleta original da etapa 1.

## Como reproduzir

1. Abra `Top_1_Billboard.Rproj` no RStudio.
2. Instale os pacotes, se necessário:
   ```r
   install.packages(c("rmarkdown", "bookdown", "knitr", "dplyr", "readr", "purrr", "tidyr", "ggplot2"))
   ```
3. Abra `relatorio.Rmd` e clique em **Knit**.

Todos os números do texto são calculados pelo próprio código, e as sementes fixas garantem
que o sorteio e a simulação produzam sempre os mesmos resultados. A simulação de Monte Carlo
leva alguns minutos na primeira compilação.

## Autores

Dominique, Fernanda, Isabela Diniz Cia e Matheus.
