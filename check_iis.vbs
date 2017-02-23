'########################################################################################
'#                                                                                      #
'# NAME:     check_iis.ps1                                                              #
'#                                                                                      #
'# AUTHOR:   TCP Team					                                                #
'# COMPANY:  TCP Sistemas e Ingenieria, S.L.                                            #
'# EMAIL:    jmmurillo@tcpsi.es; dalonso@tcpsi.es                                       #
'#                                                                                      #
'# DESCRIPTION:  Script to monitor Microsoft IIS with Zabbix Agent.                     #
'#               List sites, application and application pools containing the IIS       #
'#           @Param:                                                                    #
'#               -discovery:  IIS indicates the object you want to discover to list     #
'#               -check:  IIS indicates the object you want check                       #
'#                                                                                      #
'#           @Return:                                                                   #
'#               result: Contains the array json for discovery or simple value          #
'#                                of check IIS                                          #
'#                                                                                      #
'# CHANGELOG:                                                                           #
'# 1.0 2014-12-09 - Initial version                                                     #
'# 1.1 2015-04-27 - ApplicationPools discovery is added and modified discovery          #
'#                  of WorkerProcess. WMI simple checks are removed and made directly   #
'#                  from Template zabbix                                                #
'#                                                                                      #
'########################################################################################
Set colArgs = WScript.Arguments.Named
checkitem = colArgs.Item("c")
objectcheck = colArgs.Item("o")
pid = colArgs.Item("p")
objdiscovery = colArgs.Item("d")
debugmode = colArgs.Item("v")
'wscript.echo checkitem & " and " & objectcheck
'wscript.echo checkitem &"  " & objectcheck & "  " & pid & "  " & objdiscovery & "  " & debugmode

' For default the status is 0
returnState = 0

'wscript.echo returnState

' Supported object types:
' SITE      Administration of virtual sites
' APP       Administration of applications
' VDIR      Administration of virtual directories
' APPPOOL   Administration of application pools
' CONFIG    Administration of general configuration sections
' WP        Administration of worker processes
' REQUEST   Administration of HTTP requests
' MODULE    Administration of server modules
' BACKUP    Administration of server configuration backups
' TRACE     Working with failed request trace logs
objecttypes =Array("SITE", "APP", "APPPOOL", "WP")


' DISCOVERY
if objdiscovery <> Empty and checkitem = Empty then
	novalid = Filter(objecttypes,objdiscovery)
	if ubound(novalid) < 0 then
		wscript.echo "No valid object"
		returnstate = -2
	else
		'wscript.echo novalid(0)

		select case objdiscovery
		case "SITE"
			On Error Resume Next 

			'Const wbemFlagReturnImmediately = &h10 
			'Const wbemFlagForwardOnly = &h20 

			Set wshNetwork = WScript.CreateObject("WScript.Network") 
			strComputer = wshNetwork.ComputerName 
			strQuery = "SELECT Id,Name FROM Site" 

			Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\ROOT\WebAdministration") 
			Set colItems = objWMIService.ExecQuery(strQuery, "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly) 

			'Output the JSON header
			wscript.echo "{"
			wscript.echo   vbtab & """data"":["
			'temp variable
			temp = 1
				
			For Each objItem in colItems 
				WScript.Std    
    				
				if temp = 0 then
	 			  wscript.echo ","
				else 
				  temp = 0
				end if
				
				line = " { "& vbnewline &" ""{#SITEID}"":""" & objItem.Id & """, "& vbnewline &" ""{#SITENAME}"":""" & objItem.Name & """"& vbnewline &" }"
				wscript.echo line
			Next 

				'# Close the JSON message
        		wscript.echo "]"
        		wscript.echo "}"

		case "APP"
			On Error Resume Next 

			'Const wbemFlagReturnImmediately = &h10 
			'Const wbemFlagForwardOnly = &h20 

			Set wshNetwork = WScript.CreateObject("WScript.Network") 
			strComputer = wshNetwork.ComputerName 
			strQuery = "SELECT ApplicationPool,SiteName,Path  FROM Application" 

			Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\ROOT\WebAdministration") 
			Set colItems = objWMIService.ExecQuery(strQuery, "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly) 

			' Output the JSON header
			wscript.echo "{"
			wscript.echo   vbtab & """data"":["
			'temp variable
			temp = 1

			For Each objItem in colItems
				if temp = 0 then
					wscript.echo ","
				else
					temp = 0
				end if
				
				line = " {"& vbnewline &" ""{#APPNAME}"":""" & objItem.ApplicationPool & ""","& vbnewline & " ""{#APPSITE}"":""" & objItem.SiteName & ""","& vbnewline & " ""{#APPPATH}"":""" & objItem.Path & """"& vbnewline & " }"
				wscript.echo line 
			Next 

			'# Close the JSON message
        	wscript.echo "]"
        	wscript.echo "}"
	 
		case "APPPOOL"
			On Error Resume Next 

			'Const wbemFlagReturnImmediately = &h10 
			'Const wbemFlagForwardOnly = &h20 

			Set wshNetwork = WScript.CreateObject("WScript.Network") 
			strComputer = wshNetwork.ComputerName 
			strQuery = "SELECT Name FROM ApplicationPool" 

			Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\ROOT\WebAdministration") 
			Set colItems = objWMIService.ExecQuery(strQuery, "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly) 

			' Output the JSON header	
			wscript.echo "{"
			wscript.echo   vbtab & """data"":["
			'temp variable
			temp = 1
				
			For Each objItem in colItems
				if temp = 0 then
				wscript.echo ","
				else
					temp = 0
				end if
			
				line = " { ""{#APPPOOL}"":""" & objItem.Name & """ }"
				wscript.echo line 
			Next 

			'# Close the JSON message
			wscript.echo "]"
			wscript.echo "}"
	 
		case "WP"
			On Error Resume Next 

			'Const wbemFlagReturnImmediately = &h10 
			'Const wbemFlagForwardOnly = &h20 

			Set wshNetwork = WScript.CreateObject("WScript.Network") 
			strComputer = wshNetwork.ComputerName 
			strQuery = "SELECT * FROM WorkerProcess" 

			Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\ROOT\WebAdministration") 
			Set colItems = objWMIService.ExecQuery(strQuery, "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly) 

			' Output the JSON header
			wscript.echo "{"
			wscript.echo   vbtab & """data"":["
			'temp variable
			temp = 1

			For Each objItem in colItems
				if temp = 0 then
					wscript.echo ","
				else
					temp = 0
				end if

				line = " {"& vbnewline &" ""{#WPAPPPOOLNAME}"":""" & objItem.AppPoolName & ""","& vbnewline & " ""{#WPPID}"":""" & objItem.ProcessId & ""","& vbnewline & " ""{#WPGUID}"":""" & objItem.Guid & """"& vbnewline & " }"
				wscript.echo line
			Next

			'# Close the JSON message
			wscript.echo "]"
			wscript.echo "}"

		case else
			Document.write "Unknown Number"

	End select
   end if
end if


' CHECK
If checkitem <> Empty and objdiscovery = Empty then
	
	Select case checkitem	
		case "appPoolStatus"		
			' Connect to the WMI WebAdministration namespace.
			Set oWebAdmin = GetObject("winmgmts:root\WebAdministration")
		
			' Specify the application pool.
			Set oAppPool = oWebAdmin.Get("ApplicationPool.Name='"& objectcheck&"'")

			' Get the application pool's state and return it to the user by
			' calling a helper function.
			WScript.Echo oAppPool.GetState

		case "siteStatus" 
		   'Connect to the WMI WebAdministration namespace.
			Set oWebAdmin = GetObject("winmgmts:root\WebAdministration")

			' Specify the website.
			Set oSite = oWebAdmin.Get("Site.Name='"& objectcheck&"'")

			' Get the web site's state and return it to the user by
			' calling a helper function.
			WScript.Echo oSite.GetState
		
		case "numSites" 
			Set wshNetwork = WScript.CreateObject("WScript.Network") 
			strComputer = wshNetwork.ComputerName 
			strQuery = "SELECT Name FROM Site" 

			Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\ROOT\WebAdministration") 
			Set colItems = objWMIService.ExecQuery(strQuery, "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly) 
			
			wscript.echo colItems.Count
 		
 		case "numApps"
 			Set wshNetwork = WScript.CreateObject("WScript.Network") 
			strComputer = wshNetwork.ComputerName 
			strQuery = "SELECT SiteName FROM Application" 

			Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\ROOT\WebAdministration") 
			Set colItems = objWMIService.ExecQuery(strQuery, "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly) 
			numberApps = 0

			wscript.echo colItems.Count
		
		case "numAppPools"
			Set wshNetwork = WScript.CreateObject("WScript.Network") 
			strComputer = wshNetwork.ComputerName 
			strQuery = "SELECT Name FROM ApplicationPool" 

			Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\ROOT\WebAdministration") 
			Set colItems = objWMIService.ExecQuery(strQuery, "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly) 
			numberAppPools = 0
			For Each objItem in colItems 
			
			numberAppPools = numberAppPools +1
			
			Next
			wscript.echo numberAppPools
			
	    case "numAppIntoPool"
	       	Set wshNetwork = WScript.CreateObject("WScript.Network") 
			strComputer = wshNetwork.ComputerName 
			strQuery = "SELECT ApplicationPool FROM Application WHERE ApplicationPool = '"&objectcheck&"'" 

			Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\ROOT\WebAdministration") 
			Set colItems = objWMIService.ExecQuery(strQuery, "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly) 
			
			wscript.echo colItems.Count
		
		case "wp"
			Set wshNetwork = WScript.CreateObject("WScript.Network") 
			strComputer = wshNetwork.ComputerName 
			strQuery = "SELECT IDProcess,WorkingSet,HandleCount,PercentProcessorTime,IOReadOperationsPersec,IOWriteOperationsPersec,IOReadBytesPersec,IOWriteBytesPersec,ThreadCount FROM Win32_PerfFormattedData_PerfProc_Process WHERE IDProcess ='"& pid &"'" 

			Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\ROOT\cimv2") 
			Set colItems = objWMIService.ExecQuery(strQuery, "WQL", wbemFlagReturnImmediately + wbemFlagForwardOnly) 

			For Each objItem in colItems
				Select case objectcheck
					case "WorkingSet"
						WScript.echo objItem.WorkingSet
					case "HandleCount"
						WScript.echo objItem.HandleCount
					case "PercentProcessorTime"
						WScript.echo objItem.PercentProcessorTime
					case "IOReadOperationsPersec"
						WScript.echo objItem.IOReadOperationsPersec
					case "IOWriteOperationsPersec"
						WScript.echo objItem.IOWriteOperationsPersec
					case "IOReadBytesPersec"
						WScript.echo objItem.IOReadBytesPersec
					case "IOWriteBytesPersec"
						WScript.echo objItem.IOWriteBytesPersec
					case "ThreadCount"
						WScript.echo objItem.ThreadCount
					case else
				End Select

    			'WScript.StdOut.WriteLine "IDProcess: " & objItem.IDProcess
    			'WScript.StdOut.WriteLine objItem.&objectcheck&"'"
			Next 
		case else

		End select
		
end if