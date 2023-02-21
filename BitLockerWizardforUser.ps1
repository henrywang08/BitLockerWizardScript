# This script will check if BitLocker is enabled or not. 
# If not, it will start BitLocker Wizard for the user to complete
# And update registry to state the complete status

$LogFile = "c:\windows\temp\blwizard.log"

Function LogMessage($msg)
{
    $Timestamp = get-date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$Timestamp $msg" 
    "$Timestamp $msg" |     Out-File -FilePath $LogFile -Append 
}

$BLDriveC = Get-BitLockerVolume -MountPoint c:

$Message = "Mountpoint $($BLDriveC.MountPoint) is $($BLDriveC.VolumeStatus)"
LogMessage($Message)

if ($BLDriveC.VolumeStatus -eq "FullyDecrypted")
{
    $Message = "Start BitLocker Wizard"
    LogMessage($Message)
    
    Start-Process -FilePath "c:\windows\system32\BitLockerWizardElev.exe" `
        -ArgumentList "c: S" `
        -Wait
    
    $BLDriveCAgain = Get-BitLockerVolume -MountPoint c:
    
    $Message = "BitLocker Wizard Result: Mountpoint $($BLDriveC.MountPoint) is $($BLDriveC.VolumeStatus)"
     LogMessage($Message)
}

