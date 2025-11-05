# Multi-stage build for .NET 8

# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
# WORKDIR /src

COPY ["WeatherApi.csproj", "./"]
RUN dotnet restore "WeatherApi.csproj"

COPY . .
RUN dotnet build "WeatherApi.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "WeatherApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080

COPY --from=publish /app/publish .

USER $APP_UID

ENTRYPOINT ["dotnet", "WeatherApi.dll"]
