# CONFIG
	$subOU      = "2022"
	$setOU      = "This_OU"
	# To should be a single address
	$To         = "you@example.com"
	# enter any additional recipients above, separated by a comma
	$From       = "noreply@example.com"
	# if you don't use a relay server, set your tls stuff in the Send-MailMessage too!
	$SMTPServer = "relayserver.example.com"
	$SMTPPort   = "25"
	$targetOU   = $('OU=' + $subOU + ',OU=' + $setOU + ',OU=People,DC=example,DC=com')
# END CONFIG

# pwdLastSet is a large integer attribute, counting the objects behaves strangely if there's 1 record vs 2+
# so rather than count the obj returned, simply increment anything meeting the null condition
[int]$totalAccounts = 0;

$checkAccounts = (Get-ADUser -Filter * -Properties Name, EmailAddress, Description, pwdLastSet -SearchBase $targetOU |
	Select-Object Name, EmailAddress, Description, @{Name='pwdLastSet';Expression={if($_.pwdLastSet -eq 0){"never"} else {"set"}}}
)

$totalAccounts = 0;
foreach ($user in $checkAccounts) {
	if ($user.pwdLastSet -eq 'never') {
		$userName = "Name: " + $user.Name
		$email = "Email: " + $user.EmailAddress
		$description = "Note/Description: " + $user.Description
		$separator = '--------------------'
		$totalAccounts++

		$messageBody += "$separator`n$userName`n$email`n$description`n$separator`n"
	}
}

$subject = "$totalAccounts accounts have not yet been activated"

# send an email if there's more than 1 record
if ($totalAccounts -gt 0) {
  # display for the terminal
  Write-Host $messageBody

  # email notification
  $Subject = "$subject"
  Send-MailMessage -From $From -To $To -Subject $Subject -Body "The following accounts have not yet been activated:`n`n$messageBody" -SmtpServer $SMTPServer -port $SMTPPort
  Write-Host "Email sent to $To"
}
Write-Host $subject  -ForegroundColor Green
exit
