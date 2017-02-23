#######################################################################################################
#                                                                                                     #
# NAME:     check_cluster_hyperv.ps1                                                                  #
#                                                                                                     #
# AUTHOR:   Jose Manuel Murillo Martinez                                                              #
# COMPANY:  TCP Sistemas e Ingenieria, S.L.                                                           #
# EMAIL:    jmmurillo@tcpsi.es                                                                        #
#                                                                                                     #
# DESCRIPTION:  Script to monitor Microsoft Cluster Hyper-V with Zabbix Agent.                        #
#               List cluster nodes, csv and cluster resources                                         #
#           @Param:                                                                                   #
#               -discovery: indicates the object you want to discover to list (node or resources)     #
#               -check:     indicates the object you want check you can choose among                  #
#                           (state_node,state_resource,ownernode_resource,resourceType_resource,      #
#                            ownergroup_resource )                                                    #
#               - name:     indicate the name of the resource o node to check                         #
#                                                                                                     #
#           @Return:                                                                                  #
#               result: Contains the array json for discovery or simple value                         #
#                                of check MS Cluster                                                  #
#                                                                                                     #
#  EXAMPLES:     check_cluster_hyperv.ps1 -d csv                                                      #
#                check_cluster_hyperv.ps1 -d node                                                     #
#                check_cluster_hyperv.ps1 -discovery resource                                         #
#                check_cluster_hyperv.ps1 -check state_resource -name "cluster disk 2"                #
#######################################################################################################



param(
	[alias("c","check")][string]$checkitem=$null,
	[alias("d","discovery")][string]$objdiscovery=$null,
	[alias("n","name")][string]$nameitem=$null,
	[alias("g","clustergroup")][string]$clusterservice=$null
	)



