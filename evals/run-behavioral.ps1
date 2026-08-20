[CmdletBinding()]
param(
    [string[]]$ScenarioId,
    [string]$Model = "gpt-5.6-sol",
    [switch]$SkipExecutionSmoke,
    [switch]$List,
    [switch]$KeepArtifacts
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$scenarioPath = Join-Path $PSScriptRoot "routing-scenarios.json"
$scenarioData = Get-Content -Raw -LiteralPath $scenarioPath | ConvertFrom-Json
$scenarios = @()
foreach ($scenario in $scenarioData) { $scenarios += $scenario }

if ($List) {
    $scenarios | Select-Object id, prompt
    return
}

if ($ScenarioId.Count -gt 0) {
    $unknown = @($ScenarioId | Where-Object { $_ -notin @($scenarios.id) })
    if ($unknown.Count -gt 0) { throw "Unknown scenario: $($unknown -join ', ')" }
    $scenarios = @($scenarios | Where-Object { $_.id -in $ScenarioId })
}

$catalog = codex debug models | ConvertFrom-Json
if ($Model -notin @($catalog.models.slug)) { throw "Model is not available in this Codex catalog: $Model" }

$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase ("lightflow-behavior-" + [Guid]::NewGuid().ToString("N"))
$completed = $false
New-Item -ItemType Directory -Path $tempRoot | Out-Null

try {
    git -C $tempRoot init --quiet
    & (Join-Path $root "scripts\setup.ps1") -TargetRepository $tempRoot -Profile balanced | Out-Null

    $skillTarget = Join-Path $tempRoot ".codex\skills\lightflow"
    New-Item -ItemType Directory -Path $skillTarget -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $root "plugins\lightflow\skills\lightflow\SKILL.md") -Destination $skillTarget
    Copy-Item -LiteralPath (Join-Path $root "plugins\lightflow\skills\lightflow\references") -Destination $skillTarget -Recurse

    $schemaPath = Join-Path $tempRoot "routing-result.schema.json"
    $schema = @{
        type = "object"
        properties = @{
            workType = @{ type = "string"; enum = @("FEATURE", "BUGFIX", "REFACTOR", "INTEGRATION", "ARCHITECTURE", "TRIVIAL") }
            architecture = @{ type = "string"; enum = @("USER_COMPLETE", "USER_PARTIAL", "EXISTING", "UNSPECIFIED") }
            risk = @{ type = "string"; enum = @("LOW", "NORMAL", "HIGH", "CRITICAL") }
            route = @{ type = "array"; items = @{ type = "string"; enum = @("explorer", "architect", "worker", "reviewer") } }
        }
        required = @("workType", "architecture", "risk", "route")
        additionalProperties = $false
    } | ConvertTo-Json -Depth 8
    [System.IO.File]::WriteAllText($schemaPath, $schema)

    foreach ($scenario in $scenarios) {
        $resultPath = Join-Path $tempRoot "$($scenario.id).json"
        $prompt = @"
Use the project Lightflow skill. This is a routing-only behavioral evaluation: do not modify files and do not delegate. Classify the request and return only the required JSON result. Treat host Plan Mode as $($scenario.planMode.ToString().ToLowerInvariant()).

Request: $($scenario.prompt)
"@
        & codex exec --ephemeral --skip-git-repo-check --sandbox read-only --model $Model --output-schema $schemaPath --output-last-message $resultPath -C $tempRoot $prompt
        if ($LASTEXITCODE -ne 0) { throw "Codex failed for scenario: $($scenario.id)" }

        $actual = Get-Content -Raw -LiteralPath $resultPath | ConvertFrom-Json
        foreach ($field in @("workType", "architecture", "risk")) {
            if ($actual.$field -ne $scenario.$field) {
                throw "$($scenario.id): expected $field=$($scenario.$field), got $($actual.$field)"
            }
        }
        if ((@($actual.route) -join ",") -ne (@($scenario.route) -join ",")) {
            throw "$($scenario.id): expected route [$(@($scenario.route) -join ', ')], got [$(@($actual.route) -join ', ')]"
        }
        Write-Host "PASS route: $($scenario.id)"
    }

    if (-not $SkipExecutionSmoke) {
        $settingsPath = Join-Path $tempRoot "settings.json"
        [System.IO.File]::WriteAllText($settingsPath, "{`"legacy_name`":true}`r`n")
        & codex exec --ephemeral --skip-git-repo-check --sandbox workspace-write --model $Model -C $tempRoot 'Use Lightflow to rename the legacy_name JSON property in settings.json to current_name. Implement the change and verify the JSON.'
        if ($LASTEXITCODE -ne 0) { throw "Codex failed the execution smoke test." }
        $settings = Get-Content -Raw -LiteralPath $settingsPath | ConvertFrom-Json
        if ($settings.PSObject.Properties.Name -notcontains "current_name" -or
            $settings.PSObject.Properties.Name -contains "legacy_name" -or
            $settings.current_name -ne $true) {
            throw "Execution smoke test did not produce the requested settings.json change."
        }
        Write-Host "PASS execution: trivial rename"
    }

    $completed = $true
    Write-Host "Lightflow behavioral evaluation passed: $($scenarios.Count) live routing scenarios."
} finally {
    $resolved = [System.IO.Path]::GetFullPath($tempRoot)
    $safe = $resolved.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase) -and
        [System.IO.Path]::GetFileName($resolved).StartsWith("lightflow-behavior-")
    if ($completed -and -not $KeepArtifacts -and $safe -and (Test-Path -LiteralPath $resolved)) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    } elseif (Test-Path -LiteralPath $resolved) {
        Write-Host "Behavioral artifacts: $resolved"
    }
}
