param(
	[Parameter(Mandatory=$true)][string]$global:computername,
	[string]$global:user,
	[string]$global:password

)

psexec \\$computername Powershell enable-psremoting

write-host " Moving Files"

New-PSDrive -Name X -PSProvider FileSystem -Root "\\$computername\c$" 
New-Item -ItemType Directory -Path x:\temp
Copy-Item '#autologin path' -Destination 'X:\temp'
Remove-PSDrive -Name X

Invoke-Command -ComputerName $computername -ScriptBlock {
write-host "Starting Autologon process"


Start-Process -FilePath  "c:\temp\autologon.exe" -ArgumentList "/accepteula", $using:user, "EMRSN", $using:password -Wait
    
    write-host "Starting Power Config"

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
    powercfg.exe -x -monitor-timeout-ac 0
    powercfg.exe -x -monitor-timeout-dc 0
    powercfg.exe -x -disk-timeout-ac 0
    powercfg.exe -x -disk-timeout-dc 0
    powercfg.exe -x -standby-timeout-ac 0
    powercfg.exe -x -standby-timeout-dc 0
    powercfg.exe -x -hibernate-timeout-ac 0
    powercfg.exe -x -hibernate-timeout-dc 0
    }    

  

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


write-host "COMPLETE"