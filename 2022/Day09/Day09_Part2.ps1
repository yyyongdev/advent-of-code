Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

$ropes = @()
1..10 | ForEach-Object {
	$ropes += @{x = 0; y = 0 }
}

$lastTailSteps = New-Object System.Collections.Generic.HashSet[string]

Function Follow {
	Param($head, $tail)
	$horizontal = 0
	$vertical = 0

	if ($head.x - $tail.x -gt 1) {
		$horizontal = 1
	}
	elseif ($tail.x - $head.x -gt 1) {
		$horizontal = -1
	}
	if ($head.y - $tail.y -gt 1) {
		$vertical = 1
	}
	elseif ($tail.y - $head.y -gt 1) {
		$vertical = -1
	}

	if ($horizontal -ne 0 -and $vertical -ne 0) {
		$tail.x += $horizontal
		$tail.y += $vertical
	}
	elseif ($horizontal -ne 0) {
		$tail.x += $horizontal
		$tail.y = $head.y
	}
	elseif ($vertical -ne 0) {
		$tail.x = $head.x
		$tail.y += $vertical
	}
}

$lines | ForEach-Object {
	$dir, $count = $_ -Split ' '

	for ($i = 0; $i -lt [int]$count; $i++) {
		$move = switch ($dir) {
			"R" { @{x = 1; y = 0 } }
			"L" { @{x = -1; y = 0 } }
			"U" { @{x = 0; y = 1 } }
			"D" { @{x = 0; y = -1 } }
		}
		$ropes[0].x += $move.x
		$ropes[0].y += $move.y

		for ($ropeIdx = 1; $ropeIdx -lt $ropes.Count; $ropeIdx++) {
			Follow $ropes[$ropeIdx - 1] $ropes[$ropeIdx]
		}
		$lastTail = $ropes[-1]
		$lastTailSteps.Add("$($lastTail.x)_$($lastTail.y)") | Out-Null
	}
}

Write-Host "Result:" $lastTailSteps.Count