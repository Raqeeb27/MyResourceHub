<#
Author  : Mohammed Abdul Raqeeb
GitHub  : https://github.com/Raqeeb27
Date    : 07/01/2026
Purpose : Campus Wi-Fi login/logout automation with background keep-alive
#>

Param(
    [Parameter(Mandatory=$false)]
    [string]$Command,

    [Parameter(Mandatory=$false)]
    [string]$Username,

    [Parameter(Mandatory=$false)]
    [string]$Password,

    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ExtraArgs
)

$ErrorActionPreference = "Stop"

# -------------------------------
# -------- CONFIGURATION --------
# -------------------------------
$GATEWAY     = "10.100.100.1"
$LOGIN_URL   = "https://10.100.100.1:8090/login.xml"
$LIVE_URL    = "https://10.100.100.1:8090/live"
$LOGOUT_URL  = "https://10.100.100.1:8090/logout.xml"
# -------------------------------


function Show-Usage {
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "   ./wifi-connect.ps1 login <username> <password>" -ForegroundColor Yellow
    Write-Host "   ./wifi-connect.ps1 logout <username>" -ForegroundColor Yellow
    exit 1
}

function Try-ParseXml {
    param([string]$Content)

    try {
        return [xml]$Content
    } catch {
        return $null
    }
}


# -------------------------------
# -------- Check Wi-Fi ----------
# -------------------------------
function Check-WiFi {
    Write-Host "`nChecking campus Wi-Fi gateway..."

    try {
        $reachable = Test-Connection -Count 1 -Quiet $GATEWAY -ErrorAction Stop
    } catch {
        Write-Host "`nError: Test-Connection failed unexpectedly." -ForegroundColor Red
        Write-Host "`nUniversity Wi-Fi gateway unreachable." -ForegroundColor Red
        Write-Host "Ensure you're connected to the campus Wi-Fi.`n" -ForegroundColor Red
        exit 1
    }

    if (-not $reachable) {
        Write-Host "`nUniversity Wi-Fi gateway unreachable." -ForegroundColor Red
        Write-Host "Ensure you're connected to the campus Wi-Fi.`n" -ForegroundColor Red
        exit 1
    }

    Write-Host "Campus Wi-Fi gateway verified.`n" -ForegroundColor Green
}


# -------------------------------------------------------
# ----- Start detached keepalive ------
# -------------------------------------------------------
function Start-KeepAliveDetached($User) {

    $TempScript = "$env:TEMP\wifi_keepalive_$User.ps1"

@'
while ($true) {
    try {
        $ts  = [int][double]::Parse((Get-Date -UFormat '%s'))
        $url = "https://10.100.100.1:8090/live?mode=192&username=__USER__&a=$ts&producttype=0"

        curl.exe -k $url | Out-Null
    } catch {}

    Start-Sleep -Seconds 150
}
'@ -replace "__USER__", $User | Out-File $TempScript -Encoding UTF8 -Force

    # Start detached background PowerShell (survives closing this window)
    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$TempScript`"" `
        -WindowStyle Hidden

}


# -------------------------------------------------------
# -------- Stop detached process for this user ----------
# -------------------------------------------------------
function Stop-KeepAliveDetached($User) {
    $pattern = "wifi_keepalive_$User.ps1"

    # Use Win32_Process to inspect commandlines reliably
    $procs = Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" |
             Where-Object { $_.CommandLine -like "*$pattern*" }

    if ($procs) {
        Write-Host "Stopping keep-alive background processes for '$User'..."
        foreach ($p in $procs) {
            try {
                Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
            } catch {}
        }
        Write-Host "Stopped." -ForegroundColor Green
    } else {
        Write-Host "No detached keep-alive process running for '$User'." -ForegroundColor Yellow
    }

    $TempScript = Join-Path $env:TEMP "wifi_keepalive_$User.ps1"
    if (Test-Path $TempScript) {
        try {
            Remove-Item $TempScript -Force -ErrorAction Stop
            Write-Host "`nRemoved detached script file: Local\Temp\$pattern" -ForegroundColor Green
        } catch {
            Write-Host "`nWarning: Could not remove detached script file: Local\Temp\$pattern" -ForegroundColor Yellow
        }
    }
}


