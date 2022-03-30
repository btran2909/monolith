#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["GgCloudEx.csproj", "."]
RUN dotnet restore "./GgCloudEx.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "GgCloudEx.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "GgCloudEx.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
RUN apt update && apt install wget -y && apt install python3.7 -y && apt install ffmpeg -y \
   && wget https://yt-dl.org/latest/youtube-dl -O /usr/local/bin/youtube-dl && chmod a+x /usr/local/bin/youtube-dl \
   && ln -s /usr/bin/python3.7 /usr/local/bin/python
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "GgCloudEx.dll"]
