#!/usr/bin/env pwsh
$PSVersionTable

function Test-Colour(){
	param ($name, $ansi)
	$name
	iex ('Write-Host "`tFG: {0}" -ForegroundColor {0}' -f $name)
	iex ('Write-Host "`tBG: {0}" -BackgroundColor {0}' -f $name)
	$esc = [char]0x1B
	$off = "$esc[0m"
	if($ansi -lt 8){
		"`t$esc[{0}mFG: \e[{0}m$off" -f ($ansi + 30) | Write-Host
		"`t$esc[{0}mBG: \e[{0}m$off" -f ($ansi + 40) | Write-Host
	}
	"`t$esc[38;5;{0}mFG: \e[38;5;{0}m$off" -f $ansi | Write-Host
	"`t$esc[48;5;{0}mBG: \e[48;5;{0}m$off" -f $ansi | Write-Host
	""
}

Test-Colour Black       0
Test-Colour DarkRed     1
Test-Colour DarkGreen   2
Test-Colour DarkYellow  3
Test-Colour DarkBlue    4
Test-Colour DarkMagenta 5
Test-Colour DarkCyan    6
Test-Colour Gray        7
Test-Colour DarkGray    8
Test-Colour Red         9
Test-Colour Green       10
Test-Colour Yellow      11
Test-Colour Blue        12
Test-Colour Magenta     13
Test-Colour Cyan        14
Test-Colour White       15

if($env:GITHUB_ACTIONS){
	Write-Host "::echo::on"
	Write-Host "::debug::Debug-level message"
	Write-Host "::warning::Warning or something"
	Write-Host "::error::Legit error"
	Write-Host "[command]`"External Command`" --string 'Arguments, etc'"
}
elseif($env:APPVEYOR){
	Add-AppveyorMessage            -Message "1) Info-level message"    -Category Information -Details "Det`nails ``etc``"
	Add-AppveyorMessage            -Message "1) Warning-level message" -Category Warning     -Details "Det`nails ``etc``"
	Add-AppveyorMessage            -Message "1) Error-level message"   -Category Error       -Details "Det`nails ``etc``"
	Add-AppveyorCompilationMessage -Message "2) Info-level message"    -Category Information -Details "Det`nails ``etc``"
	Add-AppveyorCompilationMessage -Message "2) Warning-level message" -Category Warning     -Details "Det`nails ``etc``"
	Add-AppveyorCompilationMessage -Message "2) Error-level message"   -Category Error       -Details "Det`nails ``etc``"
	
	$mods = "C:\Program Files\AppVeyor\BuildAgent\Modules"
	Get-ChildItem $mods
	Get-Content "$mods\build-worker-api\build-worker-api.psm1"
}

Write-Information "Info-level message"    -InformationAction Continue
Write-Verbose     "Verbose message"       -Verbose
Write-Warning     "Warning-level message"
