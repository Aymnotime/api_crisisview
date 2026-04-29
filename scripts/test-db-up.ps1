$ErrorActionPreference = 'Stop'

$name = 'mysql-crisiview-test'
$image = 'mysql:8.4.8'
$port = 3307
$rootPassword = 'root'
$dbName = 'incident_db'

# Remove existing container if any
try {
  $existing = (docker ps -a --format "{{.Names}}") | Where-Object { $_ -eq $name }
  if ($existing) {
    docker rm -f $name | Out-Null
  }
} catch {
  # ignore
}

# Start DB
$null = docker run -d --name $name `
  -e "MYSQL_ROOT_PASSWORD=$rootPassword" `
  -e "MYSQL_DATABASE=$dbName" `
  -p "${port}:3306" `
  $image

# Wait for readiness
$maxTries = 60
for ($i = 1; $i -le $maxTries; $i++) {
  try {
    docker exec $name mysqladmin ping -h 127.0.0.1 -p$rootPassword --silent | Out-Null
    Write-Host "Test DB ready on 127.0.0.1:$port"
    exit 0
  } catch {
    Start-Sleep -Seconds 2
  }
}

throw "MySQL test container did not become ready in time"