# -------------------------------
# -------- Login Function -------
# -------------------------------
function Login($User, $Pass) {
    Check-WiFi

    Write-Host "Terminating any existing keep-alive sessions for '$User'..."

    # Kill old keepalive processes for same user
    Stop-KeepAliveDetached $User

    Write-Host "`nLogging in as '$User'..."

    # Generate timestamp
    $TS = [int][double]::Parse((Get-Date -UFormat %s))

    # Send login request via curl and capture XML response
    $output = curl.exe -k -s -X POST $LOGIN_URL `
        -d "mode=191" `
        -d "username=$User" `
        -d "password=$Pass" `
        -d "a=$TS" `
        -d "producttype=0"

    if ($LASTEXITCODE -ne 0 -or -not $output) {
        Write-Host "Error: curl login request failed." -ForegroundColor Red
        return
    }

    $xml = Try-ParseXml $output
    if (-not $xml) {
        Write-Host "Error: Server returned invalid XML." -ForegroundColor Red
        Write-Host $output
        return
    }

    $status  = $xml.requestresponse.status.'#cdata-section'
    $message = $xml.requestresponse.message.'#cdata-section'

    # ---- Interpret result ----
    if ($status -eq "LIVE") {
        Write-Host "`nLogin Successful" -ForegroundColor Green
        if ($message) {
            $displayMessage = $message -replace [regex]::Escape('{username}'), "'$User'"
            Write-Host $displayMessage
        }
        Write-Host "`nStarting detached keep-alive process..."
        Start-KeepAliveDetached $User
        Write-Host "Keep-alive running in background. You can close this window." -ForegroundColor Green
        return
    }

    if ($message -match "Invalid user name") {
        Write-Host "Login failed: Invalid username or password." -ForegroundColor Red
        return
    }

    if ($message -match "maximum login limit") {
        Write-Host "Login failed: Maximum login limit reached (already logged in elsewhere)." -ForegroundColor Yellow
        return
    }

    # Fallback for other messages
    Write-Host "Login not successful." -ForegroundColor Red
    if ($message) {
        Write-Host "Server message:"
        Write-Host $message
    } else {
        Write-Host $output
    }
}


# -------------------------------
# -------- Logout Function ------
# -------------------------------
function Logout($User) {
    Check-WiFi

    Write-Host "Logging out '$User'..."

    $TS = [int][double]::Parse((Get-Date -UFormat %s))

    $output = curl.exe -k -s -X POST $LOGOUT_URL `
        -d "mode=193" `
        -d "username=$User" `
        -d "a=$TS" `
        -d "producttype=0"

    if ($LASTEXITCODE -ne 0 -or -not $output) {
        Write-Host "Error: The logout request through commandline has failed." -ForegroundColor Red
        Write-Host "You may need to logout manually through the web portal." -ForegroundColor Yellow
        return
    } else {
        try {
            $xml = Try-ParseXml $output
            if (-not $xml) {
                Write-Host "Error: Server returned invalid XML." -ForegroundColor Red
                Write-Host $output
                return
            }
            $logoutMsg = $xml.requestresponse.logoutmessage.'#cdata-section'
            $message   = $xml.requestresponse.message.'#cdata-section'

            if ($logoutMsg) {
                Write-Host "$logoutMsg"
            } elseif ($message) {
                if ($message -match "You&#39;ve signed out"){
                    Write-Host "You have signed out successfully`n" -ForegroundColor Green
                }
                else{
                    Write-Host "$message"
                }
            }
        } catch {
            Write-Host "Server response (unparsed):" -ForegroundColor Red
            Write-Host $output
        }
    }

    # Stop background keep-alive
    Stop-KeepAliveDetached $User
}


# -------------------------------
# -------- Command Router -------
# -------------------------------
if (-not $Command) {
    Show-Usage
}

if ($ExtraArgs.Count -gt 0) {
    Write-Host "Error: Too many arguments supplied: $($ExtraArgs -join ', ')" -ForegroundColor Red
    Write-Host "`nExpected format:" -ForegroundColor Yellow
    Show-Usage
    exit 1
}

switch ($Command.ToLower()) {

    "login" {
        if ($Username -and $Password -and ($PSCmdlet.MyInvocation.BoundParameters.Count -eq 3)) {
            if ($Username -match '^\d{12}$') {
                Login $Username $Password
            } else {
                Write-Host "Error: Username must be exactly 12 digits." -ForegroundColor Red
                Show-Usage
            }
        } else {
            Write-Host "Error: login requires exactly <username> <password>" -ForegroundColor Red
            Show-Usage
        }
    }

    "logout" {
        if ($Username -and ($PSCmdlet.MyInvocation.BoundParameters.Count -eq 2)) {
            if ($Username -match '^\d{12}$') {
                Logout $Username
            } else {
                Write-Host "Error: Username must be exactly 12 digits." -ForegroundColor Red
                Show-Usage
            }
        } else {
            Write-Host "Error: logout requires exactly <username>" -ForegroundColor Red
            Show-Usage
        }
    }

    default {
        Write-Host "Invalid command." -ForegroundColor Red
        Show-Usage
    }
}
