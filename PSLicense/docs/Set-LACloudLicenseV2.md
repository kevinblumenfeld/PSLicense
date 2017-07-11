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
 [-TheUser] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This tool allows you license one, many or all of your Office 365 users with several methods.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2
```

Get-AzureADUser -SearchString cloud0 |  Set-LACloudLicenseV2 -MoveOptionsFromOneSkuToAnother -MoveOptionsSourceOptionsToIgnore -MoveOptionsDestOptionsToAdd -Verbose

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

