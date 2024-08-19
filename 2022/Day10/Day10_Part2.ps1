Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

$value = 1
$totalLoop = 0
$screenWidth = 40
$pixels = New-Object System.Collections.Generic.List[char]
$spritePosition = "###....................................."

Function GetSprite($value) {
	$ret = ""
	for($i = 0; $i -lt $screenWidth; $i++) {
		$ret += "."
	}
}

$lines | ForEach-Object {
	$command, $add = $_ -Split ' '

	$loop = switch ($command) {
		"noop" { 1 }
		"addx" { 2 }
	}

	for ($i = 0; $i -lt $loop; $i++) {
		$pixel = $spritePosition[$totalLoop % $screenWidth]
		$pixels.Add($pixel)
		$totalLoop++

		if ($i -eq 1) {
			$spritePosition = $spritePosition.Replace("#", ".")
			$chars = $spritePosition.ToCharArray()

			$value += [int]$add
			for ($change = $value-1; $change -le $value+1; $change++) {
                if(($change -ge 0) -and ($change -le $chars.Length - 1)) {
                    $chars[$change] = '#'
                }
			}
			$spritePosition = -join $chars
		}
	}
}

$start = 0
$end = 39
$range = 40
1..6 | ForEach-Object {
	Write-Host $pixels[$start..$end]
	$start = $end + 1
	$end += $range
}