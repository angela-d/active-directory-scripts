# what folder/files to check for
$FileCheck = "C:\gads_path\syncState\*.lock"

# alert subject & email settings
$SMTPServer = "mailserver.example.com"
$SMTPPort   = "25"
$From       = "gads@example.com"
$To         = "admin@example.com"
$AlertText  = 'Lock File Located'
$Body       = 'A lock file was found that may prevent GADS from syncing on next run; attention required.'

# attach log messages
$LogPath      = "C:\gads_path\*.log"
# will be auto-created and purged, as necessary; nothing else should be in it
$LogsToAttach = "C:\Scripts\log-attachments\"

# we want to check back 30 min ago.. setup date stuff
$Threshold = (Get-Date).AddMinutes(-30)
$TimeNow   = Get-Date

# confirm it exists, first
$wildcard = Test-Path -PathType Leaf -Path "$FileCheck"

if ($wildcard) {

  # make sure the lock file is at least over 30 min old, else ignore
  $WriteTime     = gci $fileCheck
  $FileTime      = [DateTime] $WriteTime.LastWriteTime
  $TimeNow       = Get-Date
  $TimeLastWrote = ($TimeNow - $FileTime).TotalMinutes

  if ($TimeLastWrote -ge 30) {

  	# get the latest log, only
  	$LatestLog = Get-ChildItem $LogPath | Sort {$_.LastWriteTime} | select -last 1

  	# create the temp folder for the logs
  	if (!(Test-Path $LogsToAttach)) {
  		New-Item $LogsToAttach -ItemType Directory
  	}

  	# last 100 lines of the requested log + pipe to a tmp txt file
  	Get-Content -Path $LatestLog -Tail 100 | Out-File -FilePath C:\Scripts\log-attachments\gads-log.txt

    # notify someone the files were located
    Write-Host $AlertText
    $ListMatches = $(ls $FileCheck)

    # send an email
	forEach($sendTo in $To) {
		$LogPath = (dir $LogsToAttach*.txt).FullName
		$Subject = "$env:computername $AlertText"
		$Body += "`nFilename: $ListMatches"
		Send-MailMessage -Attachments $LogPath -From $From -to ($To -split ',') -Subject "$Subject $ListMatches" -Body $Body -SmtpServer $SMTPServer -port $SMTPPort
	}

	# cleanup the logs that were attached to the email
	Remove-Item $LogsToAttach -Recurse
  }

} else {

  Write-Host "Everything is good - no match!"

}
