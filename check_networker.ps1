#######################################################################################################
#                                                                                                     #
# NAME:     check_networker.ps1                                                                       #
#                                                                                                     #
# AUTHOR:   David Alonso Guisado                                                                      #
# COMPANY:  TCP Sistemas e Ingenieria, S.L.                                                           #
# EMAIL:    dalonso@tcpsi.es                                                                          #
#                                                                                                     #
# DESCRIPTION:  Script to monitor EMC Networker  with Zabbix Agent.                                   #
#               List volumes, and pools                                                               #
#           @Param:                                                                                   #
#               -discovery: indicates the object you want to discover to list (volumr or pools)       #
#               -check:     indicates the object you want check you can choose among                  #
#                           (state_volume,state_pool,state_group)                                                 #
#                                                                                                     #
#               - name:     indicate the name of the volume or pool or group to check                           #
#               																                      #
#                                                                                                     #
#           @Return:                                                                                  #
#               result: Contains the array json for discovery or simple value                         #
#                                					                                                  #
#                                                                                                     #
#  EXAMPLES:     check_networker.ps1 -discovery volume                                                #
#                check_networker.ps1 -check state_volume -name "name_volume"                          #
#                check_networker.ps1 -discovery pool                                                  #
#                check_networker.ps1 -check state_pool -name "name_pool"                              #
#                check_networker.ps1 -discovery group                                                 #  
#                check_networker.ps1 -check state_group -name "name_group"                            #
#######################################################################################################





param(
	[alias("c","check")][string]$checkitem=$null,
	[alias("d","discovery")][string]$objdiscovery=$null,
	[alias("n","name")][string]$nameitem=$null
	
	)
	
#DISCOVERY
if(![string]::IsNullOrEmpty($objdiscovery) -and [string]::IsNullOrEmpty($checkitem)) {
	switch($objdiscovery) {
		"volume" {
			# Recogemos los volumenes
			$volume = @(& mminfo -a -r "volume")
			
			
			write-host "{"
			write-host " `"data`":[`n"
			
			#temp variable
			$temp = 1
			
			for ($i = 0; $i -lt $volume.length; $i++) {
			  if ($volume[$i] -ne $volume[$i+1]) {
				if ($temp -eq 0) {
					write-host ",";
				} else {
					$temp = 0;
				}
				$line= "{ `"{#VOLUME}`" : `"" + $volume[$i] + "`" }"
				write-host -NoNewline $line
			  }
			}
			write-host
			write-host " ]"
			write-host "}"
		}
		
		
		"pool" {
		   # Recogemos los pools
		   $pool = @(& mminfo -a -r "pool"|sort)
		   

			write-host "{"
			write-host " `"data`":[`n"
			
			#temp variable
			$temp = 1
			
			for ($i = 0; $i -lt $pool.length; $i++) {
			  	if ($pool[$i] -ne $pool[$i+1]) {	  
			  			  
				if ($temp -eq 0) {
					write-host ",";
				} else {
					$temp = 0;
				}
				$line= "{ `"{#POOL}`" : `"" + $pool[$i] + "`" }"
				write-host -NoNewline $line
			  }
			}
			write-host
			write-host " ]"
			write-host "}"
		}
	
		"group" {
			# Recogemos los volumenes
			$group = @(& mminfo -o t -r "group"|sort)
			
			
			write-host "{"
			write-host " `"data`":[`n"
			
			#temp variable
			$temp = 1
			
			for ($i = 0; $i -lt $group.length; $i++) {
			  if ($group[$i] -ne $group[$i+1]  -and $group[$i] -ne "") {
				if ($temp -eq 0) {
					write-host ",";
				} else {
					$temp = 0;
				}
				$line= "{ `"{#GROUP}`" : `"" + $group[$i] + "`" }"
				write-host -NoNewline $line
			  }
			}
			write-host
			write-host " ]"
			write-host "}"
		}
		
		
}		


}

# CHECK
	
	if(![string]::IsNullOrEmpty($checkitem) -and [string]::IsNullOrEmpty($objdiscovery)) {
	  switch($checkitem) {
		"state_pool"  {
			$pool_state = @( & mminfo -a -r "volume,%used,pool" -q !full 2>$null |select-string -Pattern $nameitem)

			if ($pool_state.length -gt 0) {
			write-host "0"} else {
			write-host "1"}
			
		}
		"state_volume" {
			$volume_state = @( & mminfo -a -r "%used,volume" | select-string -Pattern $nameitem)

			$volume_state = $volume_state -replace (" ","")
			$volume_state = $volume_state -split ($nameitem)
			write-host $volume_state
		}
	  

		 "state_group" {
                        
			$group_state = @( & nsrsgrpcomp -H $nameitem 2>&1)
			$aux = $group_state
			[regex]$filter = '[a-z]"'
			$group_state = $filter.split($aux)
			$number = 0
                                                                   			  
			  for ($i = 0; $i -lt $group_state.length; $i++) {
                            if ($group_state[$i] -match "failed") {  
				write-host $group_state[$i]  
				$number++
				}
                            
                          }
                          if ($number -eq 0) {
                            write-host "ok"
                          }
                }
	}
}
       