########################################################################################
#                                                                                      #
# NAME:     check_iis.ps1                                                              #
#                                                                                      #
# AUTHOR:   Jose Manuel Murillo Martinez                                               #
# COMPANY:  TCP Sistemas e Ingenieria, S.L.                                            #
# EMAIL:    jmmurillo@tcpsi.es                                                         #
#                                                                                      #
# DESCRIPTION:  Script to monitor Microsoft IIS with Zabbix Agent.                     #
#               List sites, application and application pools containing the IIS       #
#           @Param:                                                                    #
#               -discovery:  IIS indicates the object you want to discover to list     #
#               -check:  IIS indicates the object you want check                       #
#                                                                                      #
#           @Return:                                                                   #
#               result: Contains the array json for discovery or simple value          #
#                                of check IIS                                          #
#                                                                                      #
# CHANGELOG:                                                                           #
# 1.0 2014-12-09 - Initial version                                                     #
# 1.1 2015-04-27 - ApplicationPools discovery is added and modified discovery          #
#                  of WorkerProcess. WMI simple checks are removed and made directly   #
#                  from Template zabbix                                                #
#                                                                                      #
########################################################################################

param(
	[alias("c","check")][string]$checkitem=$null,
	[alias("o","object")][string]$objectcheck=$null,
	[alias("p","pid")][int]$processID=$null,
	[alias("d","discovery")][string]$objdiscovery=$null,
	[alias("v","debug")][switch]$debugmode=$false
	)

$ErrorActionPreference = "silentlycontinue"
	
# For default the status is 0
$returnState = 0

write-debug $PSVersionTable

# The Web Server Administration module (WebAdministration) for Windows PowerShell includes the Internet Information Services (IIS)
# cmdlets that let you manage the configuration and run-time data of IIS.
#It implements a namespace hierarchy containing Application Pools, Web sites, Web applications and virtual directories.
import-module 'webAdministration'

# Supported object types:
# SITE      Administration of virtual sites
# APP       Administration of applications
# VDIR      Administration of virtual directories
# APPPOOL   Administration of application pools
# CONFIG    Administration of general configuration sections
# WP        Administration of worker processes
# REQUEST   Administration of HTTP requests
# MODULE    Administration of server modules
# BACKUP    Administration of server configuration backups
# TRACE     Working with failed request trace logs
$objecttypes = 'SITE','APP','APPPOOL','WP'

if($debugmode) {
	$DebugPreference = "Continue"
} else {
	$DebugPreference = "SilentlyContinue"
}

# DISCOVERY
if(![string]::IsNullOrEmpty($objdiscovery) -and [string]::IsNullOrEmpty($checkitem)) {
	write-debug "discovery mode"
	write-debug "objdiscovery: $objdiscovery"
	#$appCmd = "$env:WINDIR\system32\inetsrv\appcmd.exe"
	#$OutAppCmd = & $appCmd list $objdiscovery
	#$regexStr = 'SITE "([\w\s._]+)" \(id:\d,([\w])+:([\w]+)\/\*:[\d]+:([\w]*,state:([\w]+)\))'
	# $_ -match "/*/*\s*(?<AlertType>[\w ]+?):\s*(?<MachineName>[^\/]+)\/(?<AlertName>.*?)\s\w+\s(?<Status>\w+)\s\*\*"  | Out-Null
	# write-debug "OutAppCmd: $OutAppCmd"
	# write-debug "regexStr: $regexStr"
	# $OutAppCmd -match $regexStr
	
	if(!($objecttypes -contains $objdiscovery)) {
		write-host "No valid object"
		$returnState  = -2
	} else {
		write-debug "objecttypes: $objecttypes"
		switch($objdiscovery) {
			SITE {
				write-debug "SITE"
				$sitesObj = Get-WmiObject Site -Namespace root\WebAdministration | Select-Object Name, Id, ServerAutoStart
				
				# Output the JSON header
				write-host "{";
				write-host "`t ""data"":[";
				
				#temp variable
				$temp = 1
				
				foreach($site in $sitesObj) {
					$siteName    = $site.Name
					$siteId      = $site.Id
					$siteStatus  = $site.ServerAutoStart
					$siteServer  = $site.__SERVER
					
					if ($siteStatus -eq $True) {
						write-debug "siteId: $siteId siteName: $siteName on $siteServer"
						if ($temp -eq 0) {
							write-host ",";
						} else {
							$temp = 0;
						}
						$line = " { `"{#SITEID}`":`"" + $siteId + "`", `"{#SITENAME}`":`"" + $siteName + "`" }"
						write-host -NoNewline $line
					}
				}
				# Close the JSON message
				write-host "`t ]";
				write-host "}"
			}
			
			APP {
				write-debug "APP"
				$appsObj = Get-WmiObject Application -Namespace root\WebAdministration
				
				# Output the JSON header
				write-host "{";
				write-host "`t ""data"":[";
				
				#temp variable
				$temp = 1
				
				foreach($app in $appsObj) {
					$appPath    = $app.Path
					$appSite    = $app.SiteName
					$appPool    = $app.ApplicationPool
					$siteServer = $app.__SERVER
					write-debug "`nappPath: $appPath `nappSite: $appSite `nappPool: appPool `n"
					
					if ($appPath -eq "/") {
						$appName = "Root Application"
					} else {
						$appName    = $appPath.Substring(1)
					}
					
					if (![string]::IsNullOrEmpty($appName)) {
						write-debug "appName: $appName appSite: $appSite on $siteServer"
						if ($temp -eq 0) {
							Write-Host ",";
						} else {
							$temp = 0;
						}
						$line = " { `"{#APPNAME}`":`"" + $appName + "`", `"{#APPSITE}`":`"" + $appSite + "`", `"{#APPPATH}`":`"" + $appPath + "`" }"
						Write-Host -NoNewline $line
					}
				}
				# Close the JSON message
				write-host "`t ]";
				write-host "}"
			}
			
			APPPOOL {
				write-debug "APPPOOL"
				$appPoolsObj = Get-WmiObject ApplicationPool -Namespace root\WebAdministration
				
				# Output the JSON header
				write-host "{";
				write-host "`t ""data"":[";
				
				#temp variable
				$temp = 1
				
				foreach($appPool in $appPoolsObj) {
					$appPoolName = $appPool.Name
					$siteServer  = $appPool.__SERVER
					
					if (![string]::IsNullOrEmpty($appPoolName)) {
						write-debug "appPoolName: $appPool.Name on $siteServer"
						if ($temp -eq 0) {
							Write-Host ",";
						} else {
							$temp = 0;
						}
						$line = " { `"{#APPPOOL}`":`"" + $appPoolName + "`" }"
						Write-Host -NoNewline $line
					}
				}
				# Close the JSON message
				write-host "`t ]";
				write-host "}"
			}
			
			WP {
				write-debug "WP"
				$wpsObj = Get-WmiObject WorkerProcess -Namespace root\WebAdministration
				
				# Output the JSON header
				write-host "{";
				write-host "`t ""data"":[";
				
				#temp variable
				$temp = 1
				
				foreach($wp in $wpsObj) {
					$wpPID      = $wp.ProcessID
					$wpGUID     = $wp.Guid
					$wpAppPool  = $wp.AppPoolName
					$siteServer = $wp.__SERVER
					
					if (![string]::IsNullOrEmpty($wpPID)) {
						write-debug "ProcessID: $wpPID Guid: $wpGUID of AppPoolName: $wpAppPool on $siteServer"
						if ($temp -eq 0) {
							Write-Host ",";
						} else {
							$temp = 0;
						}
						$line = " { `"{#WPAPPPOOLNAME}`":`"" + $wpAppPool + "`", `"{#WPPID}`":`"" + $wpPID + "`", `"{#WPGUID}`":`"" + $wpGUID + "`" }"
						Write-Host -NoNewline $line
					}
				}
				# Close the JSON message
				write-host "`t ]";
				write-host "}"
			}
			
			default {
				write-debug "DEFAULT"
			}
		}
	}
}

# CHECK
if(![string]::IsNullOrEmpty($checkitem) -and [string]::IsNullOrEmpty($objdiscovery)) {
	write-debug "Check mode: $checkitem"
	
	switch($checkitem) {
		numSites {
			$sitesObj = Get-WmiObject -Class Site -Namespace root\WebAdministration
			write-host $sitesObj.count
		}
		
		numApps {
			$appsObj = Get-WmiObject -Class Application -Namespace root\WebAdministration
			write-host $appsObj.count
		}
		
		numAppPools {
			$appPoolsObj = Get-WmiObject -Class ApplicationPool -Namespace root\WebAdministration
			write-host $appPoolsObj.count
		}
		
		numAppIntoPool {
			$appIntoPoolsObj = Get-WmiObject -Class Application -Namespace root\WebAdministration | Where-Object {$_.ApplicationPool -eq $objectcheck}
			# Si no devuelve objeto, no tiene aplicaciones.
			# Si devuelve solo un resultado, se devuelve como objeto
			# Si devuelve mas de un  resultado, es un array
			if ($appIntoPoolsObj) {
				if($appIntoPoolsObj.count) {
					write-host $appIntoPoolsObj.count
				} else {
					write-host 1
				}
			} else {
				write-host 0
			}
		}
		
		appSite {
			$appsSiteNameObj = Get-WmiObject -Class Application -Namespace root\WebAdministration | Where-Object {$_.Path -eq $objectcheck}
			write-host $appsSiteNameObj.SiteName
		}
		
		appPoolRuntimeVersion {
			$AppPoolObj = Get-WmiObject -Class ApplicationPool -Namespace root\WebAdministration | Where-Object {$_.Name -eq $objectcheck}
			write-host $AppPoolObj.ManagedRuntimeVersion
		}
		
		appPoolStatus {
			$appPoolStatus = Get-WebAppPoolState -Name $objectcheck
			write-debug $appPoolStatus.Value
			switch($appPoolStatus.Value) {
				Starting { write-host 0 }
				Started  { write-host 1 }
				Stopping { write-host 2 }
				Stopped  { write-host 3 }
				Unknown  { write-host 4 }
			}
		}
		
		siteStatus {
			$sitesObj = Get-WebsiteState -Name $objectcheck
			write-debug $sitesObj.Value
			if ($sitesObj.Value -eq 'Started') {
				write-host 1
			} else {
				write-host 0
			}
		}
		
		wp {
			$wpObj = Get-WmiObject -Class Win32_PerfFormattedData_PerfProc_Process -Namespace root\cimv2 | Where-Object {$_.IDProcess -eq "$processID"}
			write-host $wpObj.$objectcheck
		}
	}
}
