param (
    	[Parameter(Mandatory=$true)][string]$global:computername,
	[string]$global:user,
	[string]$global:page,
	[string]$global:password
	
    
)

write-host "DEBUG: powershell computer = $computername"

$arg= '"'+$page+'"'#convert to allow quotes in the string later

$cimParam = @{
    CimSession  = New-CimSession -ComputerName $global:computername -SessionOption (New-CimSessionOption -Protocol Dcom)
    ClassName = 'Win32_Process'
    MethodName = 'Create'
    Arguments = @{ CommandLine = 'cmd.exe /c winrm quickconfig' }
}

Invoke-CimMethod @cimParam 




Write-Host "Mounting remote machine drive as X and copying files"

New-PSDrive -Name X -PSProvider FileSystem -Root "\\$computername\c$" 
New-Item -ItemType Directory -Path x:\temp
Copy-Item '#filepath for vnc*' -Destination 'X:\temp'
Remove-PSDrive -Name X

Write-host "Installing UltraVNC"

$Job = Start-Job -ScriptBlock {
	Invoke-Command -ComputerName $computername  -ScriptBlock {
	
     		
     		Start-Process "C:\temp\UltraVNC_1_4_20_X64_Setup.exe" -Args "/verysilent /NORESTART /loadinf=`"C:\temp\ultravnc.inf`" /MERGETASKS=installdriver" -Wait -NoNewWindow
     		copy-item -Path c:\temp\ultravnc.ini  -Destination "c:\program files\uvnc bvba\ultravnc\ultravnc.ini"
     		Start-Process -filepath "C:\program files\uvnc bvba\ultravnc\mslogonacl.exe" -ArgumentList  "/i /a `"C:\temp\acl.txt`"" -Wait -NoNewWindow
     		Start-Process -filepath "C:\program files\uvnc bvba\ultravnc\winvnc.exe" -ArgumentList "-service"
     		net stop uvnc_service
     		net start uvnc_service

     }
}

$job | wait-job -timeout 30
$job | stop-job

write-host "Configuring autologin" -ForegroundColor Green

Invoke-Command -ComputerName $computername  -ScriptBlock {
write-host $using:user
write-host $using:password


    New-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" -Name 'DefaultPassword' -Value "$using:password" -PropertyType String -Force
    New-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" -Name 'DefaultUsername' -Value "$using:user" -PropertyType String -Force  
    New-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" -Name 'AutoAdminLogon' -Value "1" -PropertyType String -Force 
    

    powercfg.exe -attributes SUB_VIDEO VIDEOCONLOCK -ATTRIB_HIDE
    powercfg.exe /SETDCVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 0

    powercfg.exe -x -monitor-timeout-ac 0
    powercfg.exe -x -monitor-timeout-dc 0
    powercfg.exe -x -disk-timeout-ac 0
    powercfg.exe -x -disk-timeout-dc 0
    powercfg.exe -x -standby-timeout-ac 0
    powercfg.exe -x -standby-timeout-dc 0
    powercfg.exe -x -hibernate-timeout-ac 0
    powercfg.exe -x -hibernate-timeout-dc 0

    powercfg.exe -attributes SUB_VIDEO VIDEOCONLOCK -ATTRIB_HIDE
    powercfg.exe /SETDCVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 0
    }    

  
write-host "Adding groups" -ForegroundColor Green

$group = 'CO-No Screen Saver'
$group3 = 'co-no legal notice'

$group5 = 'CO-No Screen Saver'



try{
$adcomputer=get-ADcomputer -Identity $computername -ErrorAction Stop} catch {Write-Warning "Cannot find name for $computername"
}


try{
$aduser=get-ADuser -Identity $user -ErrorAction Stop} catch {Write-Warning "Cannot find name for $user"
}


try{
$adgroup = Get-ADGroup -Identity $group -ErrorAction Stop} catch {Write-Warning "Cannot find group for $group"
}
try{
$adgroup3 = Get-ADGroup -Identity $group3 -ErrorAction Stop} catch {Write-Warning "Cannot find group for $group3"
}

try{
$adgroup5 = Get-ADGroup -Identity $group5 -ErrorAction Stop} catch {Write-Warning "Cannot find group for $group5"
}


If ($adgroup) {
    Write-Host "Processing $($adgroup.SamAccountName)" -ForegroundColor Green
    Add-ADGroupMember  -Identity $group -Members $adcomputer 
    }



If ($adgroup3) {
    Write-Host "Processing $($adgroup3.SamAccountName)" -ForegroundColor Green
    Add-ADGroupMember  -Identity $group3 -Members $adcomputer
    }
If ($adgroup5) {
    Write-Host "Processing $($adgroup5.SamAccountName)" -ForegroundColor Green
    Add-ADGroupMember  -Identity $group5 -Members $user
    }




write-host "Adding website shortcut" -ForegroundColor Green

Invoke-command -ComputerName $computername -ScriptBlock {
	$shortcut = (New-Object -ComObject Wscript.Shell).CreateShortcut('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\merlin.lnk')
	$shortcut.TargetPath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' # Executable only
	$shortcut.Arguments = "-inprivate --kiosk $using:arg --edge-kiosk-type=fullscreen"   # Args to pass to executable.
	#$shortcut.IconLocation = 'C:\Program Files\Google\Chrome\Application\114.0.5735.110\VisualElements\Logo.png'
	$shortcut.Save()
}



write-host "Done" -ForegroundColor Green
