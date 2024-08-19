Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

Function Extrapolate-Next {
    Param($Numbers)
    $removeZeroLen = ($Numbers | Where-Object { $_ -ne 0 }).Length
    if ($removeZeroLen -eq 0) {
        return $Numbers[-1]
    }
    $intervals = @()
    for ($i = 1; $i -lt $Numbers.Length; $i++) {
        $intervals += ($Numbers[$i] - $Numbers[$i - 1])
    }

    $extrapolate = Extrapolate-Next $intervals
    return $intervals[-1] + $extrapolate
}

$lines = Get-Content -Path "./$dataFile"
$lines | ForEach-Object {
	$numbers = $_.Split() | ForEach-Object { [long]$_ }
    [array]::Reverse($numbers)
    $extrapolate = Extrapolate-Next $numbers
    $result += ($numbers[-1] + $extrapolate)
}

Write-Host "Result: $result"
