$ErrorActionPreference = 'Stop'

$name = 'mysql-crisiview-test'

$existing = (docker ps -a --format "{{.Names}}") | Where-Object { $_ -eq $name }
if ($existing) {
  docker rm -f $name | Out-Null
  Write-Host 'Test DB container removed'
} else {
  Write-Host 'Test DB container not found'
}
