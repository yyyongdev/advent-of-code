Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0
$A = $null
$B = $null

Function Parse($str) {
    $idx = 0
    $length = $str.Length - 1

    Function ParseNumber($str, $idx) {
        $start = $idx
        while ($idx -lt $length -and $str[$idx] -match '\d') {
            $idx++
        }
        $value = [int64]$str.Substring($start, $idx - $start)
        return @{parsed=$value; idx=$idx}
    }

    Function ParseArray($str, $idx) {
        $idx++ # '['
        $arr = @()
        while ($idx -lt $length) {
            $char = $str[$idx]

            if ($char -eq '[') {
                $result = ParseArray $str $idx
                $arr += ,$result.parsed
                $idx = $result.idx
            }
            elseif ($char -eq ']') {
                $idx++
                return @{parsed=$arr; idx=$idx}
            }
            elseif ($char -eq ',') {
                $idx++
            }
            elseif ($char -match '\d') {
                $result = ParseNumber $str $idx
                $arr += $result.parsed
                $idx = $result.idx
            }
        }
        return @{parsed=$arr; idx=$idx}
    }
    $result = ParseArray $str $idx
    return @(,$result.parsed)
}

Function CompareList($lhs, $rhs) {
    $minLength = [Math]::Min($lhs.Length, $rhs.Length)

    for ($i = 0; $i -lt $minLength; $i++) {
        $elemA = $lhs[$i]
        $elemB = $rhs[$i]
        if ($elemA -is [int64] -and $elemB -is [int64]) {
            if ($elemA -lt $elemB) {
                return $true
            }
            elseif ($elemA -gt $elemB) {
                return $false
            }
        }
        elseif ($elemA -is [array] -and $elemB -is [array]) {
            $result = CompareList $elemA $elemB
            if ($null -ne $result) {
                return $result
            }
        }
        elseif ($elemA -is [int64] -and $elemB -is [array]) {
            $result = CompareList @($elemA) $elemB
            if ($null -ne $result) {
                return $result
            }
        }
        elseif ($elemA -is [array] -and $elemB -is [int64]) {
            $result = CompareList $elemA @($elemB)
            if ($null -ne $result) {
                return $result
            }
        }
        else {
            Write-Error "Unknown type detected"
        }
    }
    if ($lhs.Length -lt $rhs.Length) {
        return $true
    }
    elseif ($lhs.Length -gt $rhs.Length) {
        return $false
    }
    return $null
}

$lines = Get-Content -Path "./$dataFile"
$lines | Where-Object { -not [string]::IsNullOrEmpty($_) } | ForEach-Object -Begin { $i = 1 } -Process {
    if ($A -eq $null) {
        $A = $_
    }
    elseif ($B -eq $null) {
        $B = $_
    }
    
    if (@($A, $B) -notcontains $null) {
        $parsedA = Parse $A
        $parsedB = Parse $B

        if (CompareList $parsedA $parsedB) {
            $result += $i
        }
        $A = $null
        $B = $null
        $i++
    }
}

Write-Host "Result: $result"
