#!/usr/bin/env pwsh

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string] $Token,
    [Parameter()]
    [string] $ModelsDirectory = "$Env:HOMEPATH/.models",
    [Parameter()]
    [ValidateSet("smollm2", "qwen2.5", "all")]
    [string[]] $Model = @("all")
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
if (-not (Get-Command hf -ErrorAction SilentlyContinue)) {
    throw "The 'hf' CLI was not found in PATH. Install it first: https://huggingface.co/docs/huggingface_hub/guides/cli"
}
$Catalog = @{
    "smollm2" = @{
        Repo = "bartowski/SmolLM2-135M-Instruct-GGUF"
        Include = "SmolLM2-135M-Instruct-Q4_K_M.gguf"
    }
    "qwen2.5" = @{
        Repo = "bartowski/Qwen2.5-0.5B-Instruct-GGUF"
        Include = "Qwen2.5-0.5B-Instruct-Q4_K_M.gguf"
    }
}
$Selected = if ($Model -contains "all") {
    $Catalog.Keys
} else {
    $Model
}
if (-not (Test-Path -LiteralPath $ModelsDirectory)) {
    New-Item -Path $ModelsDirectory -ItemType Directory -Force | Out-Null
}
foreach ($Name in $Selected) {
    $Entry = $Catalog[$Name]
    $Args = @(
        "download"
        $Entry.Repo
        "--include"
        $Entry.Include
        "--local-dir"
        $ModelsDirectory
    )
    if ($Token) {
        $Args += @("--token", $Token)
    }
    if ($PSCmdlet.ShouldProcess($Entry.Repo, "Download model to $ModelsDirectory")) {
        Write-Verbose "Running: hf $($Args -join ' ')"
        & hf @Args
    }
}

