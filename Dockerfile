# ── Stage 1: build ──────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY ["src/DataTransfer.Api/DataTransfer.Api.csproj", "src/DataTransfer.Api/"]
RUN dotnet restore "src/DataTransfer.Api/DataTransfer.Api.csproj"

COPY . .
WORKDIR "/src/src/DataTransfer.Api"
RUN dotnet build "DataTransfer.Api.csproj" -c Release -o /app/build

# ── Stage 2: publish ─────────────────────────────────────────────────────────
FROM build AS publish
RUN dotnet publish "DataTransfer.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# ── Stage 3: runtime ─────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:10.0-alpine AS final
WORKDIR /app

COPY --from=publish /app/publish .

# aspnet images ship with a built-in non-root user (UID 1654)
USER $APP_UID

EXPOSE 8080
ENTRYPOINT ["dotnet", "DataTransfer.Api.dll"]
