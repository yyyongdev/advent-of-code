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

Function TotalSize($root) {
	$size = 0
	$root.Keys | Where-Object { $PSItem -ne ".." -and $PSItem -ne "name" } | ForEach-Object {
		$child = $root[$PSItem]
		if ($null -eq $child.size) {
			$dirSize = TotalSize $child
			$size += $dirSize
		}
		else {
			$size += $child.size
		}
	}
	return $size
}

$diskSpace = 70000000
$needSpace = 30000000

$usedSpace = TotalSize $fileTree
$unusedSpace = $diskSpace - $usedSpace
$needMoreSpace = $needSpace - $unusedSpace
Write-Host "need more :" $needMoreSpace


Function GetDirSizeList($root, [ref]$list) {
	$size = 0
	$root.Keys | Where-Object { $PSItem -ne ".." -and $PSItem -ne "name" } | ForEach-Object {
		$child = $root[$PSItem]
		if ($null -eq $child.size) {
			$dirSize = GetDirSizeList $child $list
			$size += $dirSize
			$list.Value += $dirSize
		}
		else {
			$size += $child.size
		}
	}
	return $size
}

$list = @()
$null = GetDirSizeList $fileTree ([ref]$list)

$condidate = $diskSpace
$list | Where-Object { $PSItem -ge $needMoreSpace} | ForEach-Object {
	$condidate = ($condidate, $PSItem | Measure-Object -Minimum).Minimum
}

Write-Host "Result:" $condidate