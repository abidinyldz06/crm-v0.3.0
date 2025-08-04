param(
  [string]$SettingsPath = "c:\Users\LEGION\AppData\Roaming\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json"
)

$ErrorActionPreference = "Stop"

function Ensure-McpServersObject {
  param([Parameter(Mandatory=$true)] [psobject]$Root)
  if ($null -eq $Root.mcpServers) {
    $Root | Add-Member -MemberType NoteProperty -Name mcpServers -Value ([ordered]@{}) -Force
  }
}

function Upsert-GitHubMcpServer {
  param(
    [Parameter(Mandatory=$true)] [psobject]$Root,
    [Parameter(Mandatory=$true)] [string]$ServerKey
  )

  $entry = [pscustomobject]@{
    command     = "docker"
    args        = @("run","-i","--rm","-e","GITHUB_PERSONAL_ACCESS_TOKEN","ghcr.io/github/github-mcp-server")
    env         = @{ "GITHUB_PERSONAL_ACCESS_TOKEN" = "${input:github_token}" }
    disabled    = $false
    autoApprove = @()
  }

  if ($Root.mcpServers.PSObject.Properties.Name -contains $ServerKey) {
    # Overwrite existing
    $Root.mcpServers | Add-Member -NotePropertyName $ServerKey -NotePropertyValue $entry -Force
  } else {
    # Create new
    $Root.mcpServers | Add-Member -NotePropertyName $ServerKey -NotePropertyValue $entry
  }
}

if (-not (Test-Path -LiteralPath $SettingsPath)) {
  throw "Ayar dosyası bulunamadı: $SettingsPath"
}

$raw = Get-Content -Raw -LiteralPath $SettingsPath
try {
  $obj = $raw | ConvertFrom-Json -ErrorAction Stop
} catch {
  throw "JSON parse hatası. Dosyayı kontrol edin: $SettingsPath. Hata: $($_.Exception.Message)"
}

Ensure-McpServersObject -Root $obj

$serverKey = "github.com/github/github-mcp-server"
Upsert-GitHubMcpServer -Root $obj -ServerKey $serverKey

# Yedek al
$backup = "$SettingsPath.bak"
$raw | Out-File -FilePath $backup -Encoding utf8 -Force

# JSON'u yaz - Out-File kullan
$jsonOut = $obj | ConvertTo-Json -Depth 50
$jsonOut | Out-File -FilePath $SettingsPath -Encoding utf8 -Force

Write-Host "Güncellendi: $SettingsPath"
