 param (
    [Parameter(Mandatory=$true)][string]$computername
 )



psexec \\$computername Powershell enable-psremoting



Invoke-Command -ComputerName $computername -ScriptBlock {
	REG ADD “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU” /v UseWUServer /t REG_DWORD /d 0 /f
	REG ADD “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU” /v UseWUServer /t REG_DWORD /d 0 /f
	REG ADD “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU” /v NoAutoUpdate /t REG_DWORD /d 0 /f
	REG ADD “HKEY_USERS\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate” /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
	REG ADD “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate” /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
	REG ADD “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate” /v SetDisableUXWUAccess /t REG_DWORD /d 0 /f
	REG ADD “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate” /v DisableDualScan /t REG_DWORD /d 0 /f
	REG ADD “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate” /v FillEmptyContentUrls /t REG_DWORD /d 0 /f
	REG ADD “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate” /v SetPolicyDrivenUpdateSourceForDriverUpdates /t REG_DWORD /d 0 /f
	REG ADD “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate” /v SetPolicyDrivenUpdateSourceForFeatureUpdates /t REG_DWORD /d 0 /f
	REG ADD “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate” /v SetPolicyDrivenUpdateSourceForOtherUpdates /t REG_DWORD /d 0 /f
	REG ADD “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate” /v SetPolicyDrivenUpdateSourceForQualityUpdates /t REG_DWORD /d 0 /f
	REG ADD “HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing” /v RepairContentServerSource /t REG_DWORD /d 2 /f
	REG ADD “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU” /v WUServer /t REG_DWORD /d 0 /f


	reg delete “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate” /v  WUServer /f 
	reg delete “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate” /v  WUStatusServer /f 
	reg delete “HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate” /v  UpdateServiceUrlAlternate /f 


	net stop “Windows Update”
	net start “Windows Update”

}