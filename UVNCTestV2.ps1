param (
	[Parameter(Mandatory=$true)][string]$global:computername


)



Write-Host "Mounting remote machine drive as X and copying files"

New-PSDrive -Name X -PSProvider FileSystem -Root "\\$computername\c$" 
New-Item -ItemType Directory -Path x:\temp -erroraction silentlycontinue
Copy-Item '#filepath for VNC' -Destination 'X:\temp'
Remove-PSDrive -Name X

Write-host "Installing UltraVNC"


	Invoke-Command -ComputerName $computername  -ScriptBlock {
	
     		
     		net stop uvnc_service
     		Start-Process "C:\temp\UltraVNC_1_4_20_X64_Setup.exe" -Args "/verysilent /NORESTART /loadinf=`"C:\temp\ultravnc.inf`" /MERGETASKS=installdriver" -Wait -NoNewWindow
     		copy-item -Path c:\temp\ultravnc.ini  -Destination "c:\program files\uvnc bvba\ultravnc\ultravnc.ini"
     		Start-Process -filepath "C:\program files\uvnc bvba\ultravnc\mslogonacl.exe" -ArgumentList  "/i /a `"C:\temp\acl.txt`"" -Wait -NoNewWindow
     		Start-Process -filepath "C:\program files\uvnc bvba\ultravnc\winvnc.exe" -ArgumentList "-service"
     		net stop uvnc_service
     		net start uvnc_service
     }


Write-Host "Completed"