Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0
$mapData = @{}

Function ConvertMappingRange($ConvertInfo, $Ranges) {
	$retArray = @()
	for ($i = 0; $i -lt $Ranges.Length; $i++) {
		$tempArray = @()
		$range = $Ranges[$i]
		if ($range.Done) {
			continue
		}
		foreach ($info in $ConvertInfo.Ranges) {
			# [     Info     ]
			#     [ Range ]
			if ($info.Start -le $range.Start -and $info.End -ge $range.End) {
				$tempArray += @{ 'Start' = $range.Start + $info.Gap; 'End' = $range.End + $info.Gap; 'Done' = $false }
				$range.Done = $true
			}
			# [  Info  ]     
			#       [ Range ]
			elseif ($info.End -ge $range.Start -and $info.End -le $range.End) {
				$tempArray += @{ 'Start' = $range.Start + $info.Gap; 'End' = $info.End + $info.Gap; 'Done' = $false }
				$range.Start = $info.End + 1
			}
			#      [  Info  ] 
			# [ Range ]
			elseif ($info.Start -le $range.End -and $info.Start -ge $range.Start) {
				$tempArray += @{ 'Start' = $info.Start + $info.Gap; 'End' = $range.End + $info.Gap; 'Done' = $false }
				$range.End = $info.Start - 1
			}
			#     [ Info ]
			# [    Range    ]
			elseif ($info.Start -ge $range.Start -and $info.End -le $range.End) {
				$tempArray += @{ 'Start' = $info.Start + $info.Gap; 'End' = $info.End + $info.Gap; 'Done' = $false }
				$Ranges += @{ 'Start' = $range.Start; 'End' = $info.Start - 1; 'Done' = $false }
				$Ranges += @{ 'Start' = $info.End + 1; 'End' = $range.End; 'Done' = $false }
				$range.Done = $true
			}
		}
		$retArray += $tempArray
	}
	foreach ($range in $Ranges) {
		if ($range.Done -eq $false) {
			$retArray += $range
		}
	}
	return $retArray
}

$lines = Get-Content -Path "./$dataFile"
$seedLine, $lines = $lines

$lines | ForEach-Object {
	if ($_ -eq "") {
		return
	}
	if ($_ -match '(.*)-(.*)-(.*) map:') {
		$from = $matches[1]
		$to = $matches[3]
		$mapData[$from] = @{
			'To'         = $to
			'TotalStart' = [long]::MaxValue
			'TotalEnd'   = [long]0
			'Ranges'     = @()
		}
	}
	else {
		$numbers = $_.Split()
		$start = [long]$numbers[1]
		$len = [long]$numbers[2]
		$end = $start + $len - 1
		$newStart = [long]$numbers[0]
		$gap = $newStart - $start

		$mapData[$from].TotalStart = [Math]::Min($mapData[$from].TotalStart, $start)
		$mapData[$from].TotalEnd = [Math]::Max($mapData[$from].Totalend, $end)
		$mapData[$from].Ranges += @{
			'Start' = $start
			'End'   = $end
			'Gap'   = $gap
		}
	}
}

if ($seedLine -match 'seeds: (.*)') {
	$seeds = @()
	$seedInfo = $matches[1].Split();
	for ($i = 0; $i -lt $seedInfo.Length; $i += 2) {
		$seeds += @{
			'Start' = [long]$seedInfo[$i]
			'End'   = [long]$seedInfo[$i] + [long]$seedInfo[$i + 1] - 1
			'Done'  = $false
		}
	}
	$soils = ConvertMappingRange -ConvertInfo $mapData['seed'] -Range $seeds
	$fertilizers = ConvertMappingRange -ConvertInfo $mapData['soil'] -Range $soils
	$waters = ConvertMappingRange -ConvertInfo $mapData['fertilizer'] -Range $fertilizers
	$lights = ConvertMappingRange -ConvertInfo $mapData['water'] -Range $waters
	$temperatures = ConvertMappingRange -ConvertInfo $mapData['light'] -Range $lights
	$humidities = ConvertMappingRange -ConvertInfo $mapData['temperature'] -Range $temperatures
	$locations = ConvertMappingRange -ConvertInfo $mapData['humidity'] -Range $humidities
    
	$lowest = [long]::MaxValue
	$locations | ForEach-Object {
		$lowest = [Math]::Min($lowest, $_.Start)
	}
	$result = $lowest
}

Write-Host "Result: $result"