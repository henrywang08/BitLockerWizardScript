$BLDriveC = Get-BitLockerVolume c:
If ($BLDriveC.VolumeStatus -eq "FullyDecrypted")
{
   #  Write-Host "False"
    return 1
}
else
{
    Write-host "True"
    return 0
}

