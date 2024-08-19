Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

$lines = Get-Content -Path "./$dataFile"
$lines | ForEach-Object {
	$line = $_
	$numbers = @()

	$line.ToCharArray() | ForEach-Object {
		if ($_ -match '\d') {
			$numbers += $_
		}
    }
	$lineNumber = "$($numbers[0])$($numbers[-1])"
	$result += [int]$lineNumber
}

Write-Host "Result: $result"