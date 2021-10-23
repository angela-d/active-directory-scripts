# CONFIG
	# To should be a single address
	$To = "me@example.com"
	# enter any additional recipients, separated by a comma
	$From = "admins@example.com"
	$SMTPServer = "mailserver.example.com"
	$SMTPPort = "25"
# END CONFIG

# filter ou's we don't want
# logon dates will be inaccurate, as this script is only polling dcX and lastLogon doesn't replicate
$checkAccounts = (Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 15 |
	?{($_.DistinguishedName -notmatch "OU=Retired,OU=People") -and
	($_.DistinguishedName -notmatch "OU=Deleted,OU=People") -and
	($_.DistinguishedName -notmatch "OU=Utility_Accounts") -and
	($_.DistinguishedName -notlike "CN=*Wifi*") -and
	($_.DistinguishedName -notlike "CN=Printer*") -and
	($_.DistinguishedName -notmatch "CN=IT-Test")} |
	?{$_.enabled -eq $True}  |
	Get-ADUser -Properties Name, EmailAddress, Description, whenCreated, lastLogon, lastLogonTimestamp |
	Where-Object { $_.whenCreated -lt (Get-Date).AddDays(-10) })

# get a count of records, so empty emails don't get sent
$totalAccounts = [int]$checkAccounts.Count
$subject = "$totalAccounts inactive accounts currently enabled"

# send an email if there's more than 1 record
if ($totalAccounts -gt 0) {
  # display for the terminal
  $Body = $checkAccounts | Format-List Name, UserPrincipalName, Description, DistinguishedName, @{Name="lastLogon";Expression={[datetime]::FromFileTime($_.'lastLogon')}}, @{Name="lastLogonTimestamp";Expression={[datetime]::FromFileTime($_.'lastLogonTimestamp')}}, whenCreated | Out-String
  Write-Host $Body

  # email notification
  $Subject = "$subject"
  Send-MailMessage -From $From -To $To -Subject $Subject -Body "The following accounts have no recent activity and should be disabled if are utility accounts.`n$Body" -SmtpServer $SMTPServer -port $SMTPPort
  Write-Host "Email sent to $To"
}
Write-Host $subject
exit
