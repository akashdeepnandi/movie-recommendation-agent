FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Install uv / uvx
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install OpenCode
RUN curl -fsSL https://opencode.ai/install | bash

ENV PATH="/root/.local/bin:/root/.opencode/bin:$PATH"

WORKDIR /app

COPY opencode.json .
COPY run-agent.sh .
COPY .opencode/ .opencode/

RUN chmod +x \
    /app/run-agent.sh \
    /app/.opencode/skills/movie-recommendation/scripts/enrich_movies.sh

CMD ["./run-agent.sh"]
