# LANjoiner is a Windows PowerShell script made by Franz "OokamiKunTV" to ease the process of setting up and play custom Rocket League
# maps and gamemodes with other people from my community.
#
# This script has the capabilities of installing the following software:
# ZeroTier One, a Virtual Local Area Network (VLAN) tool, similar to Hamachi
# BakkesMod, a must-have modding platform for Rocket League
# Custom Map Loader, a tool for loading custom maps into Rocket League (replaces the "Underpass" map)
#
# Additionally, this script can also install several additional components, such as "RocketPlugin",
# which is a BakkesMod plugin that enables multiplayer functionality on custom maps.
# It may also install other optional components, such as nice-to-have BakkesMod plugins and custom maps.
#
# --- DISCLAIMER ---
# Many are sceptical of running scripts on their computers (for good reason), but this script contains no malicius code.
# However, if you'd like to look into how this script works, you are free to do so, I've commented most of the script.
# With that said, there may be the occational bug or unintended behaviour, so this script is provided with no guarantee,
# and you execute this script at your own risk. 
# I encourage everyone using my script to report any bugs, errors, etc to me on Discord!
# You can create a thread in the Discord Channel "#community-dev" (https://discord.com/channels/896713616089309184/1037449432079290368)
#
# ------------------- IMPORTANT IF YOU SEE THIS WHEN YOU TRY TO RUN THE SCRIPT --------------------
# | Windows will, usually, by default open PowerShell scripts in an editor instead of running it. |
# |       If this is the case, right-click on the script, and press "Run with PowerShell"         |
# -------------------------------------------------------------------------------------------------

$version = "0.1.2"
$versiondate = "23.06.30"
$versionfull = "$version-$versiondate" # M.P.B-YY.MM.DD (Major.Patch.Bugfix-Year.Month.Day)
$repositoryUrl = "https://github.com/FreemoX/OokamiKunTV-LANjoiner" # GitHub repository URL
$repositoryApiUrl = "https://api.github.com/repos/FreemoX/OokamiKunTV-LANjoiner"

$projectfolder = "$([Environment]::GetFolderPath("Personal"))\LANjoiner"
$zerotierurl = "https://download.zerotier.com/dist/ZeroTier%20One.msi"
$bakkesmodurl = "https://github.com/bakkesmodorg/BakkesModInjectorCpp/releases/latest/download/BakkesModSetup.zip"
$custommaploaderurl = "https://github.com/NoxPhoenix/custom-map-loader/releases/latest/download/MapLoaderInstall.exe"
$kamizerotiernetworkid = "93afae59634aaa8c"
$ztnetworkpath = "C:\ProgramData\ZeroTier\One\networks.d"
$ztnetworkfilename = "$kamizerotiernetworkid.conf"
$ztnetworkfilepath = Join-Path -Path $ztnetworkpath -ChildPath $ztnetworkfilename
# ZeroTier One Network Path: C:\ProgramData\ZeroTier\One\networks.d

# Menu section
function Show-Menu {
    Clear-Host
    Write-Host "LANjoiner v$version by OokamiKunTV"
	Write-Host ""
	Write-Host "Project Folder: '$projectfolder'"
	Write-Host "Folder Setup Complete: $(Test-Path $projectfolder)"
	Write-Host ""
    Write-Host "Please select an option:"
    Write-Host "Q. Exit script"
    Write-Host "0. About this script"
    Write-Host "1. Full Setup"
    # Write-Host "2. Partial Setup"
	# Write-Host "3. Repair Setup"
	# Write-Host "T. Test Function"
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        "Q" { # Exit the script
            Exit
        }
        "0" { # Display the "About" text
            About
        }
        "1" { # Perform a full setup
            SetupFull
        }
		"2" { # Perform a partial setup
            SetupPartial
        }
		"3" { # Perform repair/update actions
            SetupRepair
        }
		"T" { # Test option
			$software = Read-Host "Software to check"
			Checkinstalled($software)
			#cls
			#DownloadSoftware
			#GetZeroTierID
			Start-Sleep 10
			Show-Menu
		}
        default { # In case of invalid input
            Write-Host "Invalid choice. Please try again."
            Start-Sleep 2
            Show-Menu
        }
    }
}

# Download and extract provided software
function DownloadSoftware($software) {
	cls
	switch ($software) {
		"ZeroTier" { # Download the ZeroTier One Client
			Write-Host "Downloading '$software', please wait ..."
			Invoke-WebRequest -Uri $zerotierurl -OutFile "$projectfolder/ZeroTierInstaller.msi"
			Write-Host "Downloaded ZeroTier one: $(Test-Path -Path "$projectfolder/ZeroTierInstaller.msi" -PathType Leaf)"
		}
		"BakkesMod" { # Download and Extract BakkesMod
			Write-Host "Downloading and extracting '$software', please wait ..."
			Invoke-WebRequest -Uri $bakkesmodurl -OutFile "$projectfolder/BakkesModSetup.zip"
			Start-Sleep 1
			Expand-Archive -Path "$projectfolder/BakkesModSetup.zip" -DestinationPath "$projectfolder/BakkesModSetup"
			
			Write-Host "Downloaded BakkesMod: $(Test-Path -Path "$projectfolder/BakkesModSetup.zip" -PathType Leaf)"
			Write-Host " Extracted BakkesMod: $(Test-Path -Path "$projectfolder/BakkesModSetup/BakkesModSetup.exe" -PathType Leaf)"
		}
		"CustomMapLoader" { # Download the Custom Map Loader Program
			Write-Host "Downloading '$software', please wait (it's a little large)..."
			Invoke-WebRequest -Uri $custommaploaderurl -OutFile "$projectfolder/CustomMapLoaderInstall.exe"
			Write-Host "Downloaded CustomMapLoader: $(Test-Path -Path "$projectfolder/CustomMapLoaderInstall.exe" -PathType Leaf)"
		}
		default {
            Write-Host "Invalid choice. Please try again."
            Start-Sleep 2
            DownloadSoftware
        }
	}
}

# Install provided software
function InstallSoftware($software) {
	cls
	Write-Host "Installing '$software'..."
	switch ($software) {
		"ZeroTier" { # Install the ZeroTier One Client
			CheckInstalled("ZeroTier")
			if ($softwareisinstalled -eq 1) {
				Write-Host "The ZeroTier One Client is already installed."
				$reply = Read-Host "Do you wish to repair/update it? (Y|n)"
				switch ($reply) {
					"n" {
						Write-Host "OK, skipping ZeroTier One setup"
					}
					default {
						Write-Host "OK, running ZeroTier One Setup"
						Start-Process -FilePath "ZeroTierInstaller.msi"
					}
				}
			} elseif ($softwareisinstalled -eq 0) {
				Write-Host "ZeroTier One is not installed, running setup ..."
				Start-Process -FilePath "ZeroTierInstaller.msi"
			} else {
				Write-Host "[ERROR] - Unable to determine ZeroTier status!"
				Write-Host "This is usually caused by a lookup error,"
				Write-Host "and proceeding is usually safe anyway."
				$reply = Read-Host "Do you wish to run the installer? (Y|n)"
				switch ($reply) {
					"n" {
						Write-Host "OK, skipping ZeroTier One setup"
					}
					default {
						Write-Host "OK, running ZeroTier One Setup"
						Start-Process -FilePath "ZeroTierInstaller.msi"
					}
				}
			}
			if (Test-Path -Path $ztnetworkpath -PathType Container) {
				Write-Host "The folder $ztnetworkpath exists."

				if (-not (Test-Path -Path $ztnetworkfilename -PathType Leaf)) {
					New-Item -Path $ztnetworkfilename -ItemType File -Force
					Write-Host "Successfully configured ZeroTier Network"
				} else {
					Write-Host "Skipping network configuration, already exist"
				}
			} else {
				Write-Host "ZeroTier Network Configuration folder is missing!"
				Write-Host "This is likely due to the installation folder being"
				Write-Host "non-standard. It's safe to proceed, but manual"
				Write-Host "configuration will be required."
			}
			CheckInstalled("ZeroTier")
			if ($softwareisinstalled -eq 1) { # If ZeroTier One was successfully installed and registered
				Write-Host "ZeroTier has been successfully installed!"
				Write-Host "If you don't see ZeroTier in the system tray,"
				Write-Host "you can run it manually by running the"
				Write-Host "'ZeroTier' app. Then find ZeroTier in the"
				Write-Host "system tray, right-click it, and copy the"
				Write-Host "'Node-ID'/'My Address' by clicking it, and"
				Write-Host "send it to OokamiKunTV to be accepted into"
				Write-Host "the VLAN. (it's your ZeroTier ID, used to"
				Write-Host "verify the connection owner)"
			} else { # In case of unsuccessful installation/registration of ZeroTier One
				Write-Host "Unable to verify if ZeroTier was installed!"
				Write-Host "You can try to run it manually by running the"
				Write-Host "'ZeroTier' app. Then find ZeroTier in the"
				Write-Host "system tray, right-click it, and copy the"
				Write-Host "'Node-ID'/'My Address' by clicking it, and"
				Write-Host "send it to OokamiKunTV to be accepted into"
				Write-Host "the VLAN. (it's your ZeroTier ID, used to"
				Write-Host "verify the connection owner)"
				Write-Host ""
				Write-Host "If you still face any issues, please"
				Write-Host "reach out to me on Discord"
			}
		}
		"BakkesMod" { # Install BakkesMod
			CheckInstalled("BakkesMod")
			if ($softwareisinstalled -eq 1) {
				Write-Host "BakkesMod is already installed."
				$reply = Read-Host "Do you wish to repair/update it? (Y|n)"
				switch ($reply) {
					"n" {
						Write-Host "OK, skipping BakkesMod setup"
					}
					default {
						Write-Host "OK, running BakkesMod Setup"
						Start-Process -FilePath "BakkesModSetup/BakkesModSetup.exe"
					}
				}
			} elseif ($softwareisinstalled -eq 0) {
				Write-Host "BakkesMod is not installed, running setup ..."
				Start-Process -FilePath "BakkesModSetup/BakkesModSetup.exe"
			} else {
				Write-Host "[ERROR] - Unable to determine BakkesMod status!"
				Write-Host "This is usually caused by a lookup error,"
				Write-Host "and proceeding is usually safe anyway."
				$reply = Read-Host "Do you wish to run the installer? (Y|n)"
				switch ($reply) {
					"n" {
						Write-Host "OK, skipping BakkesMod setup"
					}
					default {
						Write-Host "OK, running BakkesMod Setup"
						Start-Process -FilePath "BakkesModSetup/BakkesModSetup.exe"
					}
				}
			}
			InstallBMPlugins # Install required BakkesMod Plugins
		}
		"CustomMapLoader" { # Install the Custom Map Loader Program
			CheckInstalled("CustomMapLoader")
			if ($softwareisinstalled -eq 1) {
				Write-Host "CustomMapLoader is already installed."
				$reply = Read-Host "Do you wish to repair/update it? (Y|n)"
				switch ($reply) {
					"n" {
						Write-Host "OK, skipping CustomMapLoader setup"
					}
					default {
						Write-Host "OK, running CustomMapLoader Setup"
						Start-Process -FilePath "CustomMapLoaderInstall.exe"
					}
				}
			} elseif ($softwareisinstalled -eq 0) {
				Write-Host "CustomMapLoader is not installed, running setup ..."
				Start-Process -FilePath "CustomMapLoaderInstall.exe"
			} else {
				Write-Host "[ERROR] - Unable to determine CustomMapLoader status!"
				Write-Host "This is usually caused by a lookup error,"
				Write-Host "and proceeding is usually safe anyway."
				$reply = Read-Host "Do you wish to run the installer? (Y|n)"
				switch ($reply) {
					"n" {
						Write-Host "OK, skipping CustomMapLoader setup"
					}
					default {
						Write-Host "OK, running CustomMapLoader Setup"
						Start-Process -FilePath "CustomMapLoaderInstall.exe"
					}
				}
			}
		}
		default {
            Write-Host "Invalid choice. Please try again."
            Start-Sleep 2
            # InstallSoftware
        }
	}
}

function SetupFull { # Full setup, installs everything needed
    Write-Host "You have selected Full Setup"
    Start-Sleep -Seconds 2
	DownloadSoftware("ZeroTier")
	InstallSoftware("ZeroTier")
	DownloadSoftware("BakkesMod")
	InstallSoftware("BakkesMod")
	DownloadSoftware("CustomMapLoader")
	InstallSoftware("CustomMapLoader")
}

function SetupPartial { # Partial setup, installs specified parts only
    Write-Host "You have selected Partial Setup"
    # Further processing for Option 2 goes here...
    # You can replace this with your desired actions
    Start-Sleep -Seconds 2
    Show-Menu
}

function SetupRepair { # Repair setup. Will re-install/update/repair the setup
    Write-Host "You have selected Repair Setup"
    # Further processing for Option 2 goes here...
    # You can replace this with your desired actions
    Start-Sleep -Seconds 2
    Show-Menu
}

function InstallBMPlugins {
	# Install Rocket Plugin for MP capabilities
	Write-Host Installing BM Plugin: RocketPlugin
	Start-Process "bakkesmod://install/26"
}

# Checks if provided software is installed
function CheckInstalled($software) {
	
	switch ($software) {
		"zerotier" { # If ZeroTier is selected
			$softwaredisplay = "ZeroTier One"
		}
		"bakkesmod" {
			$softwaredisplay = "BakkesMod version"
		}
		"custommaploader" {
			$softwaredisplay = "Custom Map Loader"
		}
	}
	$installedCU = (Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall" | find "$softwaredisplay")
	$installedLM = (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" | find "$softwaredisplay")

	If (-Not $installedCU -And -Not $installedLM) {
		Write-Host "'$software' is not installed.";
		$softwareisinstalled = 0
	} else {
		Write-Host "'$software' is installed."
		$softwareisinstalled = 1
	}

	Start-Sleep -Seconds 5
}

# Initial script setup
function InitialSetup {
	# Retrieve the releases information from the GitHub API
	$releases = Invoke-RestMethod -Uri "$repositoryApiUrl/releases"
	$latestRelease = $releases[0].tag_name

	# Extract the latest version and release date from the release information
	$latestVersion = $latestRelease -replace '^[Vv]| pre-release$'

	# Compare the current version with the latest version
	if ($latestVersion -gt $version) {
		$latestVersionURL = "$repositoryUrl/releases/download/v$latestVersion/LANjoiner-v$latestVersion.ps1"
		Write-Host "A newer version is available: $latestVersion"
		Write-Host "You currently have version: $version"
		Write-Host "Performing automatic update. This script will"
		Write-Host "re-start when the update is finished ..."
		Start-Sleep 2

		# Download the latest version from Github
		Invoke-WebRequest -Uri $latestVersionURL -OutFile "LANjoiner-v$latestVersion.ps1"
		Write-Host "Update completed."
		Start-Sleep 2
		Write-Host "Please run the new version of the script"
		Write-Host "Don't forget to delete the old version"
		Read-Host "Press ENTER to close LANjoiner"
		exit
	} elseif ($version -gt $latestVersion) {
		Write-Host "Uhm... You somehow have a newer version than the latest release ..."
		Write-Host "Unless you're OokamiKunTV, I'm not sure how unless you manually"
		Write-Host "changed the script version yourself, which you SHOULD NOT DO!"
		Write-Host ""
		Write-Host "Current version: v$version"
		Write-Host "Latest version:  v$latestVersion"
		Write-Host ""
		Write-Host "Q.  Exit LANjoiner"
		Write-Host "F.  Force update to v$latestVersion"
		Write-Host "P.  Proceed without updating (default)"
		$reply = Read-Host "How would you like to proceed?"
		switch ($reply) {
			"Q" {
				Write-Host "OK, exiting LANjoiner"
				Start-Sleep 2
				exit
			}
			"F" {
				Write-Host "OK, force-updating to version v$latestVersion"
				Start-Sleep 2
				Invoke-WebRequest -Uri $latestVersionURL -OutFile "LANjoiner-v$latestVersion.ps1"
				Write-Host "Update completed."
				Start-Sleep 2
				Write-Host "Please run the new version of the script"
				Write-Host "Don't forget to delete the old version"
				Read-Host "Press ENTER to close LANjoiner"
				exit
			}
			default {
				Write-Host "OK, proceeding without updating"
				Start-Sleep 2
			}
		}
	} elseif ($latestVersion -eq $version) {
		Write-Host "You have the latest version: $version"
	} else {
		Write-Host "An error occured while looking up the lastest version!"
		Read-Host "Anyway, press ENTER to continue, or 'CTRL+C' to exit the script"
	}
	Start-Sleep 2
	
	# Check if project folder exists, and create it if it doesn't
	if (Test-Path $projectfolder) {
		Remove-Item $projectfolder -Recurse -Force
	}
	$projectfolder = New-Item -Path "$([Environment]::GetFolderPath("Personal"))" -Name "LANjoiner" -ItemType "directory"
	
	# Assign the project folder as working directory
	cd $projectfolder
}

function GetZeroTierID {
	$zerotierinfo = "$(zerotier-cli info)"
	$zerotierinfoarray = $($zerotierinfo -Split " ")
	$zerotierID = $zerotierinfoarray[2]
	Write-Host "ZeroTier One Info: $zerotierinfo"
	Write-Host "ZeroTier One ID: $zerotierID"
}

# About section
function About {
    Clear-Host
    Write-Host "LANjoiner v$versionfull by OokamiKunTV"
    Write-Host ""
    Write-Host "This script is for the lazy people out there"
    Write-Host "who'd like to join our custom Rocket League games."
    Write-Host ""
    Write-Host "This is a tool to semi-automate the process of"
    Write-Host "configuring your computer to join our VLAN,"
    Write-Host "installing required components, and getting you"
    Write-Host "ready to play custom maps, modes, and more"
    Write-Host "with the rest of the community on-stream."
    Write-Host ""
    Write-Host "You can choose a Full Setup if you are starting"
    Write-Host "from scratch, or you can perform singular actions"
    Write-Host "e.g., only joining the network."
    Write-Host ""
    Write-Host "Feel free to ask in our discord if you have questions."
    Write-Host "Invite link:    https://ookamikun.tv/discord"
	Write-Host "QR code invite: https://ookamikun.tv/discord-qr"
	Write-Host "PS: Hold CTRL while clicking to open links"
    Write-Host ""
    Read-Host "Press ENTER to return to the menu"
    Show-Menu
}

InitialSetup
Show-Menu
Read-Host "Press ENTER to exit close LANjoiner"
