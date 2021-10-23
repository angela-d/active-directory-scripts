# Inactive Accounts Check
Search Active Directory for accounts that are enabled, but inactive and send an admin and notification about it.

## Customizing
Set your mailserver details:
```powershell
# To should be a single address
$To = "me@example.com"
# enter any additional recipients, separated by a comma
$From = "admins@example.com"
$SMTPServer = "mailserver.example.com"
$SMTPPort = "25"
```

Specify how far to go back (in days):
```powershell
-TimeSpan 15
```

Set the **CN** you want to *exclude* from the search / notifications:
```powershell
?{($_.DistinguishedName -notmatch "OU=Retired,OU=People") -and
($_.DistinguishedName -notmatch "OU=Deleted,OU=People") -and
($_.DistinguishedName -notmatch "OU=Utility_Accounts") -and
($_.DistinguishedName -notlike "CN=*Wifi*") -and
($_.DistinguishedName -notlike "CN=Printer*") -and
($_.DistinguishedName -notmatch "CN=IT-Test")} |
```
You can regex by partial CN with `*`

## Usage
Put the script on one of your DCs or RSAT that has read access to Active Directory and set up a task to run it on your desired schedule.

### Known Bugs
The last logon date is sometimes going to be inaccurate, as that field is pulled from the DC the server is lives on; so if you have a cluster, you may see the last logon date as default for some entries.
