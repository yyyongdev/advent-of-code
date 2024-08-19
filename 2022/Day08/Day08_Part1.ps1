Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

$visibleSet = [System.Collections.Generic.HashSet[String]]::new()

$colCount = $lines.Length
$rowCount = $lines[0].Length

# view from left
for ($row = 0; $row -lt $rowCount; $row++) {
	$tallest = -1
	for ($col = 0; $col -lt $colCount; $col++) {
		$height = [int]($lines[$row][$col])
		if ($height -gt $tallest) {
			$tallest = $height
			$key = "$col,$row"
			$visibleSet.Add($key) | Out-Null
		}
	}
}

# view from right
for ($row = 0; $row -lt $rowCount; $row++) {
	$tallest = -1
	for ($col = $colCount-1; $col -ge 0; $col--) {
		$height = [int]($lines[$row][$col])
		if ($height -gt $tallest) {
			$tallest = $height
			$key = "$col,$row"
			$visibleSet.Add($key) | Out-Null
		}
	}
}

# view from top
for ($col = 0; $col -lt $colCount; $col++) {
	$tallest = -1
	for ($row = 0; $row -lt $rowCount; $row++) {
		$height = [int]($lines[$row][$col])
		if ($height -gt $tallest) {
			$tallest = $height
			$key = "$col,$row"
			$visibleSet.Add($key) | Out-Null
		}
	}
}

# view from bottom
for ($col = 0; $col -lt $colCount; $col++) {
	$tallest = -1
	for ($row = $rowCount-1; $row -ge 0; $row--) {
		$height = [int]($lines[$row][$col])
		if ($height -gt $tallest) {
			$tallest = $height
			$key = "$col,$row"
			$visibleSet.Add($key) | Out-Null
		}
	}
}

Write-Host "Result:" $visibleSet.Count