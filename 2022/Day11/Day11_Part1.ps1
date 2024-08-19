Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

class Monkey {
	$items = @()
	[int]$operateCount = 0
	[string]$value
	[string]$operator
	[int]$divide
	[int]$throwTrue
	[int]$throwFalse
	[int64]execute([int64]$old) {
		[int64]$v = 0
		if ($this.value -eq "old") {
			$v = $old
		}
		else {
			$v = [int64]$this.value
		}
		$ret = switch ($this.operator) {
			"+" { $old + $v }
			"*" { $old * $v }
		}
		return $ret
	}
}

enum ParseLine {
	Monkey = 0
	Items = 1
	Operation = 2
	Test = 3
	IfTrue = 4
	IfFalse = 5
	Separate = 6
}

$monkeys = @()
$monkey = $null

for ($i = 0; $i -lt $lines.Length; $i++) {
	$line = $lines[$i]
	$parseIndex = $i % [ParseLine].GetEnumValues().Length
	switch ($parseIndex) {
		([int][ParseLine]::Monkey) {
			$monkey = [Monkey]::new()
			$monkeys += $monkey
		}
		([int][ParseLine]::Items) {
			$monkey.items = $line.subString(18) -split ','
		}
		([int][ParseLine]::Operation) {
			$opers = ($line -split " = ")[-1] -split ' '
			$monkey.operator = $opers[1]
			$monkey.value = $opers[2]
		}
		([int][ParseLine]::Test) {
			$monkey.divide = [int]($line.subString(21))
		}
		([int][ParseLine]::IfTrue) {
			$monkey.throwTrue = [int]($line.subString(29))
		}
		([int][ParseLine]::IfFalse) {
			$monkey.throwFalse = [int]($line.subString(30))
		}
		([int][ParseLine]::Separate) {
			$monkey = $null
		}
	}
}

1..20 | ForEach-Object {
	$monkeys | ForEach-Object {
		$monkey = $_
		$monkey.items | ForEach-Object {
			$monkey.operateCount++
			$result = $monkey.execute($_)
			$divided = [Math]::Floor($result / 3)
			if ($divided % $monkey.divide -eq 0) {
				$monkeys[$monkey.throwTrue].items += $divided 
			}
			else {
				$monkeys[$monkey.throwFalse].items += $divided 
			}
		}
		$monkey.items = @()
	}
}

$list = @()
$monkeys | ForEach-Object {
	$list += $_.operateCount
}

$result = 1
($list | Sort-Object | Select-Object -Last 2) | ForEach-Object {
	$result *= [int]($_)
}

Write-Host $result