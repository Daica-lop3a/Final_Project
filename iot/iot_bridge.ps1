# =========================================================================
# SMARTWASTE - ARDUINO SERIAL TO WEB HTTP BRIDGE (POWERSHELL)
# Reads JSON from Arduino Uno USB COM Port and POSTs to SmartWaste Web Server
# No external dependencies or Python installation required!
# =========================================================================

param (
    [string]$Port = "",
    [int]$BaudRate = 115200,
    [string]$ServerUrl = "http://localhost:8080/SmartWaste/api/bin/update-fill"
)

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "   SMARTWASTE - IOT SENSOR BRIDGE (ARDUINO -> WEB)    " -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Cyan

# 1. Detect Available COM Ports
$availablePorts = [System.IO.Ports.SerialPort]::getportnames()

if ($availablePorts.Count -eq 0) {
    Write-Host "[ERROR] No COM ports detected. Please plug in your Arduino Uno USB cable!" -ForegroundColor Red
    exit
}

if ([string]::IsNullOrWhiteSpace($Port)) {
    Write-Host "Available COM Ports: $($availablePorts -join ', ')" -ForegroundColor Yellow
    if ($availablePorts.Count -eq 1) {
        $Port = $availablePorts[0]
        Write-Host "Auto-selected only available port: $Port" -ForegroundColor Green
    } else {
        $Port = Read-Host "Enter Arduino COM Port (e.g. $($availablePorts[0]))"
    }
}

Write-Host "[INFO] Connecting to $Port at $BaudRate baud..." -ForegroundColor Cyan
Write-Host "[INFO] Target Web API: $ServerUrl" -ForegroundColor Cyan
Write-Host "[INFO] Press Ctrl + C to stop.`n" -ForegroundColor DarkGray

# 2. Configure Serial Port
$serial = New-Object System.IO.Ports.SerialPort $Port, $BaudRate, None, 8, One
$serial.ReadTimeout = 4000
$serial.WriteTimeout = 1000

try {
    $serial.Open()
    Write-Host "[SUCCESS] Serial port $Port opened successfully! Waiting for sensor data...`n" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to open $Port : $_" -ForegroundColor Red
    Write-Host "Tip: Close Arduino IDE Serial Monitor if it is currently open, as it locks the COM port." -ForegroundColor Yellow
    exit
}

# 3. Main Loop
try {
    while ($true) {
        try {
            $line = $serial.ReadLine().Trim()
            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            # Display raw message from Arduino
            $timestamp = (Get-Date).ToString("HH:mm:ss")

            # Check if JSON
            if ($line.StartsWith("{") -and $line.EndsWith("}")) {
                try {
                    $json = $line | ConvertFrom-Json

                    # Skip initialization message
                    if ($json.status -eq "READY") {
                        Write-Host "[$timestamp] [ARDUINO] Sensor booted and ready." -ForegroundColor Cyan
                        continue
                    }

                    if ($json.error) {
                        Write-Host "[$timestamp] [WARNING] Sensor error: $($json.error)" -ForegroundColor Yellow
                        continue
                    }

                    $binID = $json.bin_id
                    $fillLevel = $json.fill_level
                    $dist = $json.distance_cm

                    # Color coding by fill level
                    $color = "Green"
                    if ($fillLevel -ge 80) { $color = "Red" }
                    elseif ($fillLevel -ge 60) { $color = "Yellow" }

                    Write-Host "[$timestamp] [DATA] Bin: $binID | Distance: ${dist}cm | Fill: ${fillLevel}%" -ForegroundColor $color

                    # Send HTTP POST to SmartWaste Web API
                    $body = @{
                        binID = $binID
                        fillPercent = $fillLevel
                    }

                    $response = Invoke-RestMethod -Uri $ServerUrl -Method POST -Body $body -TimeoutSec 5
                    Write-Host "           [WEB API] $response" -ForegroundColor DarkCyan

                } catch {
                    Write-Host "[$timestamp] [PARSE ERROR] Invalid JSON or Web API offline: $_" -ForegroundColor DarkYellow
                }
            } else {
                Write-Host "[$timestamp] [RAW] $line" -ForegroundColor Gray
            }

        } catch [System.TimeoutException] {
            # Serial timeout (normal if Arduino takes 2s between sends)
            Start-Sleep -Milliseconds 100
        }
    }
} finally {
    if ($serial.IsOpen) {
        $serial.Close()
        Write-Host "`n[INFO] Closed serial port $Port." -ForegroundColor Yellow
    }
}
