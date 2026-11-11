# =========================================================================
# SMARTWASTE - QUICK TEST SENSOR SIMULATOR (POWERSHELL)
# Use this to test your Web Dashboard without connecting physical hardware!
# =========================================================================

param (
    [string]$BinID = "BIN-001",
    [int]$Fill = 85,
    [string]$ServerUrl = "http://localhost:8080/SmartWaste/api/bin/update-fill"
)

Write-Host "Sending test reading to SmartWaste..." -ForegroundColor Cyan
Write-Host "Target: $ServerUrl" -ForegroundColor Gray
Write-Host "Bin ID: $BinID | Fill Level: $Fill%" -ForegroundColor Yellow

$body = @{
    binID = $BinID
    fillPercent = $Fill
}

try {
    $res = Invoke-RestMethod -Uri $ServerUrl -Method POST -Body $body
    Write-Host "`n[RESPONSE FROM SERVER]:" -ForegroundColor Green
    Write-Host $res -ForegroundColor White

    Write-Host "`nCheck your web dashboard at: http://localhost:8080/SmartWaste/dashboard" -ForegroundColor Cyan
    Write-Host "Check alerts page at:        http://localhost:8080/SmartWaste/alert" -ForegroundColor Cyan
} catch {
    Write-Host "[ERROR] Failed to send data: $_" -ForegroundColor Red
}
