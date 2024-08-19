Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

Function Parse($str) {
    $idx = 0
    $length = $str.Length - 1

    Function ParseNumber($str, $idx) {
        $start = $idx
        while ($idx -lt $length -and $str[$idx] -match '\d') {
            $idx++
        }
        $value = [int64]$str.Substring($start, $idx - $start)
        return @{parsed = $value; idx = $idx }
    }

    Function ParseArray($str, $idx) {
        $idx++ # '['
        $arr = @()
        while ($idx -lt $length) {
            $char = $str[$idx]

            if ($char -eq '[') {
                $result = ParseArray $str $idx
                $arr += , $result.parsed
                $idx = $result.idx
            }
            elseif ($char -eq ']') {
                $idx++
                return @{parsed = $arr; idx = $idx }
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
        return @{parsed = $arr; idx = $idx }
    }
    $result = ParseArray $str $idx
    return @(, $result.parsed)
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

Function SortList {
    param (
        $array
    )
    process {
        for ($i = 1; $i -lt $array.Length; $i++) {
            $j = $i - 1
            while ($j -ge 0) {
                $result = CompareList $array[$j] $array[$j + 1]
                if ($result -eq $false) {
                    $temp = $array[$j]
                    $array[$j] = $array[$j + 1]
                    $array[$j + 1] = $temp
                }
                $j--
            }
        }
    }
}

$lines = Get-Content -Path "./$dataFile"
$lines += "`n[[2]]"
$lines += "`n[[6]]"

$list = @()
$lines | ForEach-Object {
    if ([string]::IsNullOrEmpty($_)) {
        return
    }
    $list += , (Parse $_)
}
SortList $list

$results = @()
$list | ForEach-Object -Begin { $i = 1 } -Process {
    if ($_ -is [array] -and $_.Length -eq 1 -and $_[0] -is [array] -and $_[0].Length -eq 1) {
        if ($_[0][0] -eq 2) {
            $results += $i
        }
        elseif ($_[0][0] -eq 6) {
            $results += $i
        }
    }
    $i++
}

$results | ForEach-Object -Begin { $result = 1 } -Process { $result *= $_ }
Write-Host "Result: $result"
