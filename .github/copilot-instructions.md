# DataTransfer API — Workspace Instructions

## Architecture

Single .NET 10 Web API (`src/DataTransfer.Api/`) deployed as a Docker container behind a Traefik reverse proxy. The database is **external** — never managed by this repo's compose files.

Key files:
- [src/DataTransfer.Api/Program.cs](../src/DataTransfer.Api/Program.cs) — app bootstrap, includes `/health` endpoint
- [Dockerfile](../Dockerfile) — multi-stage build (sdk:10.0 → aspnet:10.0), runs as non-root `appuser`
- [docker-compose.yml](../docker-compose.yml) — base config, always combined with an env override
- `infra/` — present for local convenience only; lives in its own repo in production

## Build & Run

Docker is the primary interface — no local `dotnet` tooling required.

```bash
# Dev (local port 5000, no TLS, no external Traefik network needed)
docker compose -f docker-compose.yml -f docker-compose.dev.yml up

# Staging
docker compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# Production
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Build a tagged image
docker build -t datatransfer-api:1.0.0 .
TAG=1.0.0 docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

> **Never run `docker-compose.yml` alone** — it is a base file that requires an env-specific override.

## Environment Variables

Each environment resolves its env file differently:

| Env | Env file location |
|-----|-------------------|
| Dev | `.env.dev` (local, gitignored) |
| Staging | `/etc/datatransfer/.env.staging` (on host) |
| Production | `/etc/datatransfer/.env.prod` (on host) |

Env files are never committed. Copy the appropriate `.env.*.example` file and fill in values:

```bash
cp .env.dev.example .env.dev
```

Key variables: `ASPNETCORE_ENVIRONMENT`, `TAG`, `DATABASE_CONNECTION_STRING`.

## Conventions

- **Nullable reference types** and **implicit usings** are enabled — do not use `#nullable disable` or redundant `using` directives.
- **Health check**: `GET /health` is mapped in `Program.cs` and used by Docker's healthcheck. Keep it available.
- **Traefik network**: dev compose overrides `traefik-public` to a local bridge; staging/prod require the external `traefik-public` network to exist on the host.
- **C# namespace**: `DataTransfer.Api` — matches `<RootNamespace>` in the csproj.
