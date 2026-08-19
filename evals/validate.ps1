[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$roles = @("orchestrator", "explorer", "architect", "worker", "reviewer")
$spawnable = @("explorer", "architect", "worker", "reviewer")

function Assert([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

function Test-TomlSubset([string]$Path) {
    $scope = ""
    $inMultiline = $false
    $seen = @{}
    foreach ($line in Get-Content -LiteralPath $Path) {
        $trimmed = $line.Trim()
        if ($inMultiline) {
            if ($trimmed.Contains('"""')) { $inMultiline = $false }
            continue
        }
        if ($trimmed -eq "" -or $trimmed.StartsWith("#")) { continue }
        if ($trimmed -match '^\[([A-Za-z0-9_.-]+)\]$') {
            $scope = $Matches[1]
            continue
        }
        Assert ($trimmed -match '^([A-Za-z0-9_.-]+)\s*=\s*(.+)$') "Invalid TOML line in ${Path}: $line"
        $key = "$scope::$($Matches[1])"
        $value = $Matches[2].Trim()
        Assert (-not $seen.ContainsKey($key)) "Duplicate TOML key $key in $Path"
        $seen[$key] = $true
        if ($value.StartsWith('"""')) {
            if ($value.Substring(3).Contains('"""')) { continue }
            $inMultiline = $true
            continue
        }
        Assert ($value -match '^("([^"\\]|\\.)*"|true|false|[0-9]+)$') "Unsupported or invalid TOML value in ${Path}: $value"
    }
    Assert (-not $inMultiline) "Unclosed multiline string in $Path"
}

$manifest = Get-Content -Raw -LiteralPath (Join-Path $root "plugins\lightflow\.codex-plugin\plugin.json") | ConvertFrom-Json
Assert ($manifest.name -eq "lightflow") "Plugin name mismatch"
Assert ($manifest.skills -eq "./skills/") "Plugin skills path mismatch"
Assert ($manifest.PSObject.Properties.Name -notcontains "mcpServers") "Unused MCP configuration must not be present"
$skillPath = Join-Path $root "plugins\lightflow\skills\lightflow\SKILL.md"
$skillContent = Get-Content -Raw -LiteralPath $skillPath
Assert ($skillContent -match '(?m)^name:\s*lightflow\s*$') "Bundled skill name mismatch"
Assert ($skillContent.Contains("inherit the parent session's available skills")) "Skill inheritance policy missing"

$toolsetPolicy = Get-Content -Raw -LiteralPath (Join-Path $root "plugins\lightflow\skills\lightflow\references\toolsets.md")
foreach ($requiredText in @("go.work", "go.mod", "package.json", "Packages/manifest.json", "README.md", "missing or insufficient")) {
    Assert ($toolsetPolicy.Contains($requiredText)) "Toolset discovery policy missing: $requiredText"
}
$authorityPolicy = Get-Content -Raw -LiteralPath (Join-Path $root "plugins\lightflow\skills\lightflow\references\authority.md")
Assert ($authorityPolicy.Contains("Ponytail applies implicitly")) "Implicit Ponytail policy missing"
$explorerTemplate = Get-Content -Raw -LiteralPath (Join-Path $root "scaffold\.codex\agents\explorer.toml")
Assert ($explorerTemplate.Contains("README.md first")) "Explorer README-first policy missing"

$marketplace = Get-Content -Raw -LiteralPath (Join-Path $root ".agents\plugins\marketplace.json") | ConvertFrom-Json
Assert ($marketplace.name -eq "lightflow") "Marketplace name mismatch"
Assert ($marketplace.plugins.Count -eq 1) "Marketplace must expose exactly one plugin"
Assert ($marketplace.plugins[0].name -eq "lightflow") "Marketplace plugin name mismatch"
Assert ($marketplace.plugins[0].source.path -eq "./plugins/lightflow") "Marketplace source path mismatch"
Assert ($marketplace.plugins[0].policy.installation -eq "AVAILABLE") "Marketplace installation policy missing"
Assert ($marketplace.plugins[0].policy.authentication -eq "ON_INSTALL") "Marketplace authentication policy missing"

$agentFiles = @(Get-ChildItem -LiteralPath (Join-Path $root "scaffold\.codex\agents") -Filter "*.toml")
Assert ($agentFiles.Count -eq 5) "Scaffold must contain exactly five agent TOML files"
Assert ((@($agentFiles.BaseName | Sort-Object) -join ",") -eq (@($roles | Sort-Object) -join ",")) "Agent role set mismatch"
Test-TomlSubset (Join-Path $root "scaffold\.codex\config.toml")
foreach ($file in $agentFiles) {
    Test-TomlSubset $file.FullName
    $content = Get-Content -Raw -LiteralPath $file.FullName
    Assert ($content -match '(?m)^name\s*=') "Agent missing name: $($file.Name)"
    Assert ($content -match '(?m)^description\s*=') "Agent missing description: $($file.Name)"
    Assert ($content -match '(?m)^developer_instructions\s*=') "Agent missing instructions: $($file.Name)"
}

foreach ($profileName in @("balanced", "quality", "economy")) {
    $profile = Get-Content -Raw -LiteralPath (Join-Path $root "profiles\$profileName.json") | ConvertFrom-Json
    Assert ((($profile.PSObject.Properties.Name | Sort-Object) -join ",") -eq (($roles | Sort-Object) -join ",")) "Profile role mismatch: $profileName"
    foreach ($role in $roles) {
        Assert ($profile.$role.model -match '^gpt-5\.6(?:-terra|-luna)?$') "Invalid model in $profileName/$role"
        Assert ($profile.$role.reasoning -match '^(medium|high|xhigh)$') "Invalid reasoning in $profileName/$role"
    }
}

$scenarioData = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "routing-scenarios.json") | ConvertFrom-Json
$scenarios = @()
foreach ($scenarioItem in $scenarioData) { $scenarios += $scenarioItem }
$required = @(
    "trivial-rename", "failing-rpc", "complete-user-architecture", "partial-user-architecture",
    "incomplete-refactor", "project-port", "reuse-toolset", "local-capability",
    "propose-reusable-capability", "unapproved-toolset-mutation", "approved-toolset-api",
    "plan-complete-architecture", "plan-unresolved-design", "unity-source-only",
    "unity-runtime-state", "go-nakama-normal", "critical-precision", "normal-feature-no-ceremony"
)
$scenarioIds = @($scenarios | ForEach-Object { $_.id })
Assert (@($required | Where-Object { $_ -notin $scenarioIds }).Count -eq 0) "Required routing scenarios are missing"

foreach ($scenario in $scenarios) {
    Assert ($scenario.workType -in @("FEATURE", "BUGFIX", "REFACTOR", "INTEGRATION", "ARCHITECTURE", "TRIVIAL")) "Invalid work type: $($scenario.id)"
    Assert ($scenario.architecture -in @("USER_COMPLETE", "USER_PARTIAL", "EXISTING", "UNSPECIFIED")) "Invalid architecture: $($scenario.id)"
    Assert ($scenario.risk -in @("LOW", "NORMAL", "HIGH", "CRITICAL")) "Invalid risk: $($scenario.id)"
    foreach ($role in @($scenario.route)) {
        Assert ($role -in $spawnable) "Unknown or redundant orchestrator route in $($scenario.id): $role"
    }
    if ($scenario.workType -eq "TRIVIAL") {
        Assert ((@($scenario.route) -join ",") -eq "worker") "Trivial work must use Worker only: $($scenario.id)"
    }
    if ($scenario.planMode) {
        Assert ("worker" -notin @($scenario.route)) "Plan Mode must not invoke Worker: $($scenario.id)"
    }
    if ($scenario.architecture -eq "USER_COMPLETE") {
        Assert ("architect" -notin @($scenario.route)) "Complete user architecture must skip Architect: $($scenario.id)"
    }
    if ($scenario.risk -eq "LOW") {
        Assert ("reviewer" -notin @($scenario.route)) "Low-risk work should skip Reviewer: $($scenario.id)"
    }
    if ($scenario.PSObject.Properties.Name -contains "stopBeforeMutation" -and $scenario.stopBeforeMutation) {
        Assert ("worker" -notin @($scenario.route)) "Unapproved toolset mutation must stop before Worker: $($scenario.id)"
    }
}

$unitySource = $scenarios | Where-Object id -eq "unity-source-only"
Assert ("unity-editor" -notin @($unitySource.tools)) "Pure Unity source work must avoid unnecessary editor tooling"
Assert ("applicable-installed-unity-skill" -in @($unitySource.skills)) "Pure Unity source work must use applicable installed Unity skills"
$unityRuntime = $scenarios | Where-Object id -eq "unity-runtime-state"
Assert ("unity-editor" -in @($unityRuntime.tools)) "Unity runtime state requires editor tooling"
Assert ("applicable-installed-unity-skill" -in @($unityRuntime.skills)) "Unity runtime work must use applicable installed Unity skills"
$goScenario = $scenarios | Where-Object id -eq "go-nakama-normal"
Assert ("go-test" -in @($goScenario.tools)) "Go/Nakama work must use native tests"
$reuseToolset = $scenarios | Where-Object id -eq "reuse-toolset"
foreach ($tool in @("go.mod", "README-first", "source-fallback")) {
    Assert ($tool -in @($reuseToolset.tools)) "Toolset discovery scenario missing: $tool"
}
$refactor = $scenarios | Where-Object id -eq "incomplete-refactor"
Assert ("ponytail" -in @($refactor.skills)) "Meaningful refactor must apply Ponytail when available"
$normalFeature = $scenarios | Where-Object id -eq "normal-feature-no-ceremony"
Assert ((@($normalFeature.route) -join ",") -eq "worker") "Normal feature is over-delegated"
$approvedApi = $scenarios | Where-Object id -eq "approved-toolset-api"
Assert ($approvedApi.risk -eq "HIGH" -and "architect" -in @($approvedApi.route) -and "reviewer" -in @($approvedApi.route)) "Approved public toolset API flow is under-protected"

$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase ("lightflow-eval-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempRoot | Out-Null
try {
    [System.IO.File]::WriteAllText((Join-Path $tempRoot "AGENTS.md"), "# Existing project`r`n`r`nKeep this instruction.`r`n")
    New-Item -ItemType Directory -Path (Join-Path $tempRoot ".codex") | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $tempRoot ".codex\config.toml"), "approval_policy = `"on-request`"`r`n")

    & (Join-Path $root "scripts\setup.ps1") -TargetRepository $tempRoot -Profile balanced | Out-Null
    Assert ((Get-Content -Raw -LiteralPath (Join-Path $tempRoot "AGENTS.md")).Contains("Keep this instruction.")) "Setup overwrote existing AGENTS.md"
    Assert ((Get-Content -Raw -LiteralPath (Join-Path $tempRoot ".codex\config.toml")).Contains('approval_policy = "on-request"')) "Setup removed existing config"
    Assert (@(Get-ChildItem -LiteralPath (Join-Path $tempRoot ".codex\agents") -Filter "*.toml").Count -eq 5) "Setup did not generate five agents"
    Assert (Test-Path -LiteralPath (Join-Path $tempRoot ".codex\toolsets.json")) "Setup did not create toolset registry"
    Assert (@(Get-ChildItem -LiteralPath $tempRoot -Filter "AGENTS.md.lightflow-backup-*").Count -eq 1) "Setup did not back up existing AGENTS.md"

    $agentsBefore = Get-Content -Raw -LiteralPath (Join-Path $tempRoot "AGENTS.md")
    $toolsetsBefore = Get-Content -Raw -LiteralPath (Join-Path $tempRoot ".codex\toolsets.json")
    $workerBefore = (Get-Content -Raw -LiteralPath (Join-Path $tempRoot ".codex\agents\worker.toml")) -replace '(?m)^model(?:_reasoning_effort)?\s*=.*\r?\n?', ''
    $backupCount = @(Get-ChildItem -LiteralPath $tempRoot -Recurse -Filter "*.lightflow-backup-*").Count

    & (Join-Path $root "scripts\setup.ps1") -TargetRepository $tempRoot -Profile quality -ProfileOnly | Out-Null
    Assert ((Get-Content -Raw -LiteralPath (Join-Path $tempRoot "AGENTS.md")) -eq $agentsBefore) "Profile-only changed AGENTS.md"
    Assert ((Get-Content -Raw -LiteralPath (Join-Path $tempRoot ".codex\toolsets.json")) -eq $toolsetsBefore) "Profile-only changed toolsets"
    Assert (@(Get-ChildItem -LiteralPath $tempRoot -Recurse -Filter "*.lightflow-backup-*").Count -eq $backupCount) "Profile-only created unrelated backups"
    $workerAfter = (Get-Content -Raw -LiteralPath (Join-Path $tempRoot ".codex\agents\worker.toml")) -replace '(?m)^model(?:_reasoning_effort)?\s*=.*\r?\n?', ''
    Assert ($workerAfter -eq $workerBefore) "Profile-only changed Worker instructions"
    $explorer = Get-Content -Raw -LiteralPath (Join-Path $tempRoot ".codex\agents\explorer.toml")
    Assert ($explorer -match '(?m)^model\s*=\s*"gpt-5\.6-terra"\s*$') "Quality Explorer model was not applied"
    Assert ($explorer -match '(?m)^model_reasoning_effort\s*=\s*"high"\s*$') "Quality Explorer reasoning was not applied"

    Test-TomlSubset (Join-Path $tempRoot ".codex\config.toml")
    foreach ($role in $roles) { Test-TomlSubset (Join-Path $tempRoot ".codex\agents\$role.toml") }
} finally {
    $resolvedTemp = [System.IO.Path]::GetFullPath($tempRoot)
    if ($resolvedTemp.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase) -and
        [System.IO.Path]::GetFileName($resolvedTemp).StartsWith("lightflow-eval-")) {
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
    }
}

Write-Host "Lightflow validation passed: plugin, marketplace, five agents, profiles, setup, TOML subset, and $($scenarios.Count) routing scenarios."
