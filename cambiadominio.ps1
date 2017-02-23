Param(
	[string] $origen,
	[string] $destino
)

Stop-Service "Zabbix Agent"

cd '\Program Files\Zabbix Agent'
get-content .\zabbix_agentd.conf | %{$_ -replace $origen, $destino} | set-content zabbix_agentd.conf.new
move-item -force zabbix_agentd.conf.new zabbix_agentd.conf

Start-Service "Zabbix Agent"