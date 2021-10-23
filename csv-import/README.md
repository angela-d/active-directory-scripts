# Import Active Directory Users from CSV
Bulk import users from a CSV spreadsheet into AD.

This was forked from [Powershell Scripts](https://ferris-powershell-scripts.blogspot.com/2019/11/ad-bulkusers1ps1.html) with several improvements:

- Script cleanup/organization
- Debug mode added
- Sub-OU customization & config option
- Temporary password creation
- Spreadsheet export with all the new users and their temporary passwords

## Customization
On first run, modify some hardcoded stuff, first:
```powershell
$OU = $('OU=' + $seasonOU + ',OU=' + $setOU + ',OU=Special_Programs,OU=Staff,OU=Special_People,DC=example,DC=com')
```
Your organization may have more/less sub-OUs; modify to suit.

Also modify the user's email suffix to match your organization:
```powershell
$email = "$Username@example.com"
```

## Usage
This script makes some assumptions.

- It's being run on a DC or RSAT system that has Active Directory permissions to the OUs needing to be written to
- Your sub-OU tree already exists
- The script has access to the `$filepath` destination, where your importing spreadsheet lies

1. Make sure you're running in debug mode: `$debug = "1"`
2. Config variables are at the top of the script:
  ```powershell
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
  ```
3. Open up a Powershell terminal and run your script:
  ```powershell
  C:\your_script_location\ad-import-users.ps1
  ```
  or
  ```powershell
  cd C:\your_script_location
  .\ad-import-users.ps1
  ```
4. If all looks good, take it out of debug mode and run again.
