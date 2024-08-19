Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

$value = 1
$totalLoop = 0
$result = 0

$lines | ForEach-Object {
	$command, $add = $_ -Split ' '

	$loop = switch ($command) {
		"noop" { 1 }
		"addx" { 2 }
	}

	for ($i = 0; $i -lt $loop; $i++) {
		$totalLoop++
		if ($totalLoop -ge 20 -and $totalLoop -le 220) {
			if (($totalLoop - 20) % 40 -eq 0) {
				$result += ($totalLoop * $value)
			}
		}
		if ($i -eq 1) {
			$value += [int]$add
		}
	}
}

Write-Host "Result:" $result