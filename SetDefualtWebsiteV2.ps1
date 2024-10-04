 param (
    [Parameter(Mandatory=$true)][string]$global:computer,
    [string]$global:url
    
 )

$arg=$url#convert to allow quotes in the string later

$cimParam = @{
    CimSession  = New-CimSession -ComputerName $global:computer -SessionOption (New-CimSessionOption -Protocol Dcom)
    ClassName = 'Win32_Process'
    MethodName = 'Create'
    Arguments = @{ CommandLine = 'cmd.exe /c winrm quickconfig' }
}

write-host "Computer Name: $Computer" 
write-host "Website: $url"
Invoke-CimMethod @cimParam

write-host "Setting Website"
Invoke-command -ComputerName $computer -ScriptBlock {
	
	Remove-Item 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\*' -Recurse -Include *.lnk
	$shortcut = (New-Object -ComObject Wscript.Shell).CreateShortcut('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\website.lnk')
	$shortcut.TargetPath = 'C:\Program Files\Google\Chrome\Application\chrome.exe' # Executable only
	$shortcut.Arguments = "$using:arg"   # Args to pass to executable.
	#$shortcut.IconLocation = 'C:\Program Files\Google\Chrome\Application\114.0.5735.110\VisualElements\Logo.png'
	$shortcut.Save()
}

Write-host "Done"