$file = ls C:\Users\jesus\Documents\snapshot_logs\ | sort LastWriteTime | select -last 1
$line = get-content C:\Users\jesus\Documents\snapshot_logs\$file

Write-Host "{"
Write-Host "`t""data"":["
Write-Host

$temp = 0

foreach ($i in $line) {
 Write-Host "`t{"
 Write-Host "`t`"`{#LINE`}`":`"$i`""
 Write-Host "`t`}"
 $temp++
	
 if ($temp -ne $line.Count){
  Write-Host "`t,"
 } 
}

Write-Host
Write-Host
Write-Host "`t]"
Write-Host "}"
