# CONFIG
	$From = "Example <me@example.com>"
	$SMTPServer = "mail.example.com"
	$SMTPPort = "25"
	$subject="Example Subject"
	$filepath = "C:\Scripts\email-from-csv\users.csv"
	$debug = "1"
# END CONFIG

$message="
Hello!`n`n
Message content here.
"

#Loop through each row containing user details in the CSV file
Import-Csv $filepath | ForEach-Object {
	#Read user data from each field in each row and assign the data to a variable as below
	$Email 	 = "$($_.Email)".trim()

	# send the email
	if ($debug -eq 0){
		Send-MailMessage -From $From -To $Email -Subject $subject -Body $message -SmtpServer $SMTPServer -port $SMTPPort
		Write-Host "Email sent to $Email" -ForegroundColor Green
	} else {
		Write-Warning "IN DEBUG MODE - NO EMAIL SENT"
		Write-Host "To: $Email" -ForegroundColor Green
		Write-Host "Subject: $subject" -ForegroundColor Green
	}

}

if ($debug -eq 1) {
	Send-MailMessage -From $From -To $From -Subject $subject -Body $message -SmtpServer $SMTPServer -port $SMTPPort
	Write-Host "A sample email was sent to $Email" -ForegroundColor Red
}

exit
