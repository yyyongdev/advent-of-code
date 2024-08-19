Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

$MOVE_X = @(0, 1, 0, -1)
$MOVE_Y = @(-1, 0, 1, 0)

$startX = 0
$startY = 0

$row = $lines.Length
$col = $lines[0].Length

$visited = @()

for ($i = 0; $i -lt $row; $i++) {
    $visited += ,@()
    for ($j = 0; $j -lt $col; $j++) {
        $visited[$i] += $false
        if ($lines[$i][$j] -ceq 'E') {
            $startY = $i
            $startX = $j
        }
    }
}

Function Get-Neighbors($x, $y) {
    $neighbors = @()
    
    for ($i = 0; $i -lt 4; $i++) {
        $nextX = $x + $MOVE_X[$i]
        $nextY = $y + $MOVE_Y[$i]

        if($nextX -ge 0 -and $nextX -lt $col -and $nextY -ge 0 -and $nextY -lt $row) {
            $neighbors += @{ x=$nextX; y=$nextY }
        }
    }
    return $neighbors
}

Function Get-Height($target) {
    if ($target -ceq 'S') {
        return [int][char]'a'
    }
    elseif ($target -ceq 'E') {
        return [int][char]'z'
    }
    return [int][char]$target
}

Function Can-Move($from, $to) {
    $fromHeight = Get-Height($from)
    $toHeight = Get-Height($to)
    
    return $fromHeight -le $toHeight + 1
}

Function BFS($map, $x, $y, $visited, $step) {
    $queue = [System.Collections.Queue]::new()
    $queue.Enqueue(@{x=$x; y=$y; step=$step})
    $visited[$y][$x] = $true

    while($queue.Count -gt 0) {
        $current = $queue.Dequeue()
        $x = $current.x
        $y = $current.y
        $step = $current.step

        if ($map[$y][$x] -ceq 'a' -or $map[$y][$x] -ceq 'S') {
            return $step
        }
        
        $neighbors = Get-Neighbors -x $x -y $y

        foreach ($neighbor in $neighbors) {
            $nx = $neighbor.x
            $ny = $neighbor.y

            if (-not $visited[$ny][$nx] -and (Can-Move $map[$y][$x] $map[$ny][$nx])) {
                $visited[$ny][$nx] = $true
                $queue.Enqueue(@{x=$nx; y=$ny; step=($step + 1)})
            }
        }
    }
    return 'Not Found'
}

$result = BFS -map $lines -x $startX -y $startY -visited $visited -step 0
Write-Host "Result:" $result
