$day = 10

Set-Location $PSScriptRoot

$strNum = $day.ToString("D2")
$directoryPath = "./Day${strNum}"

New-Item $directoryPath -ItemType Directory

$content = 'Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$result = 0

$lines = Get-Content -Path "./$dataFile"
$lines | ForEach-Object {
	
}

Write-Host "Result: $result"'

$content | Out-File "$directoryPath/Day${strNum}_Part1.ps1"
$content | Out-File "$directoryPath/Day${strNum}_Part2.ps1"

New-Item "$directoryPath/Day${strNum}_Part1.input"
New-Item "$directoryPath/Day${strNum}_Part2.input"
