# starship-install.ps1
# Description: Install Starship prompt with any desired preset, configure terminals, and set fonts.
# Author: Mohammed Abdul Raqeeb (converted to PowerShell)
# Date: 31/01/2024 (Updated: 24/05/2025)

function Wait-StarshipScript {
    Start-Sleep -Seconds 2
    Write-Host "`n"
}

function Test-WingetInstalled {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Warning "winget is not found. Please install winget to ensure dependencies can be managed automatically. You can download it from the Microsoft Store or GitHub."
        return $false
    }
    return $true
}

function Install-Dependencies {
    Write-Host "`nChecking for winget and other dependencies..."
    Log-AndPause

    if (-not (Test-WingetInstalled)) {
        Write-Warning "Skipping dependency installation as winget is not available."
        Log-AndPause
        return
    }

    # As Invoke-WebRequest is used for downloads, curl and wget are not strictly necessary for this script's functions.
    # If other dependencies were required via winget, they would be added here.
    Write-Host "Basic dependencies for Starship primarily involve PowerShell itself and the ability to download."
    Write-Host "This script uses PowerShell's built-in Invoke-WebRequest for downloads."
    Log-AndPause
}

function Install-Starship {
    if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
        Write-Host "Starship not found, installing..."
        Log-AndPause
        try {
            Invoke-WebRequest -Uri "https://starship.rs/install.ps1" -UseBasicParsing | Invoke-Expression
            if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
                Write-Warning "Starship installation script executed, but 'starship' command is still not found. You might need to restart PowerShell or check your PATH."
            } else {
                Write-Host "Starship installed successfully."
            }
        } catch {
            Write-Error "Failed to install Starship: $($_.Exception.Message)"
        }
    } else {
        Write-Host "Starship is already installed.`n"
    }
    Log-AndPause
}

function Select-StarshipPreset {
    Write-Host "`nSelect a Starship prompt preset:`n"
    Write-Host " 1. Nerd Font Symbols"
    Write-Host " 2. No Nerd Font"
    Write-Host " 3. Bracketed Segments"
    Write-Host " 4. Plain Text Symbols"
    Write-Host " 5. No Runtime Versions"
    Write-Host " 6. No Empty Icons"
    Write-Host " 7. Pure Preset"
    Write-Host " 8. Pastel Powerline"
    Write-Host " 9. Tokyo Night"
    Write-Host " 10. Gruvbox Rainbow"
    Write-Host " 11. Custom Starship Configuration - 1"
    Write-Host " 12. Custom Starship Configuration - 2"
    Write-Host " 13. None, Exit`n"
    $choice = Read-Host "Enter the number corresponding to your choice"
    switch ($choice) {
        1 { Set-StarshipPreset "nerd-font-symbols" }
        2 { Set-StarshipPreset "no-nerd-font" }
        3 { Set-StarshipPreset "bracketed-segments" }
        4 { Set-StarshipPreset "plain-text-symbols" }
        5 { Set-StarshipPreset "no-runtime-versions" }
        6 { Set-StarshipPreset "no-empty-icons" }
        7 { Set-StarshipPreset "pure-preset" }
        8 { Set-StarshipPreset "pastel-powerline" }
        9 { Set-StarshipPreset "tokyo-night" }
        10 { Set-StarshipPreset "gruvbox-rainbow" }
        11 { Set-StarshipCustomConfiguration "1" }
        12 { Set-StarshipCustomConfiguration "2" }
        13 { Write-Host "`nExiting..."; Pause-StarshipScript; exit }
        Default { Write-Host "`nInvalid choice. Exiting..."; Pause-StarshipScript; exit }
    }
}

function Set-StarshipCustomConfiguration($custom) {
    Write-Host "`n`n`nApplying Custom Starship - $custom preset..."
    Wait-StarshipScript
    $configDir = Join-Path $env:APPDATA "starship"
    if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir | Out-Null }
    $url = "https://raw.githubusercontent.com/Raqeeb27/MyResourceHub/main/Starship_Prompt/custom_starship_config-$custom.toml"
    try {
        Invoke-WebRequest -Uri $url -OutFile (Join-Path $configDir "starship.toml") -ErrorAction Stop
        Write-Host "Custom Starship - $custom preset applied successfully.`n"
    } catch {
        Write-Error "Failed to download custom configuration from ${url}: $($_.Exception.Message)"
    }
}

function Set-StarshipPreset($preset) {
    Write-Host "`n`n`nApplying Starship $preset preset..."
    Wait-StarshipScript
    $configDir = Join-Path $env:APPDATA "starship"
    if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir | Out-Null }
    try {
        starship preset $preset -o (Join-Path $configDir "starship.toml") -ErrorAction Stop
        Write-Host "Starship $preset preset applied successfully.`n"
    } catch {
        Write-Error "Failed to apply Starship preset '$preset': $(${_}.Exception.Message)"
    }
}

function Initialize-StarshipConfig {
    Write-Host "Setting up starship configuration file..."
    Wait-StarshipScript
    $configFile = Join-Path (Join-Path $env:APPDATA "starship") "starship.toml"
    if (Test-Path $configFile) {
        Write-Host "Starship is already configured."
        $choice = Read-Host "Do you want to configure a different preset? (Y/N)"
        if ($choice -match '^(y|yes|)$') {
            Start-Sleep 1
            Select-StarshipPreset
        } else {
            Write-Host "`nConfiguration file is unchanged."
        }
    } else {
        Select-StarshipPreset
    }
    Pause-StarshipScript
}

function Update-PowerShellProfile {
    $profilePath = $PROFILE
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }
    $profileContent = Get-Content $profilePath -Raw
    if ($profileContent -match 'Invoke-Expression \(starship init powershell\)') {
        Write-Host "Starship is already configured in your PowerShell profile.`n"
        return
    }
    $choice = Read-Host "Do you want to configure your PowerShell profile? (y/n, default: yes)"
    if ($choice -match '^(y|yes|)$') {
        Add-Content $profilePath "`nInvoke-Expression (starship init powershell)"
        Write-Host "Configured Starship in PowerShell profile."
    } else {
        Write-Host "`nSkipped PowerShell profile configuration."
    }
    Pause-StarshipScript
}

function Get-NerdFont {
    Write-Host "Downloading CascadiaCode Nerd Font for Preset..."
    Pause-StarshipScript
    $fontZip = Join-Path $env:TEMP "CascadiaCode.zip" # Using TEMP directory for download
    try {
        Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip" -OutFile $fontZip -ErrorAction Stop
        Write-Host "Font downloaded to $fontZip"
    } catch {
        Write-Error "Failed to download CascadiaCode Nerd Font: $(${_}.Exception.Message)"
        return $null
    }
    Pause-StarshipScript
    return $fontZip
}

function Install-NerdFont {
    Write-Host "Attempting to install Nerd Font..."
    Pause-StarshipScript

    $fontDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
    if (-not (Test-Path $fontDir)) { New-Item -ItemType Directory -Path $fontDir | Out-Null }

    $fontZip = Get-NerdFont
    if (-not $fontZip) {
        Write-Warning "Skipping font installation due to download failure."
        Pause-StarshipScript
        return
    }

    $extractDir = Join-Path $env:TEMP "CascadiaCode_Extracted" # Using TEMP directory for extraction
    try {
        Expand-Archive -Path $fontZip -DestinationPath $extractDir -Force -ErrorAction Stop
        Write-Host "Font archive extracted to $extractDir"

        $fontFiles = Get-ChildItem "$extractDir\*.ttf"
        if ($fontFiles.Count -eq 0) {
            Write-Warning "No .ttf files found in the extracted font directory."
            Pause-StarshipScript
            return
        }

        foreach ($file in $fontFiles) {
            try {
                Copy-Item $file.FullName $fontDir -Force -ErrorAction Stop
                Write-Host "Copied $($file.Name) to fonts directory."
            } catch {
                Write-Error "Failed to copy $($file.Name) to fonts directory: $(${_}.Exception.Message)"
            }
        }
        Write-Host "Fonts installed. You may need to set the font manually in your terminal settings (e.g., Windows Terminal, VS Code)."
    } catch {
        Write-Error "Failed to extract or copy fonts: $(${_}.Exception.Message)"
    } finally {
        # Clean up temporary files
        if (Test-Path $fontZip) { Remove-Item $fontZip -Force -ErrorAction SilentlyContinue }
        if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
    Pause-StarshipScript
}

function Main {
    Clear-Host
    Write-Host "`n------- Automated Starship Installation Script -------"
    Pause-StarshipScript

    Install-Dependencies
    Install-Starship
    Initialize-StarshipConfig
    Update-PowerShellProfile
    Install-NerdFont

    Write-Host "`nStarship Installation Successful!!!`n`n`n----- SUCCESS -----`n`n"
    Write-Host "Please restart your terminal or run '. $PROFILE' to apply changes."
    Read-Host "Press Enter to Exit..."
}

Main