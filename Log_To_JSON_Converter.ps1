$InputLogPath = "C:\programdata\failed_rdp.log"
$OutputJsonPath = "C:\programdata\failed_rdp.json"

if (Test-Path $InputLogPath) {
    try {
        $Data = Import-Csv -Path $InputLogPath -ErrorAction Stop
        # adds the [ ], the commas, and removes new lines.
        $JsonOutput = $Data | ConvertTo-Json -Depth 10 -Compress
        # Write to file
        $JsonOutput | Out-File -FilePath $OutputJsonPath -Encoding utf8 -Force
        Write-Host "Successfully exported JSON Array to $OutputJsonPath" -ForegroundColor Green
    }
    catch {
        Write-Host "Conversion Error: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Warning "Input log file not found at $InputLogPath"
}