---
external help file: PSLicense-help.xml
online version: 
schema: 2.0.0
---

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

The user uses the switch(es) provided at runtime to select an action(s).
The script will then present a GUI (Out-GridView) from which the user will select.
Depending on the switch, the GUI will contain Skus and Options - all, specific to their tenant.
For example, if the user selects the switch "Add Option", they will be presented with each Sku and its corresponding options.
The user can then control + click to select multiple Options.

Multiple switches can be used simultaneously.  
For example, the user could choose to remove a Sku, add a different Sku, then add or remove options.
The order of processing each switch is: Remove Sku, Remove Options, Add Skus, Add Options, Move Options From One Sku to Another, Template Mode

Template Mode wipes out any other options other than the options the user chooses.
This is specific only to the Skus that contain the options chosen in Template Mode.
For example, if the user has 3 Skus: E1, E3 and E5...
and the user selects only the option "Skype" in the E3 Sku, E1 and E5 will remain untouched.
However, the users that this script ran against will have only one option under the E1 Sku - Skype.

Further explanations of the switches are demonstrated in the Examples below.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -SearchString cloud0 | Set-LACloudLicenseV2 -MoveOptionsFromOneSkuToAnother -Verbose
```

Moves ENABLED options (Service Plans) from one Sku to another Sku.  
The user will be presented with 2 GUIs to select the Source Sku and the Destination Sku.
All Source Sku options will be moved to their corresponding, same-named option in the Destination Sku.

The script will strip off MOST version numbers for a best effort match from unlike SKUs (for ex, E3 to E5)
This is the list of what is stripped off currently, (more can be added to Get-UniqueString.ps1) :
_E3 _E5 _P1 _P2 _P3 _1  _2  2   _GOV    _MIDMARKET  _STUDENT    _FACULTY    _A  _O365

To have a look at the Options use the following command - this will display the option names mentioned above (and corresponding "friendly name")
Get-AzureADUser -SearchString foo | Set-LACloudLicenseV2 -DisplayTenantsSkusAndOptionsLookup

### -------------------------- EXAMPLE 2 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -SearchString cloud0 | Set-LACloudLicenseV2 -MoveOptionsFromOneSkuToAnother -MoveOptionsSourceOptionsToIgnore -MoveOptionsDestOptionsToAdd -Verbose
```

Same as in EXAMPLE 1 but also...
The user can choose which options in the Source Sku to ignore.
And/Or, the user can choose which options should be added to the destination SKU

### -------------------------- EXAMPLE 3 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Import-Csv .\upns.csv | Set-LACloudLicenseV2 -MoveOptionsFromOneSkuToAnother -MoveOptionsSourceOptionsToIgnore -MoveOptionsDestOptionsToAdd -Verbose

A CSV could look like this

UserPrincipalName
user01@contoso.com
user02@contoso.com
```

Demonstrates the use of a CSV, who would receive the changes made by the script.  Ensure their is a header named, UserPrincipalName.

### -------------------------- EXAMPLE 4 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -ObjectID "foo@contoso.com" | Set-LACloudLicenseV2 -AddSku -Verbose
```

Adds a Sku or multiple Skus with all available options.
If the user already has the Sku, all options will be added if the aren't already.

### -------------------------- EXAMPLE 5 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -SearchString cloud0 | Set-LACloudLicenseV2 -AddOptions -Verbose
```

Adds specific options in addition to options that are already in place for each end user.
If the end-user has yet to have the Sku assigned, it will be assigned with the options enabled that were specified at runtime.
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

### -------------------------- EXAMPLE 7 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Import-Csv .\upns.csv | Set-LACloudLicenseV2 -RemoveSku -Verbose
```

## PARAMETERS

### -RemoveSkus
{{Fill RemoveSkus Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveOptions
{{Fill RemoveOptions Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddSkus
{{Fill AddSkus Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddOptions
{{Fill AddOptions Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MoveOptionsFromOneSkuToAnother
{{Fill MoveOptionsFromOneSkuToAnother Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MoveOptionsSourceOptionsToIgnore
{{Fill MoveOptionsSourceOptionsToIgnore Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MoveOptionsDestOptionsToAdd
{{Fill MoveOptionsDestOptionsToAdd Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateMode
{{Fill TemplateMode Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportUserLicenses
{{Fill ReportUserLicenses Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportUserLicensesEnabled
{{Fill ReportUserLicensesEnabled Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportUserLicensesDisabled
{{Fill ReportUserLicensesDisabled Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayTenantsSkusAndOptions
{{Fill DisplayTenantsSkusAndOptions Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -TheUser
{{Fill TheUser Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayTenantsSkusAndOptionsFriendlyNames
{{Fill DisplayTenantsSkusAndOptionsFriendlyNames Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayTenantsSkusAndOptionsLookup
{{Fill DisplayTenantsSkusAndOptionsLookup Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

Thank you,

Kevin


Kevin Blumenfeld
Sr. Microsoft Architect
PCM
5080 Old Ellis Pointe          
Roswell, GA  30076
kevin.blumenfeld@pcm.com
Office:  678-297-5738
Mobile: 678-437-7468
pcm.com


