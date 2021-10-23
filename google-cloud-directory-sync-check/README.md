# Google Cloud Directory Sync Check
Formerly **Google Active Directory Sync** / **GADS** (now **Google Cloud Directory Sync** or **GCDS**); this script checks for a lock file, which will be present in a situation where GADS / Google Cloud Directory Sync fails to sync successfully.  If found, send a notification.

## Setup
Initial config is at the top of the script, change to suit your environment:
```powershell
$SMTPServer = "mailserver.example.com"
$SMTPPort   = "25"
$From       = "gads@example.com"
$To         = "admin@example.com"
$AlertText  = 'Lock File Located'
$Body       = 'A lock file was found that may prevent GADS from syncing on next run; attention required.'
```

Also set your installation path for GADS / GCDS, where the logs are located:
```powershell
# attach log messages
$LogPath      = "C:\gads_path\*.log"
```

Preferred path for building the logs that will be attached to the email notification (the directory should be manually created; the log files with auto-create):
```powershell
# will be auto-created and purged, as necessary; nothing else should be in it
$LogsToAttach = "C:\Scripts\log-attachments\"
```

If you choose a different log-attachments path, also modify this line:
```powershell
# last 100 lines of the requested log + pipe to a tmp txt file
Get-Content -Path $LatestLog -Tail 100 | Out-File -FilePath C:\Scripts\log-attachments\gads-log.txt
```

## Usage
Put this script on the same server where your GADS / GCDS installation runs.  Setup a task to run it on schedule, shortly after your sync runs.
