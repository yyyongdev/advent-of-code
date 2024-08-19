Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0
$bonusCards = @{}

Function Add-BonusCard($CardNumber, $Count) {
    if ($null -eq $bonusCards[$CardNumber]) {
        $bonusCards[$CardNumber] = 1
    }
    $bonusCards[$CardNumber] += $Count
}

Function Get-BonusCardCount($CardNumber) {
    if ($null -eq $bonusCards[$CardNumber]) {
        return 1
    }
    else {
        return $bonusCards[$CardNumber]
    }
}

$lines = Get-Content -Path "./$dataFile"
$lines | ForEach-Object {
    $result++
    if ($_ -match 'Card(.*):') {
        $cardNumber = [int]$matches[1]
    }
	if ($_ -match ':(.*?)\|') {
        $numbers = $matches[1].Split().Trim() | Where-Object { $_ -ne "" }
    }
    if ($_ -match '\|(.*)') {
        $pickNumbers = $matches[1].Split().Trim() | Where-Object { $_ -ne "" }
    }
    $corrects = $numbers | Where-Object { $pickNumbers.Contains($_) }
    $bonusCount = Get-BonusCardCount $cardNumber
    $corrects | ForEach-Object -Begin { $bonusCardNumber = $cardNumber + 1 } -Process {
        Add-BonusCard $bonusCardNumber $bonusCount
        $bonusCardNumber++
        $result += $bonusCount
    }
}

Write-Host "Result: $result"
