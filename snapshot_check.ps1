$file = ls \\10.26.188.4\datacert\data\gvp.go.snapshots\logs\ | sort LastWriteTime | select -last 1
get-content \\10.26.188.4\datacert\data\gvp.go.snapshots\logs\$file -totalcount 1
