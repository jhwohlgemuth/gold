#!/usr/bin/env pwsh

<#
.SYNOPSIS
Downloads Hugging Face models and generates llama-swap config entries.

.DESCRIPTION
Accepts one or more model IDs in `provider/model-name` format. The script
generates llama-swap `models` entries using only `model-name`, then downloads
each Hugging Face repository into `$ModelsDirectory/<model-name>` unless
`-ConfigOnly` is specified.

.PARAMETER Model
One or more model IDs in `provider/model-name` format. Values may be passed as
an array, comma-separated string, or space-separated string.

.PARAMETER ModelsDirectory
Directory that will contain downloaded model directories. Defaults to
`$HOME/models`.

.PARAMETER Token
Hugging Face token override. If omitted, `hf` will use its configured auth.

.PARAMETER Force
Pass `--force-download` to `hf download`.

.PARAMETER TemplatePath
Path to the llama-swap template containing `{{ generated_models }}`.

.PARAMETER OutputPath
Path where the generated llama-swap config will be written.

.PARAMETER ConfigOnly
Generate the llama-swap config without downloading models.

.PARAMETER NoConfig
Download models without regenerating the llama-swap config.

.EXAMPLE
./scripts/Get-Models.ps1 -Model openai/gpt-oss-20b

.EXAMPLE
./scripts/Get-Models.ps1 -Model "openai/gpt-oss-20b openai/gpt-oss-120b"

.EXAMPLE
./scripts/Get-Models.ps1 -Model "openai/gpt-oss-20b openai/gpt-oss-120b" -ConfigOnly

.EXAMPLE
./scripts/Get-Models.ps1 -Model openai/gpt-oss-20b -WhatIf
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]] $Model,
    [Parameter()]
    [string] $ModelsDirectory = "${HOME}/.models",
    [Parameter()]
    [string] $Token,
    [Parameter()]
    [switch] $Force,
    [Parameter()]
    [string] $TemplatePath = (Join-Path $PSScriptRoot "../config/llama-swap/template.yaml"),
    [Parameter()]
    [string] $OutputPath = (Join-Path $PSScriptRoot "../config/llama-swap/config.yaml"),
    [Parameter()]
    [switch] $ConfigOnly,
    [Parameter()]
    [switch] $NoConfig
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$GeneratedModelsPlaceholder = "{{ generated_models }}"
function Resolve-FilePath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
}
function Resolve-ModelIds {
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Value
    )
    $ModelIds = @($Value | ForEach-Object { $_ -split '[,\s]+' } | Where-Object { $_ })
    foreach ($ModelId in $ModelIds) {
        if ($ModelId -notmatch '^[^/\s]+/[^/\s]+$') {
            throw "Model '$ModelId' must use provider/model-name format."
        }
    }
    return @($ModelIds | Select-Object -Unique)
}
function Get-ModelNameWithoutProvider {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Id
    )
    return ($Id -split '/')[-1]
}
function Read-LlamaSwapTemplate {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    $ResolvedPath = Resolve-FilePath -Path $Path
    if (-not (Test-Path -LiteralPath $ResolvedPath -PathType Leaf)) {
        throw "llama-swap template not found: $ResolvedPath"
    }
    $Template = Get-Content -LiteralPath $ResolvedPath -Raw
    if (-not $Template.Contains($GeneratedModelsPlaceholder)) {
        throw "llama-swap template must contain placeholder: $GeneratedModelsPlaceholder"
    }
    return $Template
}
function ConvertTo-YamlScalar {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Value
    )
    return ($Value.ToString() -replace '"', '\"')
}
function Resolve-LlamaSwapModels {
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $ModelId
    )
    $Models = [System.Collections.Generic.List[object]]::new()
    $ModelNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($Id in @($ModelId | Select-Object -Unique)) {
        $Name = Get-ModelNameWithoutProvider -Id $Id
        if (-not $ModelNames.Add($Name)) {
            throw "Duplicate provider-stripped model name: $Name"
        }
        $Models.Add([pscustomobject]@{
            Id = $Id
            Name = $Name
        }) | Out-Null
    }
    return $Models
}
function New-LlamaSwapModelBlock {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Model
    )
    $Name = ConvertTo-YamlScalar -Value $Model.Name
    return @"
  "$Name":
    proxy: "http://127.0.0.1:`${PORT}"
    cmd: |
      llama-server
      --offline
      --batch-size 2048
      --host 0.0.0.0
      --jinja
      --model `${models_dir}/$Name
      --port `${PORT}
      --sleep-idle-seconds 600
      --tools all
      --ubatch-size 2048
"@
}
function ConvertTo-LlamaSwapGeneratedModels {
    param(
        [Parameter(Mandatory = $true)]
        [object[]] $Models
    )
    return (($Models | ForEach-Object { New-LlamaSwapModelBlock -Model $_ }) -join "`n")
}
function Write-LlamaSwapConfig {
    param(
        [Parameter(Mandatory = $true)]
        [object[]] $Models,
        [Parameter(Mandatory = $true)]
        [string] $TemplatePath,
        [Parameter(Mandatory = $true)]
        [string] $OutputPath
    )
    $Template = Read-LlamaSwapTemplate -Path $TemplatePath
    $GeneratedModels = ConvertTo-LlamaSwapGeneratedModels -Models $Models
    $ResolvedPath = Resolve-FilePath -Path $OutputPath
    $OutputDirectory = Split-Path -Parent $ResolvedPath
    $Config = $Template.Replace($GeneratedModelsPlaceholder, $GeneratedModels)
    if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) {
        New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
    }
    if ($PSCmdlet.ShouldProcess($ResolvedPath, "Write generated llama-swap config")) {
        Set-Content -LiteralPath $ResolvedPath -Value $Config -NoNewline
    }
}
function Invoke-HuggingFaceDownload {
    param(
        [Parameter(Mandatory = $true)]
        [object[]] $Models,
        [Parameter(Mandatory = $true)]
        [string] $Directory,
        [Parameter()]
        [string] $ResolvedToken,
        [Parameter()]
        [switch] $ForceDownload
    )
    if (-not (Get-Command hf -ErrorAction SilentlyContinue)) {
        throw "The 'hf' CLI was not found in PATH. Install it first: https://huggingface.co/docs/huggingface_hub/guides/cli"
    }
    if (-not (Test-Path -LiteralPath $Directory -PathType Container)) {
        New-Item -Path $Directory -ItemType Directory -Force | Out-Null
    }
    foreach ($ModelEntry in $Models) {
        $LocalDirectory = Join-Path $Directory $ModelEntry.Name
        $Arguments = @("download", $ModelEntry.Id, "--local-dir", $LocalDirectory)
        if ($ResolvedToken) {
            $Arguments += @("--token", $ResolvedToken)
        }
        if ($ForceDownload) {
            $Arguments += "--force-download"
        }
        if ($PSCmdlet.ShouldProcess($ModelEntry.Id, "Download to $LocalDirectory")) {
            $DisplayArguments = @($Arguments | ForEach-Object { if ($_ -eq $ResolvedToken) { "<redacted>" } else { $_ } })
            Write-Verbose "Running: hf $($DisplayArguments -join ' ')"
            & hf @Arguments
        }
    }
}
if ($ConfigOnly -and $NoConfig) {
    throw "Use either -ConfigOnly or -NoConfig, not both."
}
$ModelIds = Resolve-ModelIds -Value $Model
$Models = @(Resolve-LlamaSwapModels -ModelId $ModelIds)
if (-not $NoConfig) {
    Write-LlamaSwapConfig -Models $Models -TemplatePath $TemplatePath -OutputPath $OutputPath
}
if (-not $ConfigOnly) {
    Invoke-HuggingFaceDownload -Models $Models -Directory $ModelsDirectory -ResolvedToken $Token -ForceDownload:$Force
}
