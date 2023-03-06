# This script will check if BitLocker is enabled or not. 
# If not, it will start BitLocker Wizard for the user to complete
# And update registry to state the complete status

<# 20230306 - 

1. If BitLocker TPM+Pin is there, no further action
2. If BitLocker TPM is there, show UI to ask end-user to setup TPM Pin
3. If there is no TPM but TPM is enabled with password, no further action
4. If BitLocker is not enabled, show UI to enable BitLocker (it should cover TPM and non-TPM scenario)
If there is any data drive not enabled with bitlocker, enable them and set auto-unlock

#>

$LogFile = "c:\windows\temp\bldetect.log"

# ServiceUI.exe and the script needs to be copied into the folder
$ServiceUIPath = "c:\ProgramData\tools\"
$StartBitLockerBatchFile = "StartBL.cmd"
$SetTPMPinBatchFile = "SetPin.cmd"

Function LogMessage($msg)
{
    $Timestamp = get-date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$Timestamp $msg" 
    "$Timestamp $msg" |     Out-File -Append -FilePath $LogFile 
}

Function BitLockerOnDataDisk()
{
    $DataBLDrives = Get-BitLockerVolume | Where-Object VolumeType -ne 'OperatingSystem'
    if (($DataBLDrives.count) -gt 0 ){
        foreach ($DataDrive in $DataBLDrives) {
            if ($DataDrive.VolumeStatus -eq "FullyDecrypted")
            {
             # Need to understand the current bitlocker policy for Data disk
             # Since newly added data disk are not automatically encrypted

             $Message = "Mountpoint $($DataDrive.MountPoint) is $($DataDrive.VolumeStatus)"
             LogMessage($Message)
             #   Enable-BitLocker -MountPoint $($DataDrive.MountPoint) 
             #   Enable-BitLockerAutoUnlock -MountPoint $($DataDrive.MountPoint) 
            }
        }
        
  
    } 
 }

$BLDriveC = Get-BitLockerVolume | Where-Object VolumeType -eq 'OperatingSystem'

$Message = "Mountpoint $($BLDriveC.MountPoint) is $($BLDriveC.VolumeStatus)"
LogMessage($Message)



If ($BLDriveC.VolumeStatus -ne "FullyDecrypted")
{

##
# 1. If BitLocker TPM+Pin is there, no further action
##

    if (($BLDriveC.KeyProtector).keyprotectortype -contains 'TpmPin')
    {
        $Message = "TpmPin already configured."
        LogMessage($Message)
        BitLockerOnDataDisk
        exit 0
    }
    else {

##
# 2. If BitLocker TPM is there, show UI to ask end-user to setup TPM Pin
##
        if (($BLDriveC.KeyProtector).keyprotectortype -contains 'Tpm')
        {
            $Message = "Bitlocker with Tpm. Need to setup TPMPin"
            LogMessage($Message)
            
            Start-Process -FilePath $ServiceUIPath+$SetTPMPinBatchFile `
                    -Wait
        
            $BLDriveCAgain = Get-BitLockerVolume -MountPoint c:
        
            $Message = "BitLocker Wizard Result: Mountpoint $($BLDriveCAgain.MountPoint) is $($BLDriveCAgain.VolumeStatus)"
            LogMessage($Message)
            BitLockerOnDataDisk
            exit 0
        }
        else {

##
# 3. If there is no TPM but TPM is enabled with password, no further action
##          

            if (($BLDriveC.KeyProtector).keyprotectortype -contains 'Password')
            {
                $Message = "BitLocker enabled with startup Password. The device may not have a compatible TPM chip."
                LogMessage($Message)
                BitLockerOnDataDisk
                exit 0
            }

        }
          
    }



}    




## 
# 4. If BitLocker is not enabled, show UI to enable BitLocker (it should cover TPM and non-TPM scenario)
##

if ($BLDriveC.VolumeStatus -eq "FullyDecrypted")
{
    $Message = "Start BitLocker Wizard"
    LogMessage($Message)
    
    Start-Process -FilePath $ServiceUIPath+$StartBitLockerBatchFile `
        -Wait
    
    $BLDriveCAgain = Get-BitLockerVolume -MountPoint c:
    
    $Message = "BitLocker Wizard Result: Mountpoint $($BLDriveC.MountPoint) is $($BLDriveC.VolumeStatus)"
    LogMessage($Message)

    BitLockerOnDataDisk
}

