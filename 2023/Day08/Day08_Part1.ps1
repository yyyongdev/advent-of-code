Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

$directionInstructions, $lines = Get-Content -Path "./$dataFile"
$directionCount = $directionInstructions.Length
$map = @{}
$currentNode = 'AAA'

$lines | ForEach-Object {
    if ($_ -match '([A-Z]*) = \(([A-Z]*), ([A-Z]*)\)') {
        $node = $matches[1]
        $left = $matches[2]
        $right = $matches[3]
        $map[$node] = @{ 'Left' = $left; 'Right' = $right }
    }
}

while ($currentNode -ne 'ZZZ') {
    for ($i = 0; $i -lt $directionCount; $i++) {
        $direction = $directionInstructions[$i]
        $currentNode = switch ($direction) {
            'R' { $map[$currentNode]['Right'] }
            'L' { $map[$currentNode]['Left'] }
        }
        $result++
    }
}

Write-Host "Result: $result"
