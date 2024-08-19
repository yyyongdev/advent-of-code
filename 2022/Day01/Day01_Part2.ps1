Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

$totals = @()
$temp = 0
$lines | Foreach-Object {
	if ($PSItem.Length -gt 0) {
		$temp += [int]$PSItem
	}
	else {
		$totals += @($temp)
		$temp = 0
	}
}

Write-Host ($totals | Sort-Object -Descending | Select-Object -First 3 | Measure-Object -Sum).Sum