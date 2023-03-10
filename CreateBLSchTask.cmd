md c:\programdata\tools 
copy *.* c:\programdata\tools
schtasks /create /ru "NT AUTHORITY\SYSTEM" /sc onlogon /tn "BitLocker on Logon" /tr c:\programdata\tools\BLSchTask.cmd