#DISCOVERY
if(![string]::IsNullOrEmpty($objdiscovery) -and [string]::IsNullOrEmpty($checkitem)) {
	switch($objdiscovery) {
		"node" {
			# Recogemos el estado de los nodos
			$node = gwmi -class MSCluster_Node -namespace "root\mscluster"|Select -ExpandProperty Name

			write-host "{"
			write-host " `"data`":[`n"

			#temp variable
			$temp = 1

			foreach ($name_node in $node) {
				if ($temp -eq 0) {
					write-host ",";
				} else {
					$temp = 0;
				}
				$line= "{ `"{#NODE}`" : `"" + $name_node + "`" }"
				write-host -NoNewline $line
			}
			write-host
			write-host " ]"
			write-host "}"
		}

		"resource" {
			# Obtenemos el nombre del ClusterGroup
			$clusterGroup = gwmi -class MSCluster_ResourceGroup -namespace "root\mscluster" |Select-object Name|Where-Object {$_.Name -like "*$clusterservice*"}
			
			# Recogemos la lista de recursos de cluster
			$resource = gwmi -class MSCluster_ResourceGroupToResource -namespace "root\mscluster" |Select-Object * -ExcludeProperty PSComputerName, Scope, Path, Options, ClassPath, Properties,SystemProperties, Qualifiers, Site,Container|where-object {$_.GroupComponent -like "*$clusterservice*"}|Select -ExpandProperty PartComponent|out-string
			$resour= $resource.replace('MSCluster_Resource.Name="',"")
			$resource=$resour.split('"')
                        

                        
			write-host "{"
			write-host " `"data`":[`n"

			#temp variable
			$temp = 1

			for ($i = 0; $i -lt $resource.length-1; $i++)  {
                                $resour=$resource[$i].split("",[StringSplitOptions]::RemoveEmptyEntries)
                                $restype=gwmi -class MSCluster_ResourceTypeToResource -namespace "root\mscluster"|select-object GroupComponent,PartComponent|where-object { $_.PartComponent -like "MSCluster_Resource.Name=?$resour*"} 
                                
				$resourcetype=$restype.GroupComponent.replace("MSCluster_ResourceType.Name=","")
                                $restype=$resourcetype.replace('"','')
                                
				if ($temp -eq 0) {
					write-host ",";
				} else {
					$temp = 0;
				}
				
                                
                                #$line = "{ `"{#RESOURCE}`":`"" + $resource.Name + "`" }"
				$line = "{ `"{#RESOURCE}`":`"" + $resour + "`", `"{#RESOURCETYPE}`":`"" + $restype + "`" }"
				write-host -NoNewline $line
			}
			write-host
			write-host " ]"
			write-host "}"
                  
		}
        
        "csv" {
			# Obtenemos el nombre del ClusterGroup
			$csvdisk = Get-WmiObject -Class MSCluster_DiskPartition -Namespace "ROOT\MSCluster" | select-object FreeSpace,VolumeLabel
			
			
                        
			write-host "{"
			write-host " `"data`":[`n"

			#temp variable
			$temp = 1

			for ($i = 0; $i -lt $csvdisk.length; $i++)  {
				
				
							
				if ($temp -eq 0) {
					write-host ",";
				} else {
					$temp = 0;
				}
				$line = "{ `"{#CSVDISK}`":`"" + $csvdisk[$i].VolumeLabel + "`"}"
				write-host -NoNewline $line
			}
			write-host
			write-host " ]"
			write-host "}"
		}
	
    
		
		"disk" {
			# Obtenemos el nombre del ClusterGroup
			$DiskClusterGroup = gwmi -class MSCluster_ResourceGroup -namespace "root\mscluster" |Select-object Name|Where-Object {$_.Name -like "*$clusterservice*"}
			
			# Recogemos la lista de recursos de cluster of type Physical Disk
			$DiskResources = gwmi -class MSCluster_ResourceTypeToResource -namespace "root\mscluster"|select-object GroupComponent,PartComponent|where-object { $_.GroupComponent -match "Physical Disk"}|Select -ExpandProperty PartComponent|out-string
                        $DiskResource=$DiskResources.replace('MSCluster_Resource.Name="','')
                        $DiskResources=$DiskResource.split('"')
                        
			write-host "{"
			write-host " `"data`":[`n"

			#temp variable
			$temp = 1

			for ($i = 0; $i -lt $DiskResources.length-1; $i++)  {
				$diskname = $DiskResources[$i].split("",[StringSplitOptions]::RemoveEmptyEntries)
				# Get MSCluster Disk ID
				$ResourceToDisk = (Get-WmiObject -Class MSCluster_ResourceToDisk -Namespace ROOT\MSCluster) | Where-Object {$_.GroupComponent -match "$diskname"} | Select-Object PartComponent
				
				
				$ID = $ResourceToDisk.PartComponent.split("=")[1] -replace '"',""
				#write-host $ID
				# Get Index disk
				#$ClusterDisk = (Get-WmiObject -Class MSCluster_Disk -Namespace ROOT\MSCluster) | Where-Object {$_.ID -eq $ID} | Select-Object Name
				#$Index = $ClusterDisk.Name
				
				# Get Path of MSCluster disk to disk partition
				$MSCluster_DiskToDiskPartition = (Get-WmiObject -Class MSCluster_DiskToDiskPartition -Namespace ROOT\MSCluster) | Where-Object {$_.GroupComponent -like "*$ID*"} | Select-Object PartComponent
				$Path = $MSCluster_DiskToDiskPartition.PartComponent.split("=")[1] -replace '"',""
				
				if ($temp -eq 0) {
					write-host ",";
				} else {
					$temp = 0;
				}
				$line = "{ `"{#DISKRESOURCE}`":`"" + $diskname + "`", `"{#DISKID}`":`"" + $ID + "`", `"{#DISKPATH}`":`"" + $Path + "`" }"
				write-host -NoNewline $line
			}
			write-host
			write-host " ]"
			write-host "}"
		}
	}
}

#CHECK
if(![string]::IsNullOrEmpty($checkitem) -and [string]::IsNullOrEmpty($objdiscovery)) {
	switch($checkitem) {
		"state_node"  {
			$node_state = gwmi -class MSCluster_Node -namespace "root\mscluster"|select-object name,state|where-object {$_.name -like "*$nameitem*"}
			switch($node_state.state) {
				Up      { write-host 0 }
				Down    { write-host 1 }
				Paused  { write-host 2 }
				Joining { write-host 3 }
				Unknown { write-host 4 }
			}
			write-host $node_state.state
		}

		"state_resource" {
			$resource_state = gwmi -class MSCluster_Resource -namespace "root\mscluster"|select-object name,state|where-object {$_.name -like "$nameitem"}
			switch($resource_state.state) {
				Inherited      { write-host 0 }
				Initializing   { write-host 1 }
				Online         { write-host 2 }
				Offline        { write-host 3 }
				Failed         { write-host 4 }
				Pending        { write-host 5 }
				OnlinePending  { write-host 6 }
				OfflinePending { write-host 7 }
				Unknown        { write-host 8 }
			}
			write-host $resource_state.state
		}

		"ownernode_resource" {
			$resource_OwnerNode = gwmi -class MSCluster_NodeToActiveResource -namespace "root\mscluster"|select-object PartComponent,GroupComponent|where-object {$_.PartComponent -like "MSCluster_Resource.Name=?$nameitem*"}
			write-host $resource_OwnerNode.GroupComponent.split('"')[1]
		}

		"resourceType_resource" {
			$resource_resourceType = gwmi -class MSCluster_Resource -namespace "root\mscluster"|select-object name,type|where-object {$_.name -like "$nameitem"}
			write-host $resource_resourceType.type
		}

		"ownergroup_resource" {
			$resource_OwnerGroup = gwmi -class MSCluster_ResourceGroupToResource -namespace "root\mscluster"|select-object GroupComponent,PartComponent|where-object {$_.Partcomponent -like "MSCluster_Resource.Name=?$nameitem*"}
			write-host $resource_OwnerGroup.GroupComponent.split('"')[1]
		}
		"ownergroup" {
			$OwnerGroup = gwmi -class MSCluster_ClusterToResourceGroup -namespace "root\mscluster"|select-object GroupComponent,PartComponent|where-object {$_.Partcomponent -like "*$nameitem*"}
			write-host $OwnerGroup.GroupComponent.split('"')[1]
		}
        "free_size_disk" {
            $FreeSizeDisk = Get-WmiObject -Class MSCluster_DiskPartition -Namespace "ROOT\MSCluster" | select-object FreeSpace,VolumeLabel | where-object  { $_.VolumeLabel  -like "$nameitem"}
            write-host $FreeSizeDisk.FreeSpace
        } 
        "free_size_disk_percent"{
              $FreeSizeDiskPercent = Get-WmiObject -Class MSCluster_DiskPartition -Namespace "ROOT\MSCluster" | select-object FreeSpace,TotalSize,VolumeLabel | where-object  { $_.VolumeLabel  -like "$nameitem"}
              $percentag = $FreeSizeDiskPercent.FreeSpace*100 / $FreeSizeDiskPercent.TotalSize
              write-host $( '{0:N2}' -f $percentag)
        }
	}
}
