Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

# Opponent : A, B, C (Rock, Paper, Scissors)
# Me       : X, Y, Z (Lose, Draw, Win)
# Score    : 1, 2, 3
# + Win    : 6
# + Draw   : 3
$battleResult = @{}
$rockScore = 1
$paperScore = 2
$scissorsScore = 3
$drawScore = 3
$winScore = 6

$total = 0
$lines | ForEach-Object {
	if ($null -eq $battleResult[$PSItem]) {
		$opponent, $expected = (-split $PSItem)
		Write-Host "Opponent:" $opponent "Expected:" $expected
		$score = 0

		if ($opponent -eq "A") {
			if ($expected -eq "X") {
				$score += $scissorsScore
			}
			elseif ($expected -eq "Y") {
				$score += $rockScore + $drawScore
			}
			elseif ($expected -eq "Z") {
				$score += $paperScore + $winScore
			}
		}
		elseif ($opponent -eq "B") {
			if ($expected -eq "X") {
				$score += $rockScore
			}
			elseif ($expected -eq "Y") {
				$score += $paperScore + $drawScore
			}
			elseif ($expected -eq "Z") {
				$score += $scissorsScore + $winScore
			}
		}
		elseif ($opponent -eq "C") {
			if ($expected -eq "X") {
				$score += $paperScore
			}
			elseif ($expected -eq "Y") {
				$score += $scissorsScore + $drawScore
			}
			elseif ($expected -eq "Z") {
				$score += $rockScore + $winScore
			}
		}
		$battleResult[$PSItem] = $score
	}
	$total += $battleResult[$PSItem]
}
Write-Host "Result:" $total