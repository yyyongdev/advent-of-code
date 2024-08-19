Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

$head = @{x = 0; y = 0 }
$tail = @{x = 0; y = 0 }

$tailSteps = New-Object System.Collections.Generic.HashSet[string]

$lines | ForEach-Object {
	$dir, $count = $_ -Split ' '
	for ($i = 0; $i -lt [int]$count; $i++) {
		$move = switch ($dir) {
			"R" { @{x = 1; y = 0 } }
			"L" { @{x = -1; y = 0 } }
			"U" { @{x = 0; y = 1 } }
			"D" { @{x = 0; y = -1 } }
		}
		$head.x += $move.x
		$head.y += $move.y

		if ($head.x - $tail.x -gt 1) {
			$tail.x += 1
			$tail.y = $head.y
		}
		elseif ($tail.x - $head.x -gt 1) {
			$tail.x -= 1
			$tail.y = $head.y
		}
		if ($head.y - $tail.y -gt 1) {
			$tail.x = $head.x
			$tail.y += 1
		}
		elseif ($tail.y - $head.y -gt 1) {
			$tail.x = $head.x
			$tail.y -= 1
		}
		$tailSteps.Add("$($tail.x)_$($tail.y)") | Out-Null
	}
}

Write-Host "Result:" $tailSteps.Count