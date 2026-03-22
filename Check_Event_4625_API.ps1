$LogPath = "C:\programdata\failed_rdp.log"
$API_KEY = "PASTE_api_key-here"
$TestMode = $false # Set to $false for real monitoring

# State Tracking: Initialize with current time to ignore historical logs
$LastEventTime = Get-Date

if (!(Test-Path $LogPath)) {
    "timestamp,ip_address,country,city,latitude,longitude" | Out-File -FilePath $LogPath -Encoding utf8
}

write-host "Starting Script... Test Mode: $TestMode" -ForegroundColor Cyan

while($true) {
    if ($TestMode) {
        # --- ORIGINAL TEST MODE LOGIC ---
        $TestIPs = "185.156.74.65", "45.141.84.10", "193.163.125.115", "92.118.160.17"
        $TestCountries = "Russia", "China", "Netherlands", "United Kingdom"
        $TestCities = "Moscow", "Beijing", "Amsterdam", "London"
        
        $RandomIdx = Get-Random -Maximum 4
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        # Random Lat/Long for map testing
        $i = Get-Random -Max 4
        $Lat = ( (Get-Random -Min -30 -Max 30) + (Get-Random -Min 1 -Max 9999) / 10000 ).ToString("F4")
        $Lon = ( (Get-Random -Min -60 -Max 60) + (Get-Random -Min 1 -Max 9999) / 10000 ).ToString("F4")

        $Output = "$Timestamp,$($TestIPs[$RandomIdx]),$($TestCountries[$RandomIdx]),$($TestCities[$RandomIdx]),$Lat,$Lon"
        write-host "TEST DATA GENERATED: $Output" -ForegroundColor Yellow
        
        # Log to file
        $Output | Out-File -FilePath $LogPath -Append -Encoding utf8
    }
    else {
        # --- LIVE MONITORING WITH STATE TRACKING ---
        $Events = Get-WinEvent -LogName "Security" -FilterXPath "*[System[(EventID=4625)]]" -ErrorAction SilentlyContinue | Where-Object { $_.TimeCreated -gt $LastEventTime }
        
        if ($Events) {
            # Sort to ensure we process in chronological order
            $Events = $Events | Sort-Object TimeCreated
            
            foreach($Event in $Events) {
                $IP = $Event.Properties[19].Value
                if ($IP -and $IP -ne "-" -and $IP -ne "127.0.0.1") {
                    try {
                        $GeoData = Invoke-RestMethod "https://api.ipgeolocation.io/ipgeo?apiKey=$API_KEY&ip=$IP"
                        $Timestamp = $Event.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
                        $Output = "$Timestamp,$IP,$($GeoData.country_name),$($GeoData.city),$($GeoData.latitude),$($GeoData.longitude)"
                        
                        $Output | Out-File -FilePath $LogPath -Append -Encoding utf8
                        write-host "LIVE ATTACK DETECTED: $Output" -ForegroundColor Red
                    }
                    catch {
                        write-host "API Error or IP skip: $IP" -ForegroundColor Gray
                    }
                }
                # Update tracker to the time of this specific event
                $LastEventTime = $Event.TimeCreated
            }
        }
    }
    
    $Output = $null # Clear for next loop
    Start-Sleep -Seconds 10
}
