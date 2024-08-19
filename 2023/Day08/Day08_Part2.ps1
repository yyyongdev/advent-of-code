Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = [long]1

$directionInstructions, $lines = Get-Content -Path "./$dataFile"
$directionCount = $directionInstructions.Length
$map = @{}
$currents = @()

$lines | ForEach-Object {
    if ($_ -match '([0-9A-Z]*) = \(([0-9A-Z]*), ([0-9A-Z]*)\)') {
        $node = $matches[1]
        $left = $matches[2]
        $right = $matches[3]
        $map[$node] = @{ 'Left' = $left; 'Right' = $right }

        if ($node -match '([0-9A-Z].A)') {
            $currents += @{ 'Node' = $node; 'Goal' = 0 }
        }
    }
}
$nodeCount = $currents.Length
$count = 0

while ($true) {
    for ($i = 0; $i -lt $directionCount; $i++) {
        $direction = $directionInstructions[$i]
        $count++

        for ($j = 0; $j -lt $nodeCount; $j++) {
            $current = $currents[$j]
            if ($current.Goal -eq 0) {
                $currents[$j].Node = switch ($direction) {
                    'R' { $map[$current.Node]['Right'] }
                    'L' { $map[$current.Node]['Left'] }
                }
                if ($currents[$j].Node -match '[0-9A-Z]{2}Z') {
                    $currents[$j].Goal = $count
                }
            }
        }
    }
    if (($currents | Where-Object { $_.Goal -eq 0 }).Length -eq 0) {
        break
    }
}

function Get-GCD {
    param (
        [long]$a,
        [long]$b
    )

    while ($b -ne 0) {
        $temp = $b
        $b = $a % $b
        $a = $temp
    }

    return $a
}

function Get-LCM {
    param (
        [long[]]$numbers
    )

    $lcm = 1
    foreach ($number in $numbers) {
        $lcm = ($lcm * $number) / (Get-GCD $lcm $number)
    }

    return $lcm
}

$result = Get-LCM ($currents | ForEach-Object { [long]$_.Goal })
Write-Host "Result: $result"
