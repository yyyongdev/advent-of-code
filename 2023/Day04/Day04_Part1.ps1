Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

$lines = Get-Content -Path "./$dataFile"
$lines | ForEach-Object {
	if ($_ -match ':(.*?)\|') {
        $numbers = $matches[1].Trim().Split() | Where-Object { $_ -ne "" }
    }
    if ($_ -match '\|(.*)') {
        $pickNumbers = $matches[1].Trim().Split() | Where-Object { $_ -ne "" }
    }
    
    $corrects = @()
    $corrects += ($numbers | Where-Object { $pickNumbers.Contains($_) })

    $correctCount = $corrects.Length
    $score = $correctCount -eq 0 ? 0 : [Math]::Pow(2, $correctCount - 1)
    $result += $score
}

Write-Host "Result: $result"