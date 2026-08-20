[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetRepository,

    [ValidateSet("balanced", "quality", "economy")]
    [string]$Profile = "balanced",

    [switch]$ProfileOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workflowRoot = Split-Path -Parent $PSScriptRoot
$scaffoldRoot = Join-Path $workflowRoot "scaffold"
$profilePath = Join-Path (Join-Path $workflowRoot "profiles") "$Profile.json"
$roles = @("explorer", "architect", "worker", "reviewer")
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path -LiteralPath $TargetRepository -PathType Container)) {
    throw "Target repository does not exist: $TargetRepository"
}

$targetRoot = (Resolve-Path -LiteralPath $TargetRepository).ProviderPath
$profileData = Get-Content -Raw -LiteralPath $profilePath | ConvertFrom-Json
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Write-Text([string]$Path, [string]$Content) {
    [System.IO.File]::WriteAllText($Path, $Content, $script:utf8NoBom)
}

function Backup-File([string]$Path) {
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $backup = "$Path.lightflow-backup-$script:timestamp"
        Copy-Item -LiteralPath $Path -Destination $backup
        return $backup
    }
    return $null
}

function Set-TopLevelTomlValue([string]$Path, [string]$Key, [string]$Value) {
    $lines = [System.Collections.Generic.List[string]](Get-Content -LiteralPath $Path)
    $firstTable = $lines.Count
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*\[') { $firstTable = $i; break }
    }

    for ($i = $firstTable - 1; $i -ge 0; $i--) {
        if ($lines[$i] -match "^\s*$([regex]::Escape($Key))\s*=") {
            $lines.RemoveAt($i)
            $firstTable--
        }
    }

    $lines.Insert($firstTable, "$Key = $Value")
    Write-Text $Path (($lines -join "`r`n") + "`r`n")
}

function Set-TomlTableValue([string]$Path, [string]$Table, [string]$Key, [string]$Value) {
    $lines = [System.Collections.Generic.List[string]](Get-Content -LiteralPath $Path)
    $header = "[$Table]"
    $start = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq $header) { $start = $i; break }
    }

    if ($start -lt 0) {
        if ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -ne "") { $lines.Add("") }
        $lines.Add($header)
        $start = $lines.Count - 1
    }

    $end = $lines.Count
    for ($i = $start + 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*\[') { $end = $i; break }
    }

    for ($i = $start + 1; $i -lt $end; $i++) {
        if ($lines[$i] -match "^\s*$([regex]::Escape($Key))\s*=") {
            $lines[$i] = "$Key = $Value"
            Write-Text $Path (($lines -join "`r`n") + "`r`n")
            return
        }
    }

    $lines.Insert($end, "$Key = $Value")
    Write-Text $Path (($lines -join "`r`n") + "`r`n")
}

function Merge-AgentInstructions([string]$Destination) {
    $source = Get-Content -Raw -LiteralPath (Join-Path $script:scaffoldRoot "AGENTS.md")
    $begin = "<!-- BEGIN LIGHTFLOW WORKFLOW -->"
    $end = "<!-- END LIGHTFLOW WORKFLOW -->"
    $legacyBegin = "<!-- BEGIN NATURAL DEVELOPMENT WORKFLOW -->"
    $legacyEnd = "<!-- END NATURAL DEVELOPMENT WORKFLOW -->"
    $sourceStart = $source.IndexOf($begin)
    $sourceEnd = $source.IndexOf($end) + $end.Length
    $managed = $source.Substring($sourceStart, $sourceEnd - $sourceStart)

    if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) {
        Copy-Item -LiteralPath (Join-Path $script:scaffoldRoot "AGENTS.md") -Destination $Destination
        return
    }

    Backup-File $Destination | Out-Null
    $current = Get-Content -Raw -LiteralPath $Destination
    $currentStart = $current.IndexOf($begin)
    $currentEndMarker = $current.IndexOf($end)
    if ($currentStart -lt 0 -or $currentEndMarker -lt $currentStart) {
        $currentStart = $current.IndexOf($legacyBegin)
        $currentEndMarker = $current.IndexOf($legacyEnd)
        $currentEndToken = $legacyEnd
    } else {
        $currentEndToken = $end
    }
    if ($currentStart -ge 0 -and $currentEndMarker -ge $currentStart) {
        $currentEnd = $currentEndMarker + $currentEndToken.Length
        $updated = $current.Substring(0, $currentStart) + $managed + $current.Substring($currentEnd)
    } else {
        $updated = $current.TrimEnd() + "`r`n`r`n" + $managed + "`r`n"
    }
    Write-Text $Destination $updated
}

$codexDir = Join-Path $targetRoot ".codex"
$agentsDir = Join-Path $codexDir "agents"
$configPath = Join-Path $codexDir "config.toml"
New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null

if (-not $ProfileOnly) {
    Merge-AgentInstructions (Join-Path $targetRoot "AGENTS.md")

    if (Test-Path -LiteralPath $configPath -PathType Leaf) {
        Backup-File $configPath | Out-Null
    } else {
        Copy-Item -LiteralPath (Join-Path $scaffoldRoot ".codex\config.toml") -Destination $configPath
    }

    Set-TomlTableValue $configPath "agents" "enabled" "true"
    Set-TomlTableValue $configPath "agents" "max_concurrent_threads_per_session" "4"

    foreach ($role in $roles) {
        $destination = Join-Path $agentsDir "$role.toml"
        Backup-File $destination | Out-Null
        Copy-Item -LiteralPath (Join-Path $scaffoldRoot ".codex\agents\$role.toml") -Destination $destination -Force
    }

    $legacyOrchestratorPath = Join-Path $agentsDir "orchestrator.toml"
    if (Test-Path -LiteralPath $legacyOrchestratorPath -PathType Leaf) {
        Backup-File $legacyOrchestratorPath | Out-Null
        Remove-Item -LiteralPath $legacyOrchestratorPath -Force
    }

} elseif (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    throw "Profile-only mode requires an existing Lightflow scaffold: $configPath"
} elseif (Test-Path -LiteralPath (Join-Path $agentsDir "orchestrator.toml") -PathType Leaf) {
    throw "Legacy orchestrator.toml requires one full Lightflow setup run before profile-only mode."
}

$orchestrator = $profileData.orchestrator
Set-TopLevelTomlValue $configPath "model" ('"' + $orchestrator.model + '"')
Set-TopLevelTomlValue $configPath "model_reasoning_effort" ('"' + $orchestrator.reasoning + '"')

foreach ($role in $roles) {
    $agentPath = Join-Path $agentsDir "$role.toml"
    if (-not (Test-Path -LiteralPath $agentPath -PathType Leaf)) {
        throw "Missing agent configuration: $agentPath"
    }
    $settings = $profileData.$role
    Set-TopLevelTomlValue $agentPath "model" ('"' + $settings.model + '"')
    Set-TopLevelTomlValue $agentPath "model_reasoning_effort" ('"' + $settings.reasoning + '"')
}

$expected = @($configPath) + @($roles | ForEach-Object { Join-Path $agentsDir "$_.toml" })
foreach ($path in $expected) {
    $content = Get-Content -Raw -LiteralPath $path
    if ($content -notmatch '(?m)^model\s*=\s*"gpt-5\.6-(?:sol|terra|luna)"\s*$' -or
        $content -notmatch '(?m)^model_reasoning_effort\s*=\s*"(?:medium|high|xhigh)"\s*$') {
        throw "Generated model configuration failed validation: $path"
    }
}

$mode = if ($ProfileOnly) { "profile switched" } else { "scaffold installed/updated" }
Write-Host "Lightflow $mode"
Write-Host "Target:  $targetRoot"
Write-Host "Profile: $Profile"
Write-Host "Agents:  $($roles -join ', ')"
