Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

$lines = Get-Content -Path "./$dataFile"
$lines | ForEach-Object {
	$line = $_
	$splitByColon = $line.Split(':')

    $fewestCubes = @{
        'red'   = 0
        'green' = 0
        'blue'  = 0
    }

	$games = $splitByColon[1].Split(';')
	$games | ForEach-Object {
		$pickedCubes = $_.Split(',')
		$pickedCubes | ForEach-Object {
			$pickedInfo = $_.Trim().Split()
			$count = [int]$pickedInfo[0]
			$color = $pickedInfo[1]

			$fewestCount = $fewestCubes[$color]
            if ($count -gt $fewestCount) {
                $fewestCubes[$color] = $count
            }
		}
	}
	
    $powerOfSet = [int]$fewestCubes['red'] * [int]$fewestCubes['green'] * [int]$fewestCubes['blue']
    $result += $powerOfSet
}

Write-Host "Result: $result"