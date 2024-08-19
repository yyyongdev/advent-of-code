Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

$lines = Get-Content -Path "./$dataFile"
$height = $lines.Length
$width = $lines[0].Length
$map = New-Object 'object[,]' $height, $width
$currentCell = $null
$distance = 0

for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        $cellInfo = @{
            'X'        = [int]$x
            'Y'        = [int]$y
            'Pipe'     = $lines[$y][$x]
            'Distance' = [int]::MaxValue
            'Parent'   = $null
            'IsCycle'  = $false
        }
        if ($lines[$y][$x] -eq 'S') {
            $currentCell = $cellInfo
            $cellInfo.Distance = $distance
        }
        $map[$y, $x] = $cellInfo
    }
}

Function Set-CycleMark($map, $cell) {
    $target = $cell
    while($target.Pipe -ne 'S') {
        $target.IsCycle = $true
        $target = $map[$target.Parent.Y, $target.Parent.X]
    }
}

Function Set-AroundDistance($map, $cell) {
    $curX = $cell.X
    $curY = $cell.Y
    $distance = $cell.Distance + 1
    $cellPipe = $cell.Pipe
    
    if ($curX -gt 0) {
        $left = $map[$curY, ($curX - 1)]
        if ($cell.Parent -ne $left) {
            if ($left.Distance -gt $distance `
                    -and $left.Pipe -match '[FL-]' `
                    -and $cellPipe -match '[7JS-]') {
                $left.Distance = $distance
                $left.Parent = @{ 'X' = $cell.X; 'Y' = $cell.Y; 'Pipe' = $cell.Pipe}
                Set-AroundDistance $map $left
            }
            if ($left.Pipe -eq 'S') {
                Set-CycleMark $map $cell
            }
        }
    }
    if ($curX -lt $width - 1) {
        $right = $map[$curY, ($curX + 1)]
        if ($cell.Parent -ne $right) {
            if ($right.Distance -gt $distance `
                    -and $right.Pipe -match '[7J-]' `
                    -and $cellPipe -match '[FLS-]') {
                $right.Distance = $distance
                $right.Parent = @{ 'X' = $cell.X; 'Y' = $cell.Y; 'Pipe' = $cell.Pipe}
                Set-AroundDistance $map $right
            }
            if ($right.Pipe -eq 'S') {
                Set-CycleMark $map $cell
            }
        }
    }
    if ($curY -gt 0) {
        $top = $map[($curY - 1), $curX]
        if ($cell.Parent -ne $top) {
            if ($top.Distance -gt $distance `
                    -and $top.Pipe -match '[7F|]' `
                    -and $cellPipe -match '[JLS|]') {
                $top.Distance = $distance
                $top.Parent = @{ 'X' = $cell.X; 'Y' = $cell.Y; 'Pipe' = $cell.Pipe}
                Set-AroundDistance $map $top
            }
            if ($top.Pipe -eq 'S') {
                Set-CycleMark $map $cell
            }
        }
    }
    if ($curY -lt $height - 1) {
        $bottom = $map[($curY + 1), $curX]
        if ($cell.Parent -ne $bottom) {
            if ($bottom.Distance -gt $distance `
                    -and $bottom.Pipe -match '[JL|]' `
                    -and $cellPipe -match '[7FS|]') {
                $bottom.Distance = $distance
                $bottom.Parent = @{ 'X' = $cell.X; 'Y' = $cell.Y; 'Pipe' = $cell.Pipe}
                Set-AroundDistance $map $bottom
            }
            if ($bottom.Pipe -eq 'S') {
                Set-CycleMark $map $cell
            }
        }
    }
}

Set-AroundDistance $map $currentCell


for ($y = 0; $y -lt $height; $y++) {
    $test = ""
    for ($x = 0; $x -lt $width; $x++) {
        $distance = $map[$y, $x].Distance
        if ($distance -ne [int]::MaxValue) {
            $result = [Math]::Max($result, $distance)
        }

        if ($distance -eq [int]::MaxValue) {
            $test += '- '
        }
        elseif ($map[$y, $x].Pipe -eq 'S') {
            $test += 'S '
        }
        elseif ($map[$y, $x].IsCycle -eq $false) {
            $test += '. '
        }
        else {
            $test += "$distance "
            # $test += $map[$y,$x].Pipe
        }
    }
    Write-Host $test
}

Write-Host "Result: $result"
