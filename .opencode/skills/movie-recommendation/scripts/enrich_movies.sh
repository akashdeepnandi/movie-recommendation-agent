#!/usr/bin/env bash
set -euo pipefail
echo "ARGS: $#" "$@" >&2

: "${TMDB_API_TOKEN:?TMDB_API_TOKEN is required}"

for movie_id in "$@"; do
  echo "Fetching TMDB ID: $movie_id" >&2

  response=$(curl -sS \
  --retry 3 \
  --retry-all-errors \
  --retry-delay 1 \
  "https://api.themoviedb.org/3/movie/${movie_id}?append_to_response=credits" \
    -H "Authorization: Bearer ${TMDB_API_TOKEN}")

  echo "$response" | jq -e '.id' >/dev/null || {
    echo "ERROR: Failed to fetch TMDB ID: $movie_id" >&2
    exit 1
  }

  echo "$response"
done |
jq -s '
[
  .[] |
  {
    tmdb_id: .id,
    imdb_id: .imdb_id,
    title: .title,
    overview: .overview,
    genres: [.genres[].name],
    release_date: .release_date,
    runtime: .runtime,
    tmdb_rating: .vote_average,
    vote_count: .vote_count,
    popularity: .popularity,
    tagline: .tagline,
    directors: [
      .credits.crew[]
      | select(.job == "Director")
      | .name
    ],
    cast: [
      .credits.cast
      | sort_by(.order)
      | .[:10][]
      | {
          name: .name,
          character: .character
        }
    ]
  }
]
'
