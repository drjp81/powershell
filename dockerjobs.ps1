#Requires -Version 7.0
[CmdletBinding()]
param(
    [string]  $BuilderName = 'cibuilder',
    [string]  $Image       = 'drjp81/powershell:latest',
    [string]  $Platforms   = 'linux/amd64,linux/arm64,linux/arm/v7',
    [string]  $Dockerfile  = 'dockerfile',
    [switch]  $NoPush
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- 1. QEMU multi-arch binfmt handlers ---
Write-Host '==> Registering QEMU binfmt handlers...' -ForegroundColor Cyan
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
if ($LASTEXITCODE -ne 0) { throw 'QEMU setup failed.' }

# --- 2. Ensure buildx builder exists (idempotent) ---
$existing = docker buildx ls --format '{{.Name}}' 2>$null
if ($existing -contains $BuilderName) {
    Write-Host "==> Builder '$BuilderName' already exists — reusing." -ForegroundColor Yellow
    docker buildx use $BuilderName
} else {
    Write-Host "==> Creating builder '$BuilderName'..." -ForegroundColor Cyan
    docker buildx create --name $BuilderName --driver docker-container --use
    if ($LASTEXITCODE -ne 0) { throw "Failed to create builder '$BuilderName'." }
}

# --- 3. Bootstrap and verify ---
Write-Host '==> Bootstrapping builder...' -ForegroundColor Cyan
docker buildx inspect --bootstrap
if ($LASTEXITCODE -ne 0) { throw 'Builder bootstrap failed.' }

# --- 4. Build (and optionally push) ---
Write-Host "==> Building: $Image  platforms: $Platforms" -ForegroundColor Cyan
$buildArgs = @(
    'buildx', 'build',
    "--platform=$Platforms",
    '-f', $Dockerfile,
    '-t', $Image,
    '--progress=plain'
)
if (-not $NoPush) { $buildArgs += '--push' }
$buildArgs += '.'

docker @buildArgs
if ($LASTEXITCODE -ne 0) { throw "docker buildx build failed (exit $LASTEXITCODE)." }

Write-Host '==> Done.' -ForegroundColor Green