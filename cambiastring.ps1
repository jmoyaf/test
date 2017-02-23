Param(
	[string] $origen,
	[string] $destino,
	[string] $origen1,
	[string] $destino1,
	[string] $origen2,
	[string] $destino2,
	[string] $origen3,
	[string] $destino3
)

Stop-Service "Zabbix Agent"

cd '\Program Files\Zabbix Agent'
get-content .\zabbix_agentd.conf | %{$_ -replace $origen, $destino} | %{$_ -replace $origen1, $destino1} | %{$_ -replace $origen2, $destino2} | %{$_ -replace $origen3, $destino3} |set-content zabbix_agentd.conf.new
move-item -force zabbix_agentd.conf.new zabbix_agentd.conf

Start-Service "Zabbix Agent"