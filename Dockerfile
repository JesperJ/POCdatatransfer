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
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Non-root user for security
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

EXPOSE 8080
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DataTransfer.Api.dll"]
