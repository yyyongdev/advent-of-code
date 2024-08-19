Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

$orderTable = @{
	'A' = 0; 'K' = 1; 'Q' = 2; 'J' = 13; 'T' = 4
	'9' = 5; '8' = 6; '7' = 7; '6' = 8; '5' = 9; '4' = 10; '3' = 11; '2' = 12
}

$hands = @()
$lines = Get-Content -Path "./$dataFile"
$lines | ForEach-Object {
	if ([string]::IsNullOrEmpty($_)) {
		return
	}
	$card, $money = $_.Split()
    $originCard = $card

    if ($card.Contains('J')) {
		$chars = $card.ToCharArray() | Where-Object {$_ -ne 'J' }
		$duplicateCard = $chars | Group-Object | Sort-Object Count -Descending | Select-Object -First 1
		
		if ($chars.Length -eq 0) {
			$card = 'A' * 5
		}
		elseif ($duplicateCard.Count -eq 4) {
			$label = $chars | Select-Object -First 1
			$card = $label.ToString() * 5
		}
		elseif ($duplicateCard.Count -eq 3 -or $duplicateCard.Count -eq 2) {
			$label = ($chars | Group-Object | Sort-Object -Descending -Property Count, @{ Expression = { $orderTable[$_.Name.ToString()]}; Descending = $false } | Select-Object -First 1).Name
			$card = $originCard -replace 'J', $label
		}
		else {
			$label = $chars | Sort-Object -Property @{ Expression = { $orderTable[$_.ToString()] }; Descending = $false } | Select-Object -First 1
			$card = $originCard -replace 'J', $label
		}
	}
	
	$duplicateCard = $card.ToCharArray() | Group-Object | Sort-Object Count -Descending | Select-Object -First 1
	$distinctCard = $card.ToCharArray() | Sort-Object -Unique
	
	$hands += @{
        'OriginCard'     = $originCard
		'Card'           = $card
		'Money'          = $money
		'DuplicateCount' = $duplicateCard.Count
		'DistinctCount'  = $distinctCard.Count
	}
}



$orderedHands = $hands | Sort-Object -Property  { $_.DuplicateCount },
												{ -($_.DistinctCount) },
												{ -($orderTable[$_.OriginCard[0].ToString()]) },
												{ -($orderTable[$_.OriginCard[1].ToString()]) },
												{ -($orderTable[$_.OriginCard[2].ToString()]) },
												{ -($orderTable[$_.OriginCard[3].ToString()]) },
												{ -($orderTable[$_.OriginCard[4].ToString()]) }

$orderedHands | ForEach-Object -Begin { $index = 1 } -Process { 
	$result += $index * $_.Money
	$index++
}
Write-Host "Result: $result"