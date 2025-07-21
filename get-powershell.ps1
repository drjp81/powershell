switch ($env:TARGETARCH) { 
    "amd64" { $token = "x64" } 
    "arm" { $token = "arm32" } 
    default { $token = $env:TARGETARCH } 
} 
Get-ChildItem env:
start-sleep -Seconds 5
#if (!$token) { $token = "x64" }
Write-Host "Downloading PowerShell Core $token"
#Start-Sleep -Seconds 5
$vers = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest" -ContentType -application/json -Headers $headers
#$vers
$headers = @{
    Authorization = "Bearer $env:GH_AUTH_TOKEN"
    'User-Agent'  = 'github-actions'
}
$url = ($vers | Where-Object {$_.prerelease -eq $false }).assets.browser_download_url | Where-Object {$_ -like "*linux-$token.tar.gz"} | Select-Object -First 1
write-host ("Setting download to:" + $url)
if ($null -eq $url )
{ write-host "No PowerShell Core $token release found" 
exit -1}
else {
    mkdir /dload -p
    Set-Content -path /dload/powershellurl.txt -Value $url
    exit 0
}

