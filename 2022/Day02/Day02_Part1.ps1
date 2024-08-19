Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

# Opponent : A, B, C (Rock, Paper, Scissors)
# Me       : X, Y, Z (Rock, Paper, Scissors)
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
	if($null -eq $battleResult[$PSItem]) {
		$opponent, $me = (-split $PSItem)
		Write-Host "Opponent:" $opponent "Me:" $me
		$score = 0

		if ($opponent -eq "A") {
			if ($me -eq "X") {
				$score += $rockScore + $drawScore
			}
			elseif ($me -eq "Y") {
				$score += $paperScore + $winScore
			}
			elseif ($me -eq "Z") {
				$score += $scissorsScore
			}
		}
		elseif ($opponent -eq "B") {
			if ($me -eq "X") {
				$score += $rockScore
			}
			elseif ($me -eq "Y") {
				$score += $paperScore + $drawScore
			}
			elseif ($me -eq "Z") {
				$score += $scissorsScore + $winScore
			}
		}
		elseif ($opponent -eq "C") {
			if ($me -eq "X") {
				$score += $rockScore + $winScore
			}
			elseif ($me -eq "Y") {
				$score += $paperScore
			}
			elseif ($me -eq "Z") {
				$score += $scissorsScore + $drawScore
			}
		}
		$battleResult[$PSItem] = $score
	}

	$total += $battleResult[$PSItem]
}
Write-Host "Result:" $total