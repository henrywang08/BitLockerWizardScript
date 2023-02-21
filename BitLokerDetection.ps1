$LogFile = "c:\windows\temp\bldetect.log"

Function LogMessage($msg)
{
    $Timestamp = get-date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$Timestamp $msg" 
    "$Timestamp $msg" |     Out-File -Append -FilePath $LogFile 
}

$Message = "Start bitlocker detection on C: drive"
LogMessage($Message)

$BLDriveC = Get-BitLockerVolume c:

   $Message = "Mountpoint $($BLDriveC.MountPoint) is $($BLDriveC.VolumeStatus)"
    LogMessage($Message)


If ($BLDriveC.VolumeStatus -eq "FullyDecrypted")
{
   
   $Message = "Bitlocker not enabled on C:!"
    LogMessage($Message)

   #  Write-Host "False"
    return 1
}
else
{
   $Message = "Bitlocker enabled on C:"
    LogMessage($Message)

    Write-host "True"
    return 0
}

