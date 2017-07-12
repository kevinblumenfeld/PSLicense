
# Set-LACloudLicenseV2

## SYNOPSIS
Use this tool to license Office 365 with ease.

## SYNTAX

```
Set-LACloudLicenseV2 [-RemoveSkus] [-RemoveOptions] [-AddSkus] [-AddOptions] [-MoveOptionsFromOneSkuToAnother]
 [-MoveOptionsSourceOptionsToIgnore] [-MoveOptionsDestOptionsToAdd] [-TemplateMode] [-ReportUserLicenses]
 [-ReportUserLicensesEnabled] [-ReportUserLicensesDisabled] [-DisplayTenantsSkusAndOptions]
 [-DisplayTenantsSkusAndOptionsFriendlyNames] [-DisplayTenantsSkusAndOptionsLookup] [-TheUser] <String[]>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This tool allows you license one, many or all of your Office 365 users with several methods.

The person running the script uses the switch(es) provided at runtime to select an action(s).
The script will then present a GUI (Out-GridView) from which the person running the script will select.
Depending on the switch(es), the GUI will contain Skus and/or Options - all specific to their Office 365 tenant.

For example, if the person running the script selects the switch "Add Option", they will be presented with each Sku and its corresponding options.
The person running the script can then control + click to select multiple Options.

Multiple switches can be used simultaneously.  
For example, the person running the script could choose to remove a Sku, add a different Sku, then add or remove options.
The order of processing each switch is: Remove Sku, Remove Options, Add Skus, Add Options, Move Options From One Sku to Another, Template Mode.

Template Mode wipes out any other options - other than the options the person running the script chooses.
This is specific only to the Skus that contain the options chosen in Template Mode.
For example, if the end-user(s) has 3 Skus: E1, E3 and E5...
and the person running the script selects only the option "Skype" in the E3 Sku, E1 and E5 will remain unchanged.
However, the end-user(s) that this script runs against will have only one option under the E1 Sku - Skype.

No matter which switch is used, the person running the script will be presented with a GUI(s) for any selections that need to be made.

Further explanations of the switches are demonstrated in the EXAMPLES below.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -SearchString cloud0 | Set-LACloudLicenseV2 -MoveOptionsFromOneSkuToAnother -Verbose
```

Moves **ENABLED** options (Service Plans) from one Sku to another Sku.  
the person running the script will be presented with 2 GUIs to select the Source Sku and the Destination Sku.
All Source Sku options will be moved to their corresponding, same-named option in the Destination Sku.

The script will strip off MOST version numbers for a best-effort match from unlike SKUs (for ex, E3 to E5)
This is the list of what is stripped off currently, (more can be added to Get-UniqueString.ps1)

_E3 _E5 _P1 _P2 _P3 _1  _2    2   _GOV    _MIDMARKET  _STUDENT    _FACULTY    _A  _O365

To have a look at the Options use the following command - this will display the option names mentioned above (and corresponding "friendly name")
Get-AzureADUser -SearchString foo | Set-LACloudLicenseV2 -DisplayTenantsSkusAndOptionsLookup

### -------------------------- EXAMPLE 2 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Import-Csv .\upns.csv | Set-LACloudLicenseV2 -MoveOptionsFromOneSkuToAnother -MoveOptionsSourceOptionsToIgnore -MoveOptionsDestOptionsToAdd -Verbose
```

Same as in EXAMPLE 1 but also these "overrides" are available...
The person running the script can choose which options in the Source Sku to ignore for the Move of Options.
And/Or, the person running the script can choose which options should be added to the destination SKU regardless of the Move of Options.

### -------------------------- EXAMPLE 3 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Import-Csv .\upns.csv | Set-LACloudLicenseV2 -MoveOptionsFromOneSkuToAnother -MoveOptionsSourceOptionsToIgnore -MoveOptionsDestOptionsToAdd -Verbose

A CSV could look like this

UserPrincipalName
user01@contoso.com
user02@contoso.com
```

