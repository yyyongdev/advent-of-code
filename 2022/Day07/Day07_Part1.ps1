Set-Location $PSScriptRoot
$dataFile = $MyInvocation.MyCommand -replace ".ps1", ".input"
$lines = Get-Content -Path "./$dataFile"

$fileTree = @{
	"name" = "root"
	"/"    = @{}
}
$current = $fileTree
$Global:result = 0

$lines | ForEach-Object {
	$splits = (-Split $PSItem)
	if ($splits[0].StartsWith("$")) {
		if ($splits[1] -eq "cd") {
			if ($splits[2] -eq "..") {
				$current = $current[".."]
			}
			else {
				$temp = $current
				$current = $current[$splits[2]]
				if ($temp.name -ne "root") {
					$current[".."] = $temp
				}
			}
		}
	}
	elseif ($splits[0] -eq "dir") {
		$current[$splits[1]] = @{ name = $splits[1] }
	}
	else {
		$current[$splits[1]] = @{ name = $splits[1]; size = $splits[0] }
	}
}

Function CalcSize($root, $predicate, [ref]$sum) {
	$size = 0
	$root.Keys | Where-Object { $PSItem -ne ".." -and $PSItem -ne "name" } | ForEach-Object {
		$child = $root[$PSItem]
		if ($null -eq $child.size) {
			$dirSize = CalcSize $child $predicate $sum
			$size += $dirSize
			$result = Invoke-Command -ScriptBlock $predicate -ArgumentList $dirSize
			if ($result -eq $true) {
				$sum.Value += $dirSize
			}
		}
		else {
			$size += $child.size
		}
	}
	return $size
}

$sum = 0
$func = {
	param($value)
	return ($value -le 100000)
}
CalcSize $fileTree $func ([ref]$sum)

Write-Host "Result:" $sum