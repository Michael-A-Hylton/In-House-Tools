$computername= read-host "computer name"


psexec  \\$computername Powershell enable-psremoting



Invoke-Command -ComputerName $computername -ScriptBlock {


    Remove-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" -Name "defaultpassword" 
    Remove-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" -Name "defaultusername"
    Set-ItemProperty -path "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" -Name "autoadminlogon" -type String -Value 0


    Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\*.lnk"

    set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name HomepageLocation -PropertyType String -Value "https://google.com"

    shutdown /r /t 0 /f 

       }