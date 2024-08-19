Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

$lowerA = [byte][char]'a'
$lowerZ = [byte][char]'z'
$upperA = [byte][char]'A'
$upperZ = [byte][char]'Z'
$scoreTable = @{}

foreach ($i in $lowerA..$lowerZ) {
	$scoreTable[([byte][char]$i)] = $i - $lowerA + 1
}
foreach ($i in $upperA..$upperZ) {
	$scoreTable[([byte][char]$i)] = $i - $upperA + 27
}

$total = 0
$lines | ForEach-Object {
	$half = $PSItem.Length / 2
	$first = $PSItem.Substring(0, $half)
	$second = $PSItem.Substring($half)

	$checkTable = @{}
	($first -Split '\B') | ForEach-Object {
		$checkTable[[byte][char]$PSItem] = $true
	}

	$len = $second.Length
	for ($i = 0; $i -lt $len; $i++) {
		$key = $second[$i]
		if ($checkTable.ContainsKey([byte][char]$key)) {
			$total += $scoreTable[([byte][char]$key)]
			break;
		}
	}
}

Write-Host "Result:" $total