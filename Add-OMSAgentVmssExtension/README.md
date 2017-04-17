# Add-OMSAgentVmssExtension.ps1

This script would install **Microsoft Monitoring Agent** on **Service Fabric Nodes** or **VM Scale Sets** in the cloud or the hybrid infrastructure to OMS Workspace. Microsoft Monitoring Agent (MMA) enables rich and real-time analytics for operational data (Logs, Performance, Alerts and Inventory) from a tenant.

Please refer, [Deploy Microsoft Monitoring Agent using Azure RM PowerShell (-AzureRmVmss*) for Service Fabric Cluster or VM Scale Sets](https://blog.nilayparikh.com/azure/service-management/guide-set-up-microsoft-monitoring-agent-on-service-fabric-and-vm-scale-sets-for-improved-operational-insight/#setup-microsoft-monitoring-agent-using-powershell) for more details.

The script simplifies the Microsoft Monitoring Agent deployment to Virtual Machine Scale Set and Service Fabric Cluster.

### Usage

``` powershell
.\Add-OMSAgentVmssExtension.ps1 -ResourceGroupLocation "location" -ResourceGroupName "yourresourcegroup" -VMExtentionName "extensionname" -WorkspaceName "omsworkspacename" -VMScaleSetName "scalesetname" -AutoUpgradeMinorVersion
```

Copyright (c) 2017 Nilay Parikh

Modifications Copyright (c) 2017 Nilay Parikh

B: https://blog.nilayparikh.com E: me@nilayparikh.com G: https://github.com/nilayparikh/

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
