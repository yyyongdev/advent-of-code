Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

Function ConvertToNumber {
	Param ([string]$TextNumber)
	
	$value = switch ($TextNumber.toLower()) {
		one { 1 }
		two { 2 }
		three { 3 }
		four { 4 }
		five { 5 }
		six { 6 }
		seven { 7 }
		eight { 8 }
		nine { 9 }
		default { $TextNumber }
	}
	return $value
}

$numberNames = @(
	"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", 
	"1", "2", "3", "4", "5", "6", "7", "8", "9")

$lines = Get-Content -Path "./$dataFile"
$lines | ForEach-Object {
	$line = $_
	$minIndex = $line.Length
	$maxIndex = -1
	$firstValue = 0
	$lastValue = 0

	for ($i = 0; $i -lt $numberNames.Length; $i++) {
		$firstFindIndex = $line.IndexOf($numberNames[$i])
		$lastFindIndex = $line.LastIndexOf($numberNames[$i])

		if ($firstFindIndex -ge 0) {
			if ([Math]::Min($minIndex, $firstFindIndex) -ne $minIndex) {
				$firstValue = ConvertToNumber -TextNumber $numberNames[$i]
				$minIndex = $firstFindIndex
			}
		}
		if ($lastFindIndex -ge 0) {
			if ([Math]::Max($maxIndex, $lastFindIndex) -ne $maxIndex) {
				$lastValue = ConvertToNumber -TextNumber $numberNames[$i]
				$maxIndex = $lastFindIndex
			}
		}
	}	
	$lineNumber = "${firstValue}${lastValue}"
	$result += [int]$lineNumber
}

Write-Host "Result: $result"

