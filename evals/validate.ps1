[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$roles = @("explorer", "architect", "worker", "reviewer")
$profileRoles = @("orchestrator") + $roles
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
Assert ($manifest.version -eq "0.4.0") "Codex plugin version mismatch"
Assert ($manifest.skills -eq "./skills/") "Plugin skills path mismatch"
Assert ($manifest.PSObject.Properties.Name -notcontains "mcpServers") "Unused MCP configuration must not be present"

$claudeManifest = Get-Content -Raw -LiteralPath (Join-Path $root "plugins\lightflow\.claude-plugin\plugin.json") | ConvertFrom-Json
Assert ($claudeManifest.name -eq $manifest.name) "Claude plugin name mismatch"
Assert ($claudeManifest.version -eq $manifest.version) "Codex and Claude plugin versions differ"
Assert ($claudeManifest.skills -eq "./skills/") "Claude plugin skills path mismatch"
Assert ($claudeManifest.agents -eq "./agents/") "Claude plugin agents path mismatch"
Assert ($claudeManifest.PSObject.Properties.Name -notcontains "mcpServers") "Claude plugin must not configure MCP"

$claudeMarketplace = Get-Content -Raw -LiteralPath (Join-Path $root ".claude-plugin\marketplace.json") | ConvertFrom-Json
Assert ($claudeMarketplace.name -eq "lightflow") "Claude marketplace name mismatch"
Assert ($claudeMarketplace.plugins.Count -eq 1) "Claude marketplace must expose exactly one plugin"
Assert ($claudeMarketplace.plugins[0].name -eq "lightflow") "Claude marketplace plugin name mismatch"
Assert ($claudeMarketplace.plugins[0].source -eq "./plugins/lightflow") "Claude marketplace source mismatch"

$claudeAgentFiles = @(Get-ChildItem -LiteralPath (Join-Path $root "plugins\lightflow\agents") -Filter "*.md")
Assert ($claudeAgentFiles.Count -eq 4) "Claude plugin must contain exactly four agents"
Assert ((@($claudeAgentFiles.BaseName | Sort-Object) -join ",") -eq (@($roles | Sort-Object) -join ",")) "Claude agent role set mismatch"
foreach ($file in $claudeAgentFiles) {
    $content = Get-Content -Raw -LiteralPath $file.FullName
    Assert ($content -match "(?m)^name:\s*$($file.BaseName)\s*$") "Claude agent name mismatch: $($file.Name)"
    Assert ($content -match '(?m)^description:\s*.+$') "Claude agent missing description: $($file.Name)"
    Assert ($content -match '(?m)^model:\s*(?:haiku|inherit)\s*$') "Claude agent model mismatch: $($file.Name)"
    Assert ($content -match '(?m)^effort:\s*(?:low|medium|high)\s*$') "Claude agent effort mismatch: $($file.Name)"
}
$claudeExplorer = Get-Content -Raw -LiteralPath (Join-Path $root "plugins\lightflow\agents\explorer.md")
Assert ($claudeExplorer -match '(?m)^model:\s*haiku\s*$' -and $claudeExplorer -match '(?m)^effort:\s*low\s*$') "Claude Explorer must use Haiku low"
Assert ($claudeExplorer -match '(?m)^disallowedTools:\s*Write, Edit\s*$') "Claude Explorer must deny write tools"
$claudeWorker = Get-Content -Raw -LiteralPath (Join-Path $root "plugins\lightflow\agents\worker.md")
Assert ($claudeWorker -match '(?m)^tools:.*\bEdit\b.*\bWrite\b') "Claude Worker must expose edit tools"
$skillPath = Join-Path $root "plugins\lightflow\skills\lightflow\SKILL.md"
$skillContent = Get-Content -Raw -LiteralPath $skillPath
Assert ($skillContent -match '(?m)^name:\s*lightflow\s*$') "Bundled skill name mismatch"
Assert ($skillContent.Contains("Use one Explorer when")) "Cost-aware Explorer routing policy missing"
Assert ($skillContent.Contains("MCP/app tools") -and $skillContent.Contains("only when the user explicitly requests")) "Operational-tool opt-in policy missing"
Assert ($skillContent.Contains("lightflow:explorer") -and $skillContent.Contains("lightflow:worker")) "Claude agent host mapping missing"
Assert ($skillContent.Contains("Exact replication") -and $skillContent.Contains("Template replication") -and $skillContent.Contains("Adaptation")) "Reference-intent routing policy missing"
Assert ($skillContent.Contains("do not rewrite, minimize, redesign, or adapt")) "Exact-copy fidelity boundary missing"
Assert ($skillContent.Contains("Fidelity does not expand scope")) "Exact-copy bounded-scope policy missing"
Assert ($skillContent.Contains("bounded copy manifest")) "Exact-copy manifest policy missing"
Assert ($skillContent.Contains("enumerate the applicable scenes and explicit exclusions")) "Unity scene coverage policy missing"
Assert ($skillContent.Contains("Enter Play Mode") -and $skillContent.Contains("only when explicitly requested")) "Unity execution opt-in boundary missing"

$toolsetPolicy = Get-Content -Raw -LiteralPath (Join-Path $root "plugins\lightflow\skills\lightflow\references\toolsets.md")
foreach ($requiredText in @("go.work", "go.mod", "go list -m -json all", "GOPROXY=off", "GOMODCACHE", "package.json", "Packages/manifest.json", "Packages/packages-lock.json", "Library/PackageCache", "README.md", "missing or insufficient")) {
    Assert ($toolsetPolicy.Contains($requiredText)) "Toolset discovery policy missing: $requiredText"
}
Assert (-not $toolsetPolicy.Contains(".codex/toolsets.json")) "Manual toolset registry must not be required"
$authorityPolicy = Get-Content -Raw -LiteralPath (Join-Path $root "plugins\lightflow\skills\lightflow\references\authority.md")
Assert ($authorityPolicy.Contains("Ponytail applies implicitly")) "Implicit Ponytail policy missing"
$explorerTemplate = Get-Content -Raw -LiteralPath (Join-Path $root "scaffold\.codex\agents\explorer.toml")
Assert ($explorerTemplate.Contains("README.md first")) "Explorer README-first policy missing"
Assert ($explorerTemplate.Contains("Library/PackageCache") -and $explorerTemplate.Contains("GOMODCACHE")) "Explorer native dependency-cache discovery missing"
Assert ($explorerTemplate.Contains("line numbers") -and $explorerTemplate.Contains("inference separately")) "Explorer evidence contract missing"

$marketplace = Get-Content -Raw -LiteralPath (Join-Path $root ".agents\plugins\marketplace.json") | ConvertFrom-Json
Assert ($marketplace.name -eq "lightflow") "Marketplace name mismatch"
Assert ($marketplace.plugins.Count -eq 1) "Marketplace must expose exactly one plugin"
Assert ($marketplace.plugins[0].name -eq "lightflow") "Marketplace plugin name mismatch"
Assert ($marketplace.plugins[0].source.path -eq "./plugins/lightflow") "Marketplace source path mismatch"
Assert ($marketplace.plugins[0].policy.installation -eq "AVAILABLE") "Marketplace installation policy missing"
Assert ($marketplace.plugins[0].policy.authentication -eq "ON_INSTALL") "Marketplace authentication policy missing"

$agentFiles = @(Get-ChildItem -LiteralPath (Join-Path $root "scaffold\.codex\agents") -Filter "*.toml")
Assert ($agentFiles.Count -eq 4) "Scaffold must contain exactly four specialist TOML files"
Assert ((@($agentFiles.BaseName | Sort-Object) -join ",") -eq (@($roles | Sort-Object) -join ",")) "Agent role set mismatch"
Test-TomlSubset (Join-Path $root "scaffold\.codex\config.toml")
foreach ($file in $agentFiles) {
    Test-TomlSubset $file.FullName
    $content = Get-Content -Raw -LiteralPath $file.FullName
    Assert ($content -match '(?m)^name\s*=') "Agent missing name: $($file.Name)"
    Assert ($content -match '(?m)^description\s*=') "Agent missing description: $($file.Name)"
    Assert ($content -match '(?m)^developer_instructions\s*=') "Agent missing instructions: $($file.Name)"
}

$availableModelIds = $null
if (Get-Command codex -ErrorAction SilentlyContinue) {
    $catalog = codex debug models | ConvertFrom-Json
    $availableModelIds = @($catalog.models.slug)
} else {
    Write-Warning "Codex CLI is unavailable; live model-catalog validation was skipped."
}

foreach ($profileName in @("refined-balanced", "balanced", "quality", "economy")) {
    $profile = Get-Content -Raw -LiteralPath (Join-Path $root "profiles\$profileName.json") | ConvertFrom-Json
    Assert ((($profile.PSObject.Properties.Name | Sort-Object) -join ",") -eq (($profileRoles | Sort-Object) -join ",")) "Profile role mismatch: $profileName"
    foreach ($role in $profileRoles) {
        Assert ($profile.$role.model -match '^gpt-5\.6-(?:sol|terra|luna)$') "Invalid model in $profileName/$role"
        if ($null -ne $availableModelIds) {
            Assert ($profile.$role.model -in $availableModelIds) "Unavailable model in $profileName/${role}: $($profile.$role.model)"
        }
        Assert ($profile.$role.reasoning -match '^(low|medium|high|xhigh)$') "Invalid reasoning in $profileName/$role"
    }
}

$scenarioData = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "routing-scenarios.json") | ConvertFrom-Json
$scenarios = @()
foreach ($scenarioItem in $scenarioData) { $scenarios += $scenarioItem }
$required = @(
    "trivial-rename", "failing-rpc", "complete-user-architecture", "partial-user-architecture",
    "incomplete-refactor", "project-port", "reuse-toolset", "reuse-unity-package-cache", "local-capability",
    "propose-reusable-capability", "unapproved-toolset-mutation", "approved-toolset-api",
    "plan-complete-architecture", "plan-unresolved-design", "unity-source-only",
    "unity-runtime-state", "unity-reference-bootstrap", "exact-system-copy", "unity-complete-scene-integration", "unity-compilation-settle",
    "go-nakama-normal", "critical-precision", "normal-feature-no-ceremony"
)
$scenarioIds = @($scenarios | ForEach-Object { $_.id })
Assert (@($required | Where-Object { $_ -notin $scenarioIds }).Count -eq 0) "Required routing scenarios are missing"
$behaviorList = @(& (Join-Path $PSScriptRoot "run-behavioral.ps1") -List)
Assert ($behaviorList.Count -eq $scenarios.Count) "Behavioral evaluator loaded $($behaviorList.Count) of $($scenarios.Count) scenarios"

foreach ($scenario in $scenarios) {
    Assert ($scenario.workType -in @("FEATURE", "BUGFIX", "REFACTOR", "INTEGRATION", "ARCHITECTURE", "TRIVIAL")) "Invalid work type: $($scenario.id)"
    Assert ($scenario.architecture -in @("USER_COMPLETE", "USER_PARTIAL", "EXISTING", "UNSPECIFIED")) "Invalid architecture: $($scenario.id)"
    Assert ($scenario.risk -in @("LOW", "NORMAL", "HIGH", "CRITICAL")) "Invalid risk: $($scenario.id)"
    foreach ($role in @($scenario.route)) {
        Assert ($role -in $spawnable) "Unknown or redundant orchestrator route in $($scenario.id): $role"
    }
    if ($scenario.workType -eq "TRIVIAL") {
        Assert (@($scenario.route).Count -eq 0) "Trivial work must stay in the primary agent: $($scenario.id)"
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
    Assert (@($scenario.route | Where-Object { $_ -ne "explorer" }).Count -eq 0) "Default scenarios may route only to Explorer: $($scenario.id)"
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
$unityReference = $scenarios | Where-Object id -eq "unity-reference-bootstrap"
Assert ((@($unityReference.route) -join ",") -eq "explorer") "Unity reference integration should use one cheap read-only Explorer"
foreach ($tool in @("source-project", "target-project", "reference-checklist", "reuse-existing-assets")) {
    Assert ($tool -in @($unityReference.tools)) "Unity reference integration missing contract: $tool"
}
Assert ("unity-editor" -notin @($unityReference.tools)) "Unity reference integration must not invoke the editor without an explicit request"
$exactCopy = $scenarios | Where-Object id -eq "exact-system-copy"
Assert ((@($exactCopy.route) -join ",") -eq "explorer") "Exact replication should use one cheap read-only Explorer"
Assert ($exactCopy.architecture -eq "USER_COMPLETE") "Exact source implementation must be treated as complete architecture"
foreach ($tool in @("bounded-copy-manifest", "dependency-reasons", "explicit-exclusions", "read-only-sibling-audit", "source-target-file-diff", "public-api-parity", "structure-parity", "serialized-wiring-parity", "changed-file-scope-check")) {
    Assert ($tool -in @($exactCopy.tools)) "Exact replication missing parity check: $tool"
}
$completeUnity = $scenarios | Where-Object id -eq "unity-complete-scene-integration"
Assert ((@($completeUnity.route) -join ",") -eq "explorer") "Complete Unity integration should use one cheap read-only Explorer"
foreach ($tool in @("scene-inventory", "explicit-scene-exclusion", "helper-and-asset-coverage", "pipeline-coverage")) {
    Assert ($tool -in @($completeUnity.tools)) "Complete Unity integration missing coverage check: $tool"
}
foreach ($tool in @("unity-editor", "asset-refresh", "wait-for-editor-idle", "post-compile-console-errors")) {
    Assert ($tool -notin @($completeUnity.tools)) "Unity integration invoked unrequested operational tool: $tool"
}
$unityCompile = $scenarios | Where-Object id -eq "unity-compilation-settle"
Assert (@($unityCompile.route).Count -eq 0) "Normal Unity compilation validation must stay in the primary agent"
foreach ($tool in @("unity-editor", "asset-refresh", "observe-compilation", "wait-for-editor-idle", "post-compile-console-errors", "repeat-after-fix")) {
    Assert ($tool -in @($unityCompile.tools)) "Unity compilation validation missing gate: $tool"
}
$goScenario = $scenarios | Where-Object id -eq "go-nakama-normal"
Assert ($goScenario.PSObject.Properties.Name -notcontains "tools") "Go/Nakama work must not run unrequested tests"
$reuseToolset = $scenarios | Where-Object id -eq "reuse-toolset"
foreach ($tool in @("go.mod", "go-list-offline", "GOMODCACHE", "README-first", "source-fallback")) {
    Assert ($tool -in @($reuseToolset.tools)) "Toolset discovery scenario missing: $tool"
}
$reuseUnityPackage = $scenarios | Where-Object id -eq "reuse-unity-package-cache"
foreach ($tool in @("Packages/manifest.json", "Packages/packages-lock.json", "Library/PackageCache", "package.json", "README-first", "source-fallback")) {
    Assert ($tool -in @($reuseUnityPackage.tools)) "Unity package-cache discovery scenario missing: $tool"
}
Assert ("applicable-installed-unity-skill" -in @($reuseUnityPackage.skills)) "Unity package discovery must use applicable installed Unity skills"
$refactor = $scenarios | Where-Object id -eq "incomplete-refactor"
Assert ("ponytail" -in @($refactor.skills)) "Meaningful refactor must apply Ponytail when available"
$normalFeature = $scenarios | Where-Object id -eq "normal-feature-no-ceremony"
Assert (@($normalFeature.route).Count -eq 0) "Normal feature is over-delegated"
$normalScenarios = @($scenarios | Where-Object { $_.risk -in @("LOW", "NORMAL") -and -not $_.planMode })
foreach ($scenario in $normalScenarios) {
    Assert (@($scenario.route).Count -le 1) "Low/normal work exceeds the default one-specialist budget: $($scenario.id)"
}
$approvedApi = $scenarios | Where-Object id -eq "approved-toolset-api"
Assert ($approvedApi.risk -eq "HIGH" -and (@($approvedApi.route) -join ",") -eq "explorer") "Approved public toolset API flow should use one Explorer and primary reasoning"

$refinedProfile = Get-Content -Raw -LiteralPath (Join-Path $root "profiles\refined-balanced.json") | ConvertFrom-Json
Assert ($refinedProfile.orchestrator.model -eq "gpt-5.6-sol" -and $refinedProfile.orchestrator.reasoning -eq "medium") "Refined Balanced primary must remain Sol medium"
Assert ($refinedProfile.explorer.model -eq "gpt-5.6-luna" -and $refinedProfile.explorer.reasoning -eq "low") "Refined Balanced Explorer must remain Luna low"

$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase ("lightflow-eval-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempRoot | Out-Null
try {
    [System.IO.File]::WriteAllText((Join-Path $tempRoot "AGENTS.md"), "# Existing project`r`n`r`nKeep this instruction.`r`n`r`n<!-- BEGIN NATURAL DEVELOPMENT WORKFLOW -->`r`nLegacy block.`r`n<!-- END NATURAL DEVELOPMENT WORKFLOW -->`r`n")
    New-Item -ItemType Directory -Path (Join-Path $tempRoot ".codex") | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $tempRoot ".codex\agents") | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $tempRoot ".codex\config.toml"), "approval_policy = `"on-request`"`r`n")
    [System.IO.File]::WriteAllText((Join-Path $tempRoot ".codex\agents\orchestrator.toml"), "name = `"customized-legacy-orchestrator`"`r`n")

    & (Join-Path $root "scripts\setup.ps1") -TargetRepository $tempRoot -Profile balanced | Out-Null
    $installedAgents = Get-Content -Raw -LiteralPath (Join-Path $tempRoot "AGENTS.md")
    Assert ($installedAgents.Contains("Keep this instruction.")) "Setup overwrote existing AGENTS.md"
    Assert ($installedAgents.Contains("<!-- BEGIN LIGHTFLOW WORKFLOW -->") -and -not $installedAgents.Contains("NATURAL DEVELOPMENT WORKFLOW")) "Setup did not migrate the legacy managed block"
    Assert ((Get-Content -Raw -LiteralPath (Join-Path $tempRoot ".codex\config.toml")).Contains('approval_policy = "on-request"')) "Setup removed existing config"
    Assert (@(Get-ChildItem -LiteralPath (Join-Path $tempRoot ".codex\agents") -Filter "*.toml").Count -eq 4) "Setup did not generate four specialists"
    Assert (-not (Test-Path -LiteralPath (Join-Path $tempRoot ".codex\agents\orchestrator.toml"))) "Setup did not remove the legacy custom Orchestrator"
    Assert (@(Get-ChildItem -LiteralPath (Join-Path $tempRoot ".codex\agents") -Filter "orchestrator.toml.lightflow-backup-*").Count -eq 1) "Setup did not back up the legacy custom Orchestrator"
    Assert (-not (Test-Path -LiteralPath (Join-Path $tempRoot ".codex\toolsets.json"))) "Setup must not create a manual toolset registry"
    Assert (@(Get-ChildItem -LiteralPath $tempRoot -Filter "AGENTS.md.lightflow-backup-*").Count -eq 1) "Setup did not back up existing AGENTS.md"

    $agentsBefore = Get-Content -Raw -LiteralPath (Join-Path $tempRoot "AGENTS.md")
    $workerBefore = (Get-Content -Raw -LiteralPath (Join-Path $tempRoot ".codex\agents\worker.toml")) -replace '(?m)^model(?:_reasoning_effort)?\s*=.*\r?\n?', ''
    $backupCount = @(Get-ChildItem -LiteralPath $tempRoot -Recurse -Filter "*.lightflow-backup-*").Count

    & (Join-Path $root "scripts\setup.ps1") -TargetRepository $tempRoot -Profile refined-balanced -ProfileOnly | Out-Null
    Assert ((Get-Content -Raw -LiteralPath (Join-Path $tempRoot "AGENTS.md")) -eq $agentsBefore) "Profile-only changed AGENTS.md"
    Assert (@(Get-ChildItem -LiteralPath $tempRoot -Recurse -Filter "*.lightflow-backup-*").Count -eq $backupCount) "Profile-only created unrelated backups"
    $workerAfter = (Get-Content -Raw -LiteralPath (Join-Path $tempRoot ".codex\agents\worker.toml")) -replace '(?m)^model(?:_reasoning_effort)?\s*=.*\r?\n?', ''
    Assert ($workerAfter -eq $workerBefore) "Profile-only changed Worker instructions"
    $explorer = Get-Content -Raw -LiteralPath (Join-Path $tempRoot ".codex\agents\explorer.toml")
    Assert ($explorer -match '(?m)^model\s*=\s*"gpt-5\.6-luna"\s*$') "Refined Balanced Explorer model was not applied"
    Assert ($explorer -match '(?m)^model_reasoning_effort\s*=\s*"low"\s*$') "Refined Balanced Explorer reasoning was not applied"

    Test-TomlSubset (Join-Path $tempRoot ".codex\config.toml")
    foreach ($role in $roles) { Test-TomlSubset (Join-Path $tempRoot ".codex\agents\$role.toml") }
} finally {
    $resolvedTemp = [System.IO.Path]::GetFullPath($tempRoot)
    if ($resolvedTemp.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase) -and
        [System.IO.Path]::GetFileName($resolvedTemp).StartsWith("lightflow-eval-")) {
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
    }
}

Write-Host "Lightflow structural validation passed: Codex and Claude plugins, marketplaces, specialists, profiles, setup, TOML subset, and $($scenarios.Count) scenario contracts."
