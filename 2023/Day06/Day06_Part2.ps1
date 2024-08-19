Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

$timeLine, $distanceLine = Get-Content -Path "./$dataFile"
if ($timeLine -match 'Time:(.*)') {
	$timeList = $matches[1].Trim() -split '\s+'

	$timeString = ""
	$timeList | ForEach-Object { $timeString += $_ }
	$time = [long]$timeString
}
if ($distanceLine -match 'Distance:(.*)') {
	$distanceList = $matches[1].Trim() -split '\s+'
	
	$distanceString = ""
	$distanceList | ForEach-Object { $distanceString += $_ }
	$distance = [long]$distanceString
}

$speedMax = $time -1
$speedMin = 1
$winSpeedMin = [long]::MaxValue
$currentSpeed = 1
while ([Math]::Abs($speedMax - $speedMin) -gt 1) {
	$remainTime = $time - $currentSpeed
	$moveDistance = $currentSpeed * $remainTime
	
	if ($moveDistance -le $distance) {
		$speedMin = $currentSpeed
		$currentSpeed = $currentSpeed + [Math]::Floor(($speedMax - $currentSpeed) / 2)
	}
	else {
		$speedMax = $currentSpeed
		$winSpeedMin = $currentSpeed
		$currentSpeed = $currentSpeed - [Math]::Floor(($currentSpeed - $speedMin) / 2)
	}
}

$speedMax = $time - 1
$speedMin = 1
$winSpeedMax = 0
$currentSpeed = $time - 1
while ([Math]::Abs($speedMax - $speedMin) -gt 1) {
	$remainTime = $time - $currentSpeed
	$moveDistance = $currentSpeed * $remainTime
	
	if ($moveDistance -le $distance) {
		$speedMax = $currentSpeed
		$currentSpeed = [Math]::Floor($currentSpeed / 2)
	}
	else {
		$speedMin = $currentSpeed
		$winSpeedMax = $currentSpeed
		$currentSpeed = $currentSpeed + [Math]::Floor(($speedMax - $currentSpeed) / 2)
	}
}

$result = $winSpeedMax - $winSpeedMin + 1
Write-Host "Result: $result"