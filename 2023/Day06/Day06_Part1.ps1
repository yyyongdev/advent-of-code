Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

$timeLine, $distanceLine = Get-Content -Path "./$dataFile"
if ($timeLine -match 'Time:(.*)') {
	$timeList = $matches[1].Trim() -split '\s+'
}
if ($distanceLine -match 'Distance:(.*)') {
	$distanceList = $matches[1].Trim() -split '\s+'
}

$wins = @()
$zip = [System.Linq.Enumerable]::Zip($timeList, $distanceList)
$zip | ForEach-Object {
	$time = [int]$_.Item1
	$distance = [int]$_.Item2
	$win = 0
	for ($i = 1; $i -le $time; $i++) {
		$remainTime = $time - $i
		$speed = $i
		$moveDistance = $speed * $remainTime
		if ($moveDistance -gt $distance) {
			$win++
		}
	}
	$wins += $win
}
$result = 1
$wins | Foreach-Object { $result *= $_ }
Write-Host "Result: $result"