Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

$allCubes = @{
	'red'   = 12
	'green' = 13
	'blue'  = 14
}

$lines = Get-Content -Path "./$dataFile"
$lines | ForEach-Object {
	$line = $_
	$splitByColon = $line.Split(':')
	$gameName = $splitByColon[0]
	$gameId = [int]$gameName.Split()[1]

	$isPossible = $true
	$games = $splitByColon[1].Split(';')
	$games | ForEach-Object {
		$pickedCubes = $_.Split(',')
		$pickedCubes | ForEach-Object {
			$pickedInfo = $_.Trim().Split()
			$count = $pickedInfo[0]
			$color = $pickedInfo[1]

			if ($allCubes[$color] -lt $count) {
				$isPossible = $false
			}
		}
	}
	if ($isPossible) {
		$result += $gameId
	}
}

Write-Host "Result: $result"