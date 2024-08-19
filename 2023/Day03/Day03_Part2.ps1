Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0
$lines = Get-Content -Path "./$dataFile"

$rowCount = $lines.Length
$colCount = $lines[0].Length
$nearAsterisks = @{}

Function IsAsterisk($Lines, $X, $Y) {
    return ($Lines[$Y][$X] -eq "*") 
}

Function IsNearByAsterisk($Lines, [int]$X, [int]$Y, [int]$Len) {
    # Left
    if ($X -gt 0) {
        if (IsAsterisk $Lines ($X - 1) $Y) {
            return ($X - 1), $Y
        }
    }
    # Right
    if ($X + $Len -lt $colCount) {
        if (IsAsterisk $Lines ($X + $Len) $Y) {
            return ($X + $Len), $Y
        }
    }
    # Top
    if ($Y -gt 0) {
        for ($i = 0; $i -lt $Len; $i++) {
            if (IsAsterisk $Lines ($X + $i) ($Y - 1)) {
                return  ($X + $i), ($Y - 1)
            }
        } 
    }
    # Bottom
    if ($Y + 1 -lt $rowCount) {
        for ($i = 0; $i -lt $Len; $i++) {
            if (IsAsterisk $Lines ($X + $i) ($Y + 1)) {
                return ($X + $i), ($Y + 1)
            }
        }
    }
    # Left + Top
    if ($X -gt 0 -and $Y -gt 0) {
        if (IsAsterisk $Lines ($X - 1) ($Y - 1)) {
            return ($X - 1), ($Y - 1)
        }
    }
    # Left + Bottom
    if ($X -gt 0 -and $Y + 1 -lt $rowCount) {
        if (IsAsterisk $Lines ($X - 1) ($Y + 1)) {
            return ($X - 1), ($Y + 1)
        }
    }
    # Right + Top
    if ($X + $Len -lt $colCount -and $Y -gt 0) {
        if (IsAsterisk $Lines ($X + $Len) ($Y - 1)) {
            return ($X + $Len), ($Y - 1)
        }
    }
    # Right + Bottom
    if ($X + $Len -lt $colCount -and $Y + 1 -lt $rowCount) {
        if (IsAsterisk $Lines ($X + $Len) ($Y + 1)) {
            return ($X + $Len), ($Y + 1)
        }
    }
    return $null
}

for ($y = 0; $y -lt $rowCount; $y++) {
    $num = ""
    for ($x = 0; $x -lt $colCount; $x++) {
        if ($lines[$y][$x] -match '\d') {
            $num += $lines[$y][$x]
        }
        elseif ([string]::IsNullOrEmpty($num) -eq $false) {   
            $asteriskX, $asteriskY = IsNearByAsterisk $lines ($x - $num.Length) $y $num.Length
            if ($null -ne $asteriskX) {
                $key = "${asteriskX}:${asteriskY}"
                if ($null -eq $nearAsterisks[$key]) {
                    $nearAsterisks[$key] = [int]$num
                }
                else {
                    $result += ($nearAsterisks[$key] * [int]$num)
                }
            }
            $num = ""    
        }
    }
}

Write-Host "Result: $result"