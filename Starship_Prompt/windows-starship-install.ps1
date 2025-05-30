# starship-install.ps1
# Description: Install Starship prompt with any desired preset, configure terminals, and set fonts.
# Author: Mohammed Abdul Raqeeb (converted to PowerShell)
# Date: 31/01/2024 (Updated: 24/05/2025)

function Wait-StarshipScript {
    Start-Sleep -Seconds 2
    Write-Host "`n"
}

function Add-StarshipToPath {
    param (
        [string]$BinDir
    )
    $envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    if ($envPath -notmatch [regex]::Escape($BinDir)) {
        [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$BinDir", [System.EnvironmentVariableTarget]::Machine)
        Write-Host "Added $BinDir to system PATH. You may need to restart your terminal."
    }
}

function Install-Starship {
    $starshipExe = Join-Path $env:ProgramFiles "starship\bin\starship.exe"

    Write-Host "Downloading and installing latest Starship..."
    Wait-StarshipScript

    $zipUrl = "https://github.com/starship/starship/releases/download/v1.23.0/starship-x86_64-pc-windows-msvc.zip"
    $tempZip = Join-Path $env:TEMP "starship.zip"
    $extractDir = Join-Path $env:TEMP "starship_extracted"

    try {
        Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -ErrorAction Stop
        if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue }
        Expand-Archive -Path $tempZip -DestinationPath $extractDir -Force -ErrorAction Stop

        $starshipSrc = Get-ChildItem -Path $extractDir -Filter "starship.exe" -Recurse | Select-Object -First 1
        if (-not $starshipSrc) {
            Write-Error "starship.exe not found in the extracted archive."
            return
        }

        $destDir = Join-Path $env:ProgramFiles "starship"
        $binDir = Join-Path $destDir "bin"
        if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir | Out-Null }

        Move-Item -Path $starshipSrc.FullName -Destination $binDir -Force
        Write-Host "Starship installed to $binDir."

        Add-StarshipToPath -BinDir $binDir
    } catch {
        Write-Error "Failed to install Starship: $($_.Exception.Message)"
    } finally {
        if (Test-Path $tempZip) { Remove-Item $tempZip -Force -ErrorAction SilentlyContinue }
        if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
    Wait-StarshipScript
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
    Write-Host " 11. Jetpack"
    Write-Host " 12. Catppuccin Mocha"
    Write-Host " 13. Catppuccin Frappe"
    Write-Host " 14. Catppuccin Macchiato"
    Write-Host " 15. Catppuccin Latte"
    Write-Host " 16. Custom Starship Configuration - 1"
    Write-Host " 17. Custom Starship Configuration - 2"
    Write-Host " 18. None, Exit`n"
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
        11 { Set-StarshipPreset "jetpack" }
        12 { Set-StarshipPreset "catppuccin_mocha" }
        13 { Set-StarshipPreset "catppuccin_frappe" }
        14 { Set-StarshipPreset "catppuccin_macchiato" }
        15 { Set-StarshipPreset "catppuccin_latte" }
        16 { Set-StarshipCustomConfiguration "1" }
        17 { Set-StarshipCustomConfiguration "2" }
        18 { Write-Host "`nExiting..."; Pause-StarshipScript; exit }
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
    if ($preset -like "catppuccin*") {
        if ($preset -ne "catppuccin_mocha") {
            $global:preset1 = $preset
        }
        $preset = "catppuccin-powerline"
    }
    $configDir = Join-Path $env:APPDATA "starship"
    if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir | Out-Null }
    try {
        starship preset $preset -o (Join-Path $configDir "starship.toml")
        Write-Host "Starship $preset preset applied successfully.`n"
    } catch {
        Write-Error "Failed to apply Starship preset '$preset': $(${_}.Exception.Message)"
    }
}

function Initialize-StarshipConfig {
    Write-Host "`nSetting up starship configuration file..."
    Wait-StarshipScript
    $configFile = Join-Path (Join-Path $env:APPDATA "starship") "starship.toml"
    if (Test-Path $configFile) {
        Write-Host "Starship is already configured."
        $choice = Read-Host "Do you want to configure a different preset? (Y/N)"
        if ($choice -match '^(y|yes|)$') {
            Wait-StarshipScript
            Select-StarshipPreset
        } else {
            Write-Host "`nConfiguration file is unchanged."
        }
    } else {
        Select-StarshipPreset
    }
    Wait-StarshipScript
}

function Update-PowerShellProfile {
    $profilePathsToUpdate = @(
        (Join-Path $HOME "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"),
        (Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1")
    )

    $starshipLineToAdd = "`nInvoke-Expression (starship init powershell)"
    $starshipCheckRegex = '(?i)\b(?:Invoke-Expression|iex)\s*\(?\s*starship\s+init\s+powershell\s*\)?'

    Write-Host "Attempting to configure PowerShell profiles for both Windows PowerShell and PowerShell Core.`n"

    foreach ($currentProfilePath in $profilePathsToUpdate) {
        $profileDir = Split-Path $currentProfilePath -Parent
        $profileFileName = Split-Path $currentProfilePath -Leaf

        Write-Host "Processing profile: $currentProfilePath"

        if (-not (Test-Path $profileDir)) {
            Write-Host "  Profile directory does not exist. Creating: $profileDir"
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }

        if (-not (Test-Path $currentProfilePath)) {
            Write-Host "  Profile file does not exist. Creating: $profileFileName"
            New-Item -ItemType File -Path $currentProfilePath -Force | Out-Null
        }

        $profileContent = ""
        try {
            $profileContent = Get-Content $currentProfilePath -Raw -ErrorAction Stop
        } catch {
            Write-Error "  Failed to read profile content from '$currentProfilePath': $($_.Exception.Message)"
            Write-Host "  Assuming empty profile content for this file."
        }

        if ($profileContent -match $starshipCheckRegex) {
            Write-Host "  Starship is already configured in this profile."
        } else {
            $choice = Read-Host "  Do you want to add Starship configuration to '$profileFileName'? (y/n, default: yes)"
            if ($choice -match '^(y|yes|)$') {
                try {
                    Add-Content $currentProfilePath $starshipLineToAdd
                    Write-Host "  Configured Starship in '$profileFileName'."

                    $updatedContent = Get-Content $currentProfilePath -Raw
                    if (-not ($updatedContent -match $starshipCheckRegex)) {
                        Write-Error "  FAILED: Starship configuration not found in '$profileFileName' after writing. Please check manually."
                    }
                } catch {
                    Write-Error "  Failed to add content to '$profileFileName': $($_.Exception.Message)"
                }
            } else {
                Write-Host "  Skipped configuration for '$profileFileName'."
            }
        }
        Write-Host ""
    }
    Wait-StarshipScript
}

function Test-NerdFontInstalled {
    param (
        [string]$FontDirectory
    )
    $requiredFontFiles = @(
        "CaskaydiaCoveNerdFont-Regular.ttf",
        "CaskaydiaCoveNerdFont-Bold.ttf"
    )

    foreach ($fontFile in $requiredFontFiles) {
        $fontPath = Join-Path $FontDirectory $fontFile
        if (-not (Test-Path $fontPath)) {
            Write-Host "  Missing CaskaydiaCoveNerdFont"
            return $false
        }
    }
    return $true
}

function Get-NerdFont {
    Write-Host "Downloading CaskaydiaCove Nerd Font for Preset..."
    Wait-StarshipScript
    $fontZip = Join-Path $env:TEMP "CascadiaCode.zip"
    try {
        Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip" -OutFile $fontZip -ErrorAction Stop
        Write-Host "Font downloaded to $fontZip"
    } catch {
        Write-Error "Failed to download CascadiaCode Nerd Font: $(${_}.Exception.Message)"
        return $null
    }
    Wait-StarshipScript
    return $fontZip
}

function Install-NerdFont {
    Write-Host "Attempting to install Nerd Font..."
    Wait-StarshipScript

    $fontDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
    if (-not (Test-Path $fontDir)) { New-Item -ItemType Directory -Path $fontDir | Out-Null }

    if (Test-NerdFontInstalled -FontDirectory $fontDir) {
        Write-Host "CaskaydiaCove Nerd Font appears to be already installed. Skipping download and installation.`n"
        Wait-StarshipScript
        return
    }

    $fontZip = Get-NerdFont
    if (-not $fontZip) {
        Write-Warning "Skipping font installation due to download failure."
        Wait-StarshipScript
        return
    }

    $extractDir = Join-Path $env:TEMP "CaskaydiaCove_Extracted"
    try {
        Expand-Archive -Path $fontZip -DestinationPath $extractDir -Force -ErrorAction Stop
        Write-Host "Font archive extracted to $extractDir`n"

        $fontFiles = Get-ChildItem "$extractDir\*.ttf"
        if ($fontFiles.Count -eq 0) {
            Write-Warning "No .ttf files found in the extracted font directory."
            Wait-StarshipScript
            return
        }

        foreach ($file in $fontFiles) {
            try {
                try {
                    Copy-Item $file.FullName $fontDir -Force -ErrorAction Stop
                    Write-Host "Copied $($file.Name) to fonts directory."
                } catch {
                    Write-Warning "Skipped $($file.Name): File is in use or locked by another process."
                }
            } catch {
                Write-Error "Failed to copy $($file.Name) to fonts directory: $(${_}.Exception.Message)"
            }
        }
        Write-Host "`nFonts installed. You may need to set the font manually in your terminal settings (e.g., Windows Terminal, VS Code)."
    } catch {
        Write-Error "`nFailed to extract or copy fonts: $(${_}.Exception.Message)"
    } finally {
        # Clean up temporary files
        if (Test-Path $fontZip) { Remove-Item $fontZip -Force -ErrorAction SilentlyContinue }
        if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
    Wait-StarshipScript
}

# Main script execution starts here
Clear-Host

Write-Host "`n------- Automated Starship Installation Script -------"
Wait-StarshipScript

# Check if running as Administrator
$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "`nThis script must be run as Administrator."
    Write-Host "`nTo run as Administrator:"
    Write-Host "  1. Search and Right-click on PowerShell or Windows Terminal and select 'Run as administrator'."
    Write-Host "  2. Then run this script from the elevated terminal using the command:"
    $scriptPath = $MyInvocation.MyCommand.Path
    Write-Host "  powershell -ExecutionPolicy Bypass -File `"$scriptPath`"`n"
    Read-Host "Press Enter to exit..."
    exit 1
}

Install-Starship
Initialize-StarshipConfig
Update-PowerShellProfile
Install-NerdFont

Write-Host "Starship Installation Successful!!!`n`n`n----- SUCCESS -----`n`n"

# If the user selected a Catppuccin preset, remind them to edit the preset line in starship.toml
if ($global:preset1) {
    Write-Host "NOTE: For Catppuccin presets, please open your starship.toml file (located at `$env:APPDATA\starship\starship.toml`) and edit the 31st line to:"
    Write-Host "    preset = '$global:preset1'"
    Write-Host "This ensures the correct Catppuccin flavor is applied.`n"
}

Write-Host "Please restart your terminal or run '. `$PROFILE' to apply changes.`n"
Read-Host "Press Enter to Exit..."
exit 0