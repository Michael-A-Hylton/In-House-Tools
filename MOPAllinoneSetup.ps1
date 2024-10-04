param(
	[Parameter(Mandatory=$true)][string]$computername,
	[Parameter(Mandatory=$true)][string]$user,
	[Parameter(Mandatory=$true)][string]$password

)

psexec \\$computername Powershell enable-psremoting



    Invoke-Command -ComputerName $computername -ScriptBlock {

    #Set autologin user

        New-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" -Name 'DefaultPassword' -Value "$using:password" -PropertyType String -Force
        New-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" -Name 'DefaultUsername' -Value "$using:user" -PropertyType String -Force 
        New-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" -Name 'AutoAdminLogon' -Value "1" -PropertyType String -Force 
    
    #set power options

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

    #set chrome homepage

        #paths for chrome policy keys used in the scripts
        $policyexists = Test-Path HKLM:\SOFTWARE\Policies\Google\Chrome
        $policyexistshome = Test-Path HKLM:\SOFTWARE\Policies\Google\Chrome\RestoreOnStartupURLs
        $regKeysetup = "HKLM:\SOFTWARE\Policies\Google\Chrome"
        $regKeyhome = "HKLM:\SOFTWARE\Policies\Google\Chrome\RestoreOnStartupURLs"
        $url = "https://eheijunka.protools.local/new/"

        #setup policy dirs in registry if needed and set pwd manager
        #else sets them to the correct values if they exist
        if ($policyexists -eq $false){
        New-Item -path HKLM:\SOFTWARE\Policies\Google
        New-Item -path HKLM:\SOFTWARE\Policies\Google\Chrome
        New-ItemProperty -path $regKeysetup -Name PasswordManagerEnabled -PropertyType DWord -Value 0
        New-ItemProperty -path $regKeysetup -Name RestoreOnStartup -PropertyType Dword -Value 4
        New-ItemProperty -path $regKeysetup -Name HomepageLocation -PropertyType String -Value $url
        New-ItemProperty -path $regKeysetup -Name HomepageIsNewTabPage -PropertyType DWord -Value 0
        }

        Else {
        Set-ItemProperty -Path $regKeysetup -Name PasswordManagerEnabled -Value 0
        Set-ItemProperty -Path $regKeysetup -Name RestoreOnStartup -Value 4
        Set-ItemProperty -Path $regKeysetup -Name HomepageLocation -Value $url
        Set-ItemProperty -Path $regKeysetup -Name HomepageIsNewTabPage -Value 0
        }

        #This entry requires a subfolder in the registry
        #For more then one page create another new-item and set-item line with the name -2 and the new url
        if ($policyexistshome -eq $false){
        New-Item -path HKLM:\SOFTWARE\Policies\Google\Chrome\RestoreOnStartupURLs
        New-ItemProperty -path $regKeyhome -Name 1 -PropertyType String -Value $url
        }
        Else {
        Set-ItemProperty -Path $regKeyhome -Name 1 -Value $url
        }
       

    #Add To Trusted sites

        #Setting IExplorer settings
        Write-Verbose "Now configuring IE"
        $policyexists = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"

        if ($policyexists -eq $false){
        New-Item -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"
        set-location "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"
        new-item *.protools.local
        set-location *.protools.local
        new-itemproperty . -Name * -Value 1 -Type DWORD -Force
        Write-Host "Site added Successfully"
        }
        
        Else {
                set-location "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"
        new-item *.protools.local
        set-location *.protools.local
        new-itemproperty . -Name * -Value 1 -Type DWORD -Force
        Write-Host "Site added Successfully"
        }

       }

# Add to AD groups

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
    Add-ADGroupMember -Identity $group3 -Members $adcomputer
    }
If ($adgroup5) {
    Write-Host "Processing $($adgroup5.SamAccountName)" -ForegroundColor Green
    Add-ADGroupMember -Identity $group5 -Members $user
    }

#install VNC

Write-Host "Mounting remote machine drive as X and copying files"

New-PSDrive -Name X -PSProvider FileSystem -Root "\\$computername\c$" 
New-Item -ItemType Directory -Path x:\temp
Copy-Item '#filepath for vnc*' -Destination 'X:\temp'
Remove-PSDrive -Name X

Write host "Installing UltraVNC"

 Invoke-Command -ComputerName $computername -ScriptBlock {

     Start-Process "C:\temp\UltraVNC_1_4_20_X64_Setup.exe" -Args "/verysilent /NORESTART /loadinf=`"C:\temp\ultravnc.inf`" /MERGETASKS=installdriver" -Wait -NoNewWindow
     copy-item -Path c:\temp\ultravnc.ini  -Destination "c:\program files\uvnc bvba\ultravnc\ultravnc.ini"
     Start-Process -filepath "C:\program files\uvnc bvba\ultravnc\mslogonacl.exe" -ArgumentList  "/i /a `"C:\temp\acl.txt`"" -Wait -NoNewWindow
     Start-Process -filepath "C:\program files\uvnc bvba\ultravnc\winvnc.exe" -ArgumentList "-service"
     net stop uvnc_service
     net start uvnc_service

     }

write-host "Done"
pause