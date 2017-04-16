#Copyright (c) 2017 Nilay Parikh
#Modifications Copyright (c) 2017 Nilay Parikh
#B: https://blog.nilayparikh.com E: me@nilayparikh.com G: https://github.com/nilayparikh/
#This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

### Usage ###
#.\Add-OMSAgentVmssExtension.ps1 -ResourceGroupLocation "location" -ResourceGroupName "yourresourcegroup" -VMExtentionName "extensionname" -WorkspaceName "omsworkspacename" -VMScaleSetName "scalesetname" -AutoUpgradeMinorVersion

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)] [string] $ResourceGroupLocation,
    [Parameter(Mandatory=$true)] [string] $ResourceGroupName,
    [Parameter(Mandatory=$true)] [string] $WorkspaceName,
    [Parameter(Mandatory=$true)] [string] $VMScaleSetName,
	[string] $VMExtentionName = "OMSVmExt",
	[switch] $AutoUpgradeMinorVersion,
	[switch] $ValidateOnly
)

try
{
    Get-AzureRMContext
}
catch [System.Management.Automation.PSInvalidOperationException]
{
    Add-AzureRmAccount
}

try
{
	# Get OMS Workspace Id and Key
	$workspace = (Get-AzureRmOperationalInsightsWorkspace).Where({$_.Name -eq $WorkspaceName});
	$workspaceId = $workspace.CustomerId;
	$workspaceKey = (Get-AzureRmOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $workspace.ResourceGroupName -Name $workspace.Name).PrimarySharedKey;

	# Save access parameter to Setting and ProtectedSetting objects
	$setting = [Newtonsoft.Json.Linq.JObject]::Parse("{'workspaceId': '$workspaceId'}");
	$protectedSetting = [Newtonsoft.Json.Linq.JObject]::Parse("{'workspaceKey': '$workspaceKey'}");

	Write-Host "";
	Write-Host "OMS Workspace found.";
	Write-Host ""

	Write-Host "WorkspaceId           : " $workspaceId;
	Write-Host "WorkspaceKey          : " $workspaceKey.Substring(5,5)"...";

	# Get latest TypeHandlerVersion
	$allVersions= (Get-AzureRmVMExtensionImage -Location $ResourceGroupLocation -PublisherName "Microsoft.EnterpriseCloud.Monitoring" -Type "MicrosoftMonitoringAgent").Version
	$typeHandlerVer = $allVersions[($allVersions.count) - 1]
	$typeHandlerVerMjandMn = $typeHandlerVer.split(".")
	$typeHandlerVerMjandMn = $typeHandlerVerMjandMn[0] + "." + $typeHandlerVerMjandMn[1]

	Write-Host "";
	Write-Host "Retrieving current VM extension image version.";
	Write-Host ""

	Write-Host "TypeHandlerVersion    : " $typeHandlerVerMjandMn;

	# Get VM Scale Set instance
	$scaleSet = Get-AzureRmVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VMScaleSetName;

	Write-Host "";
	Write-Host "Successfully retrieved VM Scale Set.";
	Write-Host ""

	# Check if extension already exists in VMSS VM Profile 
	$existingExtension = $scaleSet.VirtualMachineProfile.ExtensionProfile.Extensions | Where-Object {$_.Type -eq "MicrosoftMonitoringAgent"};
	if ($existingExtension.Count -gt 0)
	{
		Write-Host "";
		Write-Host "MicrosoftMonitoringAgent already exists in Virtual Machine Profile." -ForegroundColor Cyan;
		$existingExtension[0];

		exit;
	}

	# Validation switch - exit if true
	if($ValidateOnly)
	{
		exit;
	}

	$autoUpgradeMV = $false;
	if($AutoUpgradeMinorVersion)
	{
		$autoUpgradeMV = $true;
	}

	# Run incremental provision
	$scaleSet = Add-AzureRmVmssExtension -VirtualMachineScaleSet $scaleSet -Name $VMExtentionName -Publisher "Microsoft.EnterpriseCloud.Monitoring" -Type "MicrosoftMonitoringAgent" -TypeHandlerVersion $typeHandlerVerMjandMn -AutoUpgradeMinorVersion $autoUpgradeMV -Setting $setting -ProtectedSetting $protectedSetting;
	Update-AzureRmVmss -ResourceGroupName $ResourceGroupName -Name $VMScaleSetName -VirtualMachineScaleSet $scaleSet

	Write-Host "MicrosoftMonitoringAgent successfully applied to VM Scale Set. ";
}
catch
{
	Write-Host "";
	Write-Host ""
	Write-Host $_.Exception.Message -ForegroundColor Red;
}