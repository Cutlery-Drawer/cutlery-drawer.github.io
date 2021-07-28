#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$esc = [char]0x1B
Write-Host "Normal$esc[2mDIMMED$esc[32mGreen$esc[0m$esc[32mGreen$esc[0m"
Write-Host '[command]' -NoNewline
Write-Host 'echo Foo Bar Baz'

if($env:APPVEYOR){
	$mods = "C:\Program Files\AppVeyor\BuildAgent\Modules\build-worker-api"
	Get-ChildItem $mods
	Get-Content "$mods\build-worker-api.psm1"
}
