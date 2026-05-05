# DataTransfer Service

.NET 8 Web API running in Docker. Database is managed externally.

## Project structure

```
POC-datatransfer/
  src/
    DataTransfer.Api/          # .NET Web API project
  Dockerfile                   # Multi-stage build
  docker-compose.yml           # Base (always used)
  docker-compose.dev.yml       # Dev overrides
  docker-compose.staging.yml   # Staging overrides
  docker-compose.prod.yml      # Prod overrides
  .env.example                 # Environment variable template
  .dockerignore
  infra/                       # → lives in its own repo in production
    docker-compose.yml         # Traefik reverse proxy
    traefik/traefik.yml
    .env.example
```

## Getting started

### 1. Prerequisites

- Docker + Docker Compose v2
- The `traefik-public` Docker network (created by the infra repo, see below)

### 2. Copy and fill in environment variables

```bash
cp .env.example .env
# Edit .env with real values
```

### 3. Start

**Dev** (local ports, no TLS):
```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up
```
API is available at http://localhost:5000

**Staging**:
```bash
docker compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```

**Production**:
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 4. Build a tagged image

```bash
docker build -t datatransfer-api:1.0.0 .
TAG=1.0.0 docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Infra repo (Traefik)

The `infra/` folder shows the structure of the shared infra repo.  
In production, clone it separately and start Traefik first:

```bash
cd infra
cp .env.example .env   # set ACME_EMAIL
docker compose up -d
```

This creates the `traefik-public` Docker network that all service repos attach to.  
Traefik picks up new services automatically via Docker labels — no proxy config changes needed when deploying a new service.

## Domains (update before deploy)

| Environment | Domain |
|-------------|--------|
| Staging     | `staging.datatransfer.poc.internal` |
| Production  | `datatransfer.poc.internal` |

Update the `Host(...)` labels in `docker-compose.staging.yml` and `docker-compose.prod.yml`.