Demonstrates the use of a CSV, who would receive the changes made by the script.  Ensure there is a header named, UserPrincipalName.

### -------------------------- EXAMPLE 4 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -ObjectID "foo@contoso.com" | Set-LACloudLicenseV2 -AddSku -Verbose
```

Adds a Sku or multiple Skus with all available options.
If the end-user already has the Sku, all options will be added to that Sku, if not already.

### -------------------------- EXAMPLE 5 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -SearchString cloud0 | Set-LACloudLicenseV2 -AddOptions -Verbose
```

Adds specific options in addition to options that are already in place for each end user.
If the end-user has yet to have the Sku assigned, it will be assigned with the options enabled - that were specified by the person running the script.
The options are chosen via a GUI (Out-GridView). Each options is listed next to its corresponding SKU to eliminate any possible confusion.

### -------------------------- EXAMPLE 6 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -Department 'Human Resources'| Set-LACloudLicenseV2 -RemoveSku -Verbose
```

Removes a Sku or Skus.
The Sku(s) are chosen via a GUI (Out-GridView)

### -------------------------- EXAMPLE 7 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Import-Csv .\upns.csv | Set-LACloudLicenseV2 -RemoveOptions -Verbose
```

Removes specific options from a Sku or multiple Skus.
If the end-user does not have the Sku, no action will be taken
Options are presented in pairs, with their respective SKU - to avoid any possible confusion with "which option is associated with which Sku".
The Options(s) are chosen via a GUI (Out-GridView)

### -------------------------- EXAMPLE 8 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -Filter "JobTitle eq 'CEO'"   | Set-LACloudLicenseV2 -ReportUserLicenses
Get-AzureADUser -SearchString "John Smith"    | Set-LACloudLicenseV2 -ReportUserLicensesEnabled
Get-AzureADUser -Department "Human Resources" | Set-LACloudLicenseV2 -ReportUserLicensesDisabled
```

The 3 commands display the current options licensed to an end-user(s) - 3 different ways respectively.
1. All the end-user(s) Options (organized by Sku)
2. All the end-user(s) Enabled licenses only (organized by Sku)
3. All the end-user(s) Disabled licenses only (organized by Sku)

### -------------------------- EXAMPLE 9 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -SearchString foo | Set-LACloudLicenseV2 -DisplayTenantsSkusAndOptionsLookup
```

This will display the available Office 365 tenant's available Skus and corresponding Options.
Also, this displays the the total amount of licenses and the total amount that are unassigned (remaining).

### -------------------------- EXAMPLE 10 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Import-Csv .\upns.csv | Set-LACloudLicenseV2 -TemplateMode
```

This is meant to level-set the end-users with the same options.

Here is an example of a scenario.  The end-users all have 3 Skus E3, E5 & EMS.  The command listed in this example is executed and The person running the script makes the following selections in the presented GUI: 
1. 4 options are chosen for Sku E3 
2. 7 options are chosen for Sku E5
3. Zero options are chosen for Sku EMS

For each End-User in the upns.csv, the results would be the following:
1. Sku E3: They will have assigned exactly the 4 options - all the other Sku's options will be disabled
2. Sku E5: They will have assigned exactly the 7 options - all the other Sku's options will be disabled
3. Sku EMS: Will remain unchanged, regardless of what the end-user had previously.


# Get-LACloudLicense

## SYNOPSIS
Exports all of a Office 365 tenant's licensed users. 
Based on a script by Alan Byrne

## SYNTAX

```
Get-LACloudLicense [<CommonParameters>]
```

## DESCRIPTION
Exports all of a Office 365 tenant's licensed users. 
Detailing which users have which SKU and if the provisioning status of each Option in that SKU
There is an Excel Macro with instruction in the comments in the script which divide into tabs, each Sku
Once connected to MSOnline, simply run the script (as in the example) and a time/date stamped file 
will be created in the current directory. 
The excel macro should then be used. 
Can be time consuming
run against large tenants.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-LAConnected -Tenant Contoso -ExchangeAndMSOL
```

Get-LACloudLicense