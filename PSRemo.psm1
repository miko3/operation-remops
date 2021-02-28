$script:FileName = "RmConfig.json"
$script:FilePath = "${PSScriptRoot}\${script:FileName}"
$script:Header = @{"X-Requested-With"="local";"Content-Type"="application/json"}

function NewBaseJson {
	param (
		[string]$FilePath
	)
	$json = @"
{
	"Common": {
		"Name": "",
		"IPAddress" : ""
	},
	"Data": []
}
"@
	$CommonObj = ConvertFrom-Json $json
	$CommonObj.Common.Name = "RC"
	ConvertTo-Json $CommonObj | Out-File $FilePath
}

if (-not(Test-Path $script:FilePath)) {
	NewBaseJson -FilePath $script:FilePath
}

$script:ConfigData = Get-Content -Path $script:FilePath | ConvertFrom-Json

$script:Uri = "http://$($script:ConfigData.Common.IPAddress)/messages"

function Add-RmOperation {
	if ($script:ConfigData.Common.IPAddress -eq "") {
		Write-Output "「Set-RmIPAddress」を実行し、RemoのIPアドレスを設定してください。"
		return 
	}
	
	try {
		$script:Result = Invoke-WebRequest -Uri $script:Uri -Method GET -Headers $script:Header  
	}
	catch {
		Write-Output "使用したいリモコンのボタンをRemoに向けて押し、Remoが青く光ったのを確認して再度実行してください。"
		return
	}

	if ($script:Result.StatusCode -ne 200) {
		Write-Output "使用したいリモコンのボタンをRemoに向けて押し、Remoが青く光ったのを確認して再度実行してください。"
		return
	}

	$script:Content = $script:Result.Content
	AddCommandData -Json $script:Content
}

function Remove-RmOperation {
	$script:Content = $script:Result.Content
	$script:InputName = Read-Host "削除する操作の名称を入力してください。"
	
	for ($idx = 0; $idx -lt $script:ConfigData.Data.Count; $idx++ ) {
		if ($script:ConfigData.Data[$idx].Command.Name -eq $script:InputName) {
			$script:ConfigData.Data[$idx] = $null
		}
	}

	$script:ConfigData.Data = $script:ConfigData.Data -ne $null

	SaveConfig
}

function Get-RmCommand {
	param (
		[string]$CommandName
	)

	if ($CommandName -ne "" ) { 
		$TargetCommang = $script:ConfigData.Data | Where-Object {$_.Command.Name -eq $CommandName}
	} else {
		$TargetCommang = $script:ConfigData.Data
	}
	$json = $TargetCommang.Command.Name
	Write-Output $json 
}

function Submit-RmCommand {
	param (
		[parameter(mandatory=$true)][string]$CommandName,
		[int32]$Count = 1
	)

	$TargetCommang = $script:ConfigData.Data | Where-Object {$_.Command.Name -eq $CommandName}
	$json = $TargetCommang.Command.Json
	for	($cnt = 0; $cnt -lt $Count; $cnt++){
		$script:Result = Invoke-WebRequest -Uri $script:Uri -Method POST -Headers $script:Header  -Body $json
	}
}

function Set-RmIPAddress {
	param (
		[parameter(mandatory=$true)][string]$IPAddress
	)

	$script:ConfigData.Common.IPAddress = $IPAddress
	SaveConfig
}

function GetRmData {
	param (
		[string]$ParameterName
	)
}

function AddCommandData {
	param (
		[string]$Json
	)

	$script:InputName = Read-Host "操作の名称を入力してください。"
	while (($script:ConfigData.Data | Where-Object {$_.Command.Name -eq $script:InputName} | Measure-Object).Count -ne 0) {
		$script:InputName = Read-Host "入力された名称は既に利用されています。別の名称を入力してください。"
	}

$AddData = @"
{
	"Command": {
		"Name": "",
		"Json" : ""
	}
}
"@
	$AddDataObj = ConvertFrom-Json $AddData

	try {
		$AddDataObj.Command.Name = $script:InputName
		$AddDataObj.Command.Json = $Json
	
		$script:ConfigData.Data += $AddDataObj
	
		SaveConfig
	}
	catch {
		$ErrorMessage = $_
		Write-Output $ErrorMessage
		Write-Output "登録に失敗しました。"
		return -1
	}

	Write-Output "登録が完了しました。"
}

function SaveConfig {
	ConvertTo-Json $script:ConfigData -Depth 4 -Compress | Out-File $script:FilePath
}

Export-ModuleMember -Function Add-*,Submit-*,Remove-*,Set-*,Get-*