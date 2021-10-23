# forked from https://ferris-powershell-scripts.blogspot.com/2019/11/ad-bulkusers1ps1.html
# Import active directory module for running AD cmdlets
Import-Module -Name ActiveDirectory

## User names and emails have a 17 charecters limit ##
# list to import -- MUST be a .csv
$filepath = "C:\Scripts\import.csv"
# exported list to send to outreach
$outfile = "C:\Scripts\output.csv"
# what session is this? fall (FA), spring? (SP)?
$seasonOU = "FA2021"
# specify destination OU
$setOU = "Destination_OU"
# ad description for user field
$description = "Fall 2021 Description"
# what group to add the user to?
$addToGroup = "ad_group"
# 0 = run live (no debug!), 1 = do not submit to AD.. testing
$debug = "1"

## no need to edit anything else ##

Set-StrictMode -Version latest
# create the empty output file
if ($debug -eq 0){
	Out-File -FilePath $outfile
	Add-Content $outfile "`"First`",`"Last`",`"Username`",`"Password`",`"Email`""
}

# source: https://jonlabelle.com/snippets/view/powershell/generate-random-alphanumeric-string-in-powershell
function Get-RandomAlphanumericString {
  [CmdletBinding()]
  Param ([int] $length = 6)

  Begin {}

  Process {
    Write-Output (-join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count $length  | % {[char]$_}))
  }
}

# loop through each row containing user details in the CSV file
Import-Csv $filepath | ForEach-Object {
	#Read user data from each field in each row and assign the data to a variable as below
	$Firstname 	 = "$($_.First)".trim()
	$Lastname 	 = "$($_.Last)".trim()
	$Username 	 = ($Firstname+$Lastname).ToLower()
	# remove any special chars from the users name
	$Username    = $Username -replace '[^a-zA-Z0-9]', ''
	$Password 	 = Get-RandomAlphanumericString
	$OU 		     = $('OU=' + $seasonOU + ',OU=' + $setOU + ',OU=Special_Programs,OU=Staff,OU=Special_People,DC=example,DC=com')
	$email       = "$Username@example.com"
	$ID_NUM      = $Username # these users are not normally in the db, have no ID_NUM, so we use username
	$description = $description


if ($debug -eq 1) {
	Write-Host "--- Start $Username ---"

	if (Get-ADUser -F {SamAccountName -eq $Username}) {
		# if user already exists, give a warning
		Write-Warning -Message "$Username already exists in Active Directory"
	}

	Write-Host "Username: $Username"
	Write-Host "First: $Firstname"
	Write-Host "Last: $Lastname"
	Write-Host "Pass: $Password"
	Write-Host "Email: $email"
	Write-Host "OU: $OU"
	Write-Host "ID Num: $ID_NUM"
	Write-Host "Description: $description"
	Write-Host "--- End $Username ---"
	Write-Host ""
	Write-Warning -Message "This is DEBUG mode, set the debug variable to 0 to submit to AD!"

} else {

	# check if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username}) {
		# if user does exist, give a warning
		Write-Warning -Message "$Username already exists in Active Directory, not re-adding!"
		$Password = "user already exists"
	} else {

		# user does not exist; proceed to create the new user account
		$securePWD = convertto-securestring -String $Password -AsPlainText -Force
		New-ADUser -SamAccountName $Username -UserPrincipalName $email -Name "$Firstname $Lastname" -GivenName $Firstname -Surname $Lastname -DisplayName "$Firstname $Lastname" -Path $OU -EmailAddress $email -Description $description -AccountPassword $securePWD -ChangePasswordAtLogon $True -Enabled $True -EmployeeID $ID_NUM -ErrorAction Stop

		if (Get-ADUser -F {SamAccountName -eq $Username}) {
			Write-Host "Added $Username"
		} else {
			Write-Warning "Error creating $Username !!!"
		}
	}

	# add the user to their group
	if (Get-ADUser -F {SamAccountName -eq $Username}) {
		Add-ADGroupMember -Identity $addToGroup -Members $Username
		Write-Host "$Username added to $addToGroup"
	}

	# append user info to csv
	$importedUser =[pscustomobject]@{
		'First' = $Firstname
		'Last' = $Lastname
		'Username' = $Username
		'Temp PW' = $Password
		'Email' = $Email
    }

	$importedUser | export-csv $outfile -Append -NoTypeInformation -Force

}
}
