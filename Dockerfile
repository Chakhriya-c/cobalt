FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# --------------------
# Build stage
# --------------------
FROM base AS build
WORKDIR /app

COPY . .

RUN corepack enable
RUN apt-get update && apt-get install -y \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile

RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

# --------------------
# Runtime stage
# --------------------
FROM base AS api
WORKDIR /app

COPY --from=build /prod/api /app

EXPOSE 9000

# ✅ IMPORTANT: let the package decide entrypoint
CMD ["npm", "start"]
