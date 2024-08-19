Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0
$lines = Get-Content -Path "./$dataFile"

for ($i = 0; $i -lt $lines.Length; $i++) {
    $lines[$i] = "$($lines[$i])."
}

$rowCount = $lines.Length
$colCount = $lines[0].Length

Function IsSpecialCharacter($Lines, $X, $Y) {
    return ($Lines[$Y][$X] -match '[^0-9.]') 
}

Function IsNearBySpecialChar($Lines, [int]$X, [int]$Y, [int]$Len) {
    # Left
    if ($X -gt 0) {
        if (IsSpecialCharacter $Lines ($X - 1) $Y) {
            return $true
        }
    }
    # Right
    if ($X + $Len -lt $colCount) {
        if (IsSpecialCharacter $Lines ($X + $Len) $Y) {
            return $true
        }
    }
    # Top
    if ($Y -gt 0) {
        for ($i = 0; $i -lt $Len; $i++) {
            if (IsSpecialCharacter $Lines ($X + $i) ($Y - 1)) {
                return $true
            }
        } 
    }
    # Bottom
    if ($Y + 1 -lt $rowCount) {
        for ($i = 0; $i -lt $Len; $i++) {
            if (IsSpecialCharacter $Lines ($X + $i) ($Y + 1)) {
                return $true
            }
        }
    }
    # Left + Top
    if ($X -gt 0 -and $Y -gt 0) {
        if (IsSpecialCharacter $Lines ($X - 1) ($Y - 1)) {
            return $true
        }
    }
    # Left + Bottom
    if ($X -gt 0 -and $Y + 1 -lt $rowCount) {
        if (IsSpecialCharacter $Lines ($X - 1) ($Y + 1)) {
            return $true
        }
    }
    # Right + Top
    if ($X + $Len -lt $colCount -and $Y -gt 0) {
        if (IsSpecialCharacter $Lines ($X + $Len) ($Y - 1)) {
            return $true
        }
    }
    # Right + Bottom
    if ($X + $Len -lt $colCount -and $Y + 1 -lt $rowCount) {
        if (IsSpecialCharacter $Lines ($X + $Len) ($Y + 1)) {
            return $true
        }
    }
    return $false
}

for ($y = 0; $y -lt $rowCount; $y++) {
    $num = ""
    for ($x = 0; $x -lt $colCount; $x++) {
        if ($lines[$y][$x] -match '\d') {
            $num += $lines[$y][$x]
        }
        elseif ([string]::IsNullOrEmpty($num) -eq $false) {   
            if (IsNearBySpecialChar $lines ($x - $num.Length) $y $num.Length) {
                $result += [int]$num
            }
            $num = ""    
        }
    }
}

Write-Host "Result: $result"