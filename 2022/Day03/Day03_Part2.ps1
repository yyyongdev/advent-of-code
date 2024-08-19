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

$valueTable = @{}
$keyTable = @{}
$bit = [int64]1
foreach ($i in $lowerA..$lowerZ) {
	$valueTable[([byte][char]$i)] = $bit
	$keyTable[$bit] = $i
	$bit = $bit -shl 1
}
foreach ($i in $upperA..$upperZ) {
	$valueTable[([byte][char]$i)] = $bit
	$keyTable[$bit] = $i
	$bit = $bit -shl 1
}

$total = 0
$elfCount = 0
$elves = @([int64]0, [int64]0, [int64]0)
$lines | ForEach-Object {
	$len = $PSItem.Length
	for($i = 0; $i -lt $len; $i++) {
		$key = ([byte][char]$PSItem[$i])
		$value = $valueTable[$key]
		$elves[$elfCount] = ($elves[$elfCount] -bor $value)
	}
	$elfCount++

	if ($elfCount -eq 3) {
		$value = ($elves[0] -band $elves[1] -band $elves[2])
		$key = $keyTable[$value]
		$total += $scoreTable[([byte][char]$key)]

		$elfCount = 0
		$elves = @([int64]0, [int64]0, [int64]0)
	}
}

Write-Host "Result:" $total