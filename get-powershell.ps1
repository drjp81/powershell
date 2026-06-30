#Requires -Version 7.0
$ErrorActionPreference = 'Stop'

# Map Docker TARGETARCH to PowerShell release naming
$arch = switch ($env:TARGETARCH) {
    'amd64' { 'x64'   }
    'arm'   { 'arm32' }
    default { $env:TARGETARCH }
}

Write-Host "Resolving latest PowerShell release for arch: $arch"

$headers = @{ 'User-Agent' = 'github-actions' }
if ($env:GH_AUTH_TOKEN) {
    $headers['Authorization'] = "Bearer $env:GH_AUTH_TOKEN"
}

$release = Invoke-RestMethod `
    -Uri         'https://api.github.com/repos/PowerShell/PowerShell/releases/latest' `
    -ContentType 'application/json' `
    -Headers     $headers

$url = $release.assets.browser_download_url |
    Where-Object { $_ -like "*linux-$arch.tar.gz" } |
    Select-Object -First 1

if (-not $url) {
    Write-Error "No PowerShell release asset found for arch: $arch"
    exit 1
}

Write-Host "Download URL: $url"
New-Item -ItemType Directory -Path /dload -Force | Out-Null
Set-Content -Path /dload/powershellurl.txt -Value $url
exit 0

