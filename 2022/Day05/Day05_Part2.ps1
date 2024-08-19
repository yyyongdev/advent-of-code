Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

$stacks = @{}
$tempStacks = @{}
foreach ($i in 1..9) {
	$stacks[$i] += New-Object System.Collections.Generic.Stack[System.String]
	$tempStacks[$i] += New-Object System.Collections.Generic.Stack[System.String]
}

$lines | ForEach-Object {
	if ($PSItem.StartsWith("move") -eq $false) {
		# 4칸씩 분할
		$splits = $PSItem -Split '(.{4})' | Where-Object { $_ }
		$len = $splits.Length

		# 쌓여있는 상자 찾기
		if ($len -gt 0) {
			foreach ($i in 0..($len-1)) {
				if ($splits[$i] -match "\[[A-Z]\]") {
					$alphabet = $splits[$i].Trim('[', ']', ' ')
					$stackIndex = $i + 1
					$tempStacks[$stackIndex].Push($alphabet)
				}
			}
		}
		# 상자를 요구사항과 같이 쌓아놓기
		else {
			for ($i = 1; $i -le $tempStacks.Count; $i++) {
				$tempStack = $tempStacks[$i]
				while ($tempStack.Count -gt 0) {
					$value = $tempStack.Pop()
					$stacks[$i].Push($value)
				}
			}
		}
	}
	else {
		$splits = $PSItem -Split '\s+'
		$moveCount = 0
		$from = 0
		$to = 0

		for ($i = 0; $i -lt $splits.Length; $i += 2) {
			$command = $splits[$i]
			if ($command -eq "move") { $moveCount = $splits[$i + 1] }
			elseif ($command -eq "from") { $from = $splits[$i + 1] }
			elseif ($command -eq "to") { $to = $splits[$i + 1] }
		}
		$tempStack = New-Object System.Collections.Generic.Stack[System.String]
		foreach ($i in 1..$moveCount) {
			$from = [int]$from
			$to = [int]$to
			$value = $stacks[$from].Pop()
			$tempStack.Push($value)
		}
		while($tempStack.Count -gt 0) {
			$value = $tempStack.Pop()
			$stacks[$to].Push($value)
		}
	}
}

$result = ""
for ($i = 1; $i -le $stacks.Count; $i++) {
	$result += $stacks[$i].Peek()
}

Write-Host "Result:" $result