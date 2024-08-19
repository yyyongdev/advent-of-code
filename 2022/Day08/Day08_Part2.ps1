Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

$colCount = $lines.Length
$rowCount = $lines[0].Length
$highScore = 0

Function CalculateScore {
	Param ($row, $col, $house, $lines)
	
	# view to left
	$scoreLeft = 0
	for ($i = $col - 1; $i -ge 0; $i--) {
		$scoreLeft++
		$line = $lines[$row]
		$tree = [System.Int32]::Parse($line[$i])
		if ($tree -ge $house) {
			break
		}
	}
	
	# view to right
	$scoreRight = 0
	for ($i = $col + 1; $i -lt $rowCount; $i++) {
		$scoreRight++
		$line = $lines[$row]
		$tree = [System.Int32]::Parse($line[$i])
		if ($tree -ge $house) {
			break
		}
	}
	
	# view to top
	$scoreTop = 0
	for ($i = $row - 1; $i -ge 0; $i--) {
		$scoreTop++
		$tree = [System.Int32]::Parse($lines[$i][$col])
		if ($tree -ge $house) {
			break
		}
	}

	# view to bottom
	$scoreBottom = 0
	for ($i = $row + 1; $i -lt $colCount; $i++) {
		$scoreBottom++
		$tree = [System.Int32]::Parse($lines[$i][$col])
		if ($tree -ge $house) {
			break
		}
	}

	return $scoreLeft * $scoreRight * $scoreTop * $scoreBottom
}

for ($row = 1; $row -lt $rowCount - 1; $row++) {
	for ($col = 1; $col -lt $colCount - 1; $col++) {
		$house = [System.Int32]::Parse($lines[$row][$col])
		$score = CalculateScore $row $col $house $lines
		if ($score -gt $highScore) {
			$highScore = $score
		}
	}
}

Write-Host "Result:" $highScore