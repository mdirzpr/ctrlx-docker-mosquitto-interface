FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env

# Create working folder and install dependencies
WORKDIR /app
COPY *.csproj ./
COPY [".nuget/packages/", "/app/localNugetPackages/"]
RUN dotnet restore -s https://api.nuget.org/v3/index.json -s localNugetPackages --verbosity n

# Copy app files and build app
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/sdk:6.0
WORKDIR /app
COPY --from=build-env /app/out .

# Run the service
ENTRYPOINT ["dotnet", "etherCAT.interface.dll"]