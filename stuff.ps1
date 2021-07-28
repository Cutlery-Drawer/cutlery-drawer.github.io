#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host '[command]' -NoNewline
Write-Host 'echo Foo Bar Baz'

if($env:APPVEYOR){
	$mods = "C:\Program Files\AppVeyor\BuildAgent\Modules\build-worker-api"
	Get-ChildItem $mods
	Get-Content "$mods\build-worker-api.psm1"
}
