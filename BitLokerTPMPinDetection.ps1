$BLDriveC = Get-BitLockerVolume c:
If ($BLDriveC.VolumeStatus -ne "FullyDecrypted")
{
    if (($BLDriveC.KeyProtector).keyprotectortype -contains 'TpmPin')
    {
        Write-Host "True"
        exit 0
    }
    else {
        <# Action when all if and elseif conditions are false #>
        exit
    }
}    
else
{
    Write-host "True"
    exit 0
}

