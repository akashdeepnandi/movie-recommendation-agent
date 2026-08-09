---
name: movie-recommendation
description: Discover recent English-language Hollywood movies, enrich them with TMDB data, analyze them, and recommend the best candidate.
---

# Movie Recommendation

Execute the following workflow exactly in order.

## Step 1 — Discover Candidates

Use the Wikidata MCP `execute_sparql` tool.

Run this exact query:

```sparql
SELECT ?movie ?imdbId ?tmdbId WHERE {
  ?movie wdt:P31 wd:Q11424 ;
         wdt:P495 wd:Q30 ;
         wdt:P364 wd:Q1860 ;
         wdt:P577 ?releaseDate .

  FILTER(
    ?releaseDate >= (NOW() - "P30D"^^xsd:duration)
    && ?releaseDate <= NOW()
  )

  OPTIONAL { ?movie wdt:P345 ?imdbId . }
  OPTIONAL { ?movie wdt:P4947 ?tmdbId . }
}
ORDER BY DESC(?releaseDate)
LIMIT 5
```

## Step 2 — Enrich Candidates

Use the movie enrichment script:

```bash
TMDB_API_TOKEN="$TMDB_API_TOKEN" \
.opencode/skills/movie-recommendation/scripts/enrich_movies.sh \
<TMDB_ID_1> <TMDB_ID_2> <TMDB_ID_3> <TMDB_ID_4> <TMDB_ID_5>
```

Replace the placeholders with the TMDB IDs returned by Step 1.

### Important

- The script is responsible for managing the TMDB API interaction.
- Do not inspect, print, echo, transform, or otherwise expose `TMDB_API_TOKEN`.
- Do not run commands such as `echo $TMDB_API_TOKEN`, `env`, `printenv`, or equivalent commands.
- Do not construct TMDB API requests yourself.
- Do not call the TMDB API directly.
- Pass the environment variable to the script exactly as shown above.
- Do not modify the script arguments.
- Pass all available TMDB IDs in a single invocation.
- Treat the script's JSON output as the authoritative movie data for this workflow.

If the script returns fewer movie records than candidates because some TMDB requests failed, continue with the successfully enriched movies. Do not invent missing movie data.

**NOTE**: If no data is returned, then just skip next steps with no recommendation

## Step 3 — Analyze

Analyze the JSON returned by the enrichment script.

For the current version of this workflow, the selection criterion is:

> Recommend the movie with the highest `tmdb_rating`.

Use `vote_count` as supporting context when explaining the recommendation.

Do not use popularity as the primary selection criterion.

Do not invent ratings, cast, directors, synopsis, or other movie information that is not present in the enrichment output.

## Step 4 — Recommend

Select exactly one movie from the successfully enriched candidates.

The final response MUST be valid JSON.

Do not include Markdown.
Do not include code fences.
Do not include commentary before or after the JSON.
Do not include tool output.
Do not include the enriched movie dataset.

Return exactly this structure:

```json
{
  "status": "success",
  "recommendation": {
    "title": "<movie title>",
    "tmdb_id": <TMDB ID>,
    "tmdb_rating": <TMDB rating>,
    "vote_count": <vote count>,
    "reason": "<short explanation>"
  }
}
```

Keep the explanation concise.

## Workflow Constraints

- Follow the steps in order.
- Do not skip candidate discovery.
- Do not skip TMDB enrichment.
- Do not perform additional web searches.
- Do not use IMDb or other external movie APIs.
- Do not expose API credentials.
- Do not invent missing data.
- Do not alter the Wikidata candidate query.
- Do not alter the enrichment script's arguments.
