function Set-LACloudLicenseV2 {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param
    (

    )

    DynamicParam {          
        #Create the RuntimeDefinedParameterDictionary
        # $DynamicParameters  = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $DynamicParameters = @(
            @{
                Name             = 'AddSku'
                Type             = [array]
                Position         = 0
                Mandatory        = $false
                ValidateSet      = (Get-AzureADSubscribedSku).SkuPartNumber
                ParameterSetName = 'ssCollection1'
            },
            @{
                Name             = 'AddService'
                Type             = [array]
                Position         = 1
                Mandatory        = $false
                ValidateSet      = (Get-AzureADSubscribedSku).serviceplans.serviceplanname
                ParameterSetName = 'ssCollection1'
            }
        )
        $DynamicParameters | ForEach-Object {New-Object PSObject -Property $_} | New-DynamicParameter
    }

    # Function's Begin Block
    Begin {
        New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

        # Zero Variables and Define Arrays
        $BaseDisabledOptions = @()
        $BaseSkuRemove = @()
        $addsku = @()
        $addop = @()
        $remop = @()
        $user = @()

        # Assign Tenant and Location to a variable
        $Tenant = (Get-MsolAccountSku)[0].accountname
        $Location = "US"
  
        # Assign each AccountSkuID to a variable
        $SkuE5 = ($Tenant + ':ENTERPRISEPREMIUM')
        $SkuE4 = ($Tenant + ':ENTERPRISEWITHSCAL')
        $SkuE3 = ($Tenant + ':ENTERPRISEPACK')
        $SkuE2 = ($Tenant + ':STANDARDWOFFPACK')
        $SkuE1 = ($Tenant + ':STANDARDPACK')
        $SkuEO2 = ($Tenant + ':EXCHANGEENTERPRISE')
        $SkuEMS = ($Tenant + ':EMS')
        $SkuCSP = ($Tenant + ':SPE_E3')
        $SkuMBC = ($Tenant + ':MICROSOFT_BUSINESS_CENTER')
        $SkuShareEnt = ($Tenant + ':SHAREPOINTENTERPRISE')        
        $SkuPowerApps = ($Tenant + ':POWERAPPS_INDIVIDUAL_USER')
        $SkuPowerBI = ($Tenant + ':POWER_BI_INDIVIDUAL_USER')        
        $SkuPowerBIPro = ($Tenant + ':POWER_BI_PRO')
        $SkuPowerBIFree = ($Tenant + ':POWER_BI_STANDARD')        
        $SkuRMSAdhoc = ($Tenant + ':RIGHTSMANAGEMENT_ADHOC')

        # Set Base Options for SKU    
        # $BaseDisabledOptions = 'OFFICESUBSCRIPTION'
        $PrimarySku = $SkuCSP
        
        # Hashtable for Options
        $hash = @{ 
            "ATP_ENTERPRISE"                     = "Exchange Online ATP";
            "AX_ENTERPRISE_USER"                 = "AX ENTERPRISE USER";
            "AX_SANDBOX_INSTANCE_TIER2"          = "AX_SANDBOX_INSTANCE_TIER2";
            "AX_SELF-SERVE_USER"                 = "AX SELF-SERVE USER";
            "AX_TASK_USER"                       = "AX_TASK_USER";
            "CRMPLAN2"                           = "Dynamics CRM Online Plan 2";
            "CRMSTORAGE"                         = "Microsoft Dynamics CRM Online Additional Storage";
            "DESKLESSPACK"                       = "Office 365 Enterprise K1 without Yammer";
            "DESKLESSPACK_YAMMER"                = "Office 365 Enterprise K1 with Yammer";
            "DESKLESSWOFFPACK"                   = "Office 365 Enterprise K2";
            "EMS"                                = "Enterprise Mobility + Security E3";
            "EMSPREMIUM"                         = "EMSPREMIUM";
            "ENTERPRISEPACK"                     = "Office 365 Enterprise E3";
            "ENTERPRISEPACK_B_PILOT"             = "ENTERPRISEPACK_B_PILOT";
            "ENTERPRISEPACK_FACULTY"             = "Office 365 Plan A3 for Faculty";
            "ENTERPRISEPACK_STUDENT"             = "Office 365 Plan A3 for Students";
            "ENTERPRISEPACKLRG"                  = "Office 365 (Plan E3)";
            "ENTERPRISEPACKWITHOUTPROPLUS"       = "Office 365 Enterprise E3 without ProPlus Add-on";
            "ENTERPRISEPREMIUM"                  = "Office 365 Enterprise E5";
            "ENTERPRISEWITHSCAL"                 = "Office 365 Enterprise E4";
            "ENTERPRISEWITHSCAL_FACULTY"         = "Office 365 Education E4 for Faculty";
            "ENTERPRISEWITHSCAL_STUDENT"         = "Office 365 Education E4 for Students";
            "EXCHANGE_L_STANDARD"                = "Exchange Online (Plan 1)";
            "EXCHANGE_S_ENTERPRISE"              = "Exchange Online Plan 2";
            "EXCHANGEENTERPRISE"                 = "Exchange Online Plan 2";
            "EXCHANGEENTERPRISE_FACULTY"         = "Exch Online Plan 2 for Faculty";
            "EXCHANGESTANDARD"                   = "Exchange Online Plan 1";
            "FLOW_FREE"                          = "Microsoft Flow Free";
            "INTUNE_A_VL"                        = "Intune (Volume License)";
            "IT_ACADEMY_AD"                      = "Microsoft Imagine Academy";
            "LITEPACK_P2"                        = "Office 365 Small Business Premium";
            "MCOLITE"                            = "Lync Online (Plan 1)";
            "MICROSOFT_BUSINESS_CENTER"          = "MICROSOFT_BUSINESS_CENTER";
            "MIDSIZEPACK"                        = "Office 365 Midsize Business";
            "OFFICE_PRO_PLUS_SUBSCRIPTION_SMBIZ" = "Office ProPlus";
            "OFFICESUBSCRIPTION_FACULTY"         = "Office 365 ProPlus for Faculty";
            "POWER_BI_INDIVIDUAL_USER"           = "Power BI for Office 365 Individual";
            "POWER_BI_PRO"                       = "POWER_BI_PRO";
            "POWER_BI_STANDALONE"                = "Power BI for Office 365 Standalone";
            "POWER_BI_STANDARD"                  = "Power BI for Office 365 Standard";
            "POWERAPPS_INDIVIDUAL_USER"          = "Microsoft PowerApps and Logic flows";
            "PROJECT_MADEIRA_PREVIEW_IW_SKU"     = "PROJECT_MADEIRA_PREVIEW_IW";
            "PROJECTCLIENT"                      = "Project Pro for Office 365";
            "PROJECTESSENTIALS"                  = "Project Lite";
            "PROJECTONLINE_PLAN_1"               = "Project Online with Project for Office 365";
            "PROJECTONLINE_PLAN_1_FACULTY"       = "Project Online for Faculty Plan 1";
            "PROJECTONLINE_PLAN_1_STUDENT"       = "Project Online for Students Plan 1";
            "PROJECTONLINE_PLAN_2_FACULTY"       = "Project Online for Faculty Plan 2";
            "PROJECTONLINE_PLAN_2_STUDENT"       = "Project Online for Students Plan 2";
            "PROJECTPREMIUM"                     = "Project Online Premium";
            "PROJECTPROFESSIONAL"                = "Project Online Professional";
            "RIGHTSMANAGEMENT_ADHOC"             = "Azure Rights Management Services Ad-hoc";
            "RIGHTSMANAGEMENT_STANDARD_FACULTY"  = "Information Rights Management for Faculty";
            "RIGHTSMANAGEMENT_STANDARD_STUDENT"  = "Information Rights Management for Students";
            "RMS_S_ENTERPRISE"                   = "Azure Active Directory Rights Management";
            "SHAREPOINTENTERPRISE"               = "SharePoint Online (Plan 2)";
            "SHAREPOINTENTERPRISE_MIDMARKET"     = "SharePoint Online (Plan 1)";
            "SHAREPOINTLITE"                     = "SharePoint Online (Plan 1)";
            "SHAREPOINTSTANDARD"                 = "SharePoint Online Plan 1";
            "SHAREPOINTWAC"                      = "Office Online";
            "SPE_E3"                             = "Secure Productive Enterprise E3";
            "STANDARD_B_PILOT"                   = "STANDARD_B_PILOT";
            "STANDARDPACK"                       = "Office 365 Enterprise E1";
            "STANDARDPACK_FACULTY"               = "STANDARDPACK_FACULTY";
            "STANDARDPACK_STUDENT"               = "Office 365 (Plan A1) for Students";
            "STANDARDWOFFPACK"                   = "Office 365 Enterprise E2";
            "STANDARDWOFFPACK_IW_FACULTY"        = "O365 Education for Faculty";
            "STANDARDWOFFPACK_IW_STUDENT"        = "O365 Education for Students";
            "STANDARDWOFFPACK_STUDENT"           = "O365 Education E1 for Students";
            "STANDARDWOFFPACKPACK_FACULTY"       = "Office 365 Plan A2 for Faculty";
            "STANDARDWOFFPACKPACK_STUDENT"       = "Office 365 Plan A2 for Students";
            "STREAM"                             = "Microsoft Stream";
            "VISIOCLIENT"                        = "Visio Pro for Office 365";
            "WACSHAREPOINTSTD"                   = "Office Online";
            "YAMMER_ENTERPRISE"                  = "Yammer";
            "YAMMER_MIDSIZE"                     = "Yammer"
        }

        # Hashtable to match Options to their SKUs
        $hash4sku = @{ 
            "Teams"                 = "$PrimarySku";
            "Sway"                  = "$PrimarySku";
            "Yammer"                = "$PrimarySku";
            "Flow"                  = "$PrimarySku";
            "OfficePro"             = "$PrimarySku";
            "StaffHub"              = "$PrimarySku";
            "Planner"               = "$PrimarySku";
            "PowerApps"             = "$PrimarySku";
            "AzureRMS"              = "$PrimarySku";
            "OfficeOnline"          = "$PrimarySku";
            "SharePoint"            = "$PrimarySku";
            "Skype"                 = "$PrimarySku";
            "Exchange"              = "$PrimarySku";
            "Intune"                = "$SkuEMS";
            "Azure_Info_Protection" = "$SkuEMS";
            "Azure_Rights_Mgt"      = "$SkuEMS";
            "Azure_AD_Premium"      = "$SkuEMS";
            "Azure_MultiFactorAuth" = "$SkuEMS"
        }

        # Check if SKUs are to be modified
        if ($E3.IsPresent) {
            $addsku += , $SkuE3
        }
        if ($E5.IsPresent) {
            $addsku += , $SkuE5
        }
        if ($EMS.IsPresent) {
            $addsku += , $SkuEMS
        }
        if ($PowerAppsandLogicFlows.IsPresent) {
            $addsku += , $SkuPowerApps
        }
        if ($PowerBI.IsPresent) {
            $addsku += , $SkuPowerBI
        }
        if ($PowerBIPro.IsPresent) {
            $addsku += , $SkuPowerBIPro
        }
        if ($PowerBIFree.IsPresent) {
            $addsku += , $SkuPowerBIFree
        }
        if ($RMSAdhoc.IsPresent) {
            $addsku += , $SkuRMSAdhoc
        }
        
        # Compile a list of Options to be added
        if ($AddOption) {
            $addop += , $AddOption
        }
        if ($AddOption2) {
            $addop += , $AddOption2
        }
        if ($AddOption3) {
            $addop += , $AddOption3        
        }

        # Compile a list of Options to be removed
        if ($RemoveOption) {
            $remop += , $RemoveOption
        }
        if ($RemoveOption2) {
            $remop += , $RemoveOption2
        }
        if ($RemoveOption3) {
            $remop += , $RemoveOption3
        }

        # Compile Base Options
        if (!($addsku -or $addop -or $remop)) {
            $BaseSkuRemove += , $SkuE3
            Write-Output "BASESKUREMOVE: $BaseSkuRemove"
        }
    }

    Process {
        $DisabledOptions = @()      

        # Compile all user's attributes from UPN
        $user = Get-MsolUser -UserPrincipalName $_.UserPrincipalName

        # Set User's Location
        Set-MsolUser -UserPrincipalName $user.userprincipalname -UsageLocation $Location

        # Add SKUs (or Remove SKUs) requested by user  
        if ($addsku) {
            for ($i = 0; $i -lt $addsku.count; $i++) {
                $FullSku = @()
                if (!($RemoveSKU.IsPresent)) {
                    if ($user.licenses.accountskuid -contains $addsku[$i]) {
                        $FullSku = New-MsolLicenseOptions -AccountSkuId $addsku[$i]
                        Write-Output "$($user.userprincipalname) is already assigned SKU: $($addsku[$i]). All Options will be added now"
                        Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -LicenseOptions $FullSku    
                    }
                    else {
                        Write-Output "$($user.userprincipalname) is not assigned SKU: $($addsku[$i]). Assigning SKU now"
                        Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -AddLicenses $addsku[$i]
                    }
                }
                # Remove SKUs requested by user
                else {
                    if ($user.licenses.accountskuid -contains $addsku[$i]) {
                        Write-Output "$($user.userprincipalname) is assigned SKU: $($addsku[$i]). REMOVING SKU now"
                        Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -RemoveLicenses $addsku[$i] -Verbose   
                    }
                    else {
                        Write-Output "$($user.userprincipalname) is not assigned SKU: $($addsku[$i]). No need to remove."
                    }
                }
            }
        }
        # Adding options requested by user
        if ($addop) {
            for ($i = 0; $i -lt $addop.count; $i++) {
                $DisabledOptions = @()
                $user = Get-MsolUser -UserPrincipalName $_.UserPrincipalName
                if ($user.licenses.accountskuid -contains $hash4sku[$addop[$i]]) {
                    ForEach ($License in $user.licenses | where {$_.AccountSkuID -contains $hash4sku[$addop[$i]]}) {
                        
                        $License.ServiceStatus | ForEach {
                            if ($_.ServicePlan.ServiceName -ne $hash[$addop[$i]] -and $_.ProvisioningStatus -eq "Disabled") {
                                $DisabledOptions += $_.ServicePlan.ServiceName
                            }
                        }
                        $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $hash4sku[$addop[$i]] -DisabledPlans $DisabledOptions
                        Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -LicenseOptions $LicenseOptions -ErrorAction SilentlyContinue -ErrorVariable dependency
                        if ($dependency) {
                            Write-Warning "Unable to add: $($addop[$i])`, probably due to a dependency"
                        }
                        else {
                            Write-Output "$($user.userprincipalname) adding option: $($addop[$i])"
                        }
                    }              
                }  
                else {
                    Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -AddLicenses $hash4sku[$addop[$i]]
                    $user = Get-MsolUser -UserPrincipalName $_.UserPrincipalName
                    ForEach ($License in $user.licenses | where {$_.AccountSkuID -eq $hash4sku[$addop[$i]]}) {
                        $License.ServiceStatus | ForEach {
                            if ($_.ServicePlan.ServiceName -ne $hash[$addop[$i]]) {
                                $DisabledOptions += $_.ServicePlan.ServiceName
                                write-host "Disabled Options: $DisabledOptions"
                            }
                        }
                        $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $hash4sku[$addop[$i]] -DisabledPlans $DisabledOptions
                        Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -LicenseOptions $LicenseOptions -ErrorAction SilentlyContinue -ErrorVariable dependency
                        if ($dependency) {
                            Write-Warning "Unable to add: $($addop[$i])`, probably due to a dependency"
                        }
                        else {
                            Write-Output "$($user.userprincipalname) does not have the SKU: $($hash4sku[$addop[$i]])`. Adding SKU with only $($addop[$i])"
                        }
                    }
                }
            }
        }
        # Remove options requested by user
        if ($remop) {
            for ($i = 0; $i -lt $remop.count; $i++) {
                $DisabledOptions = @()
                $user = Get-MsolUser -UserPrincipalName $_.UserPrincipalName
                if ($user.licenses.accountskuid -contains $hash4sku[$remop[$i]]) {
                    ForEach ($License in $user.licenses | where {$_.AccountSkuID -contains $hash4sku[$remop[$i]]}) {
                        $License.ServiceStatus | ForEach {
                            if ($_.ProvisioningStatus -eq "Disabled" -or $_.ServicePlan.ServiceName -eq $hash[$remop[$i]]) {
                                $DisabledOptions += $_.ServicePlan.ServiceName
                            } 
                        }
                    }
                    $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $hash4sku[$remop[$i]] -DisabledPlans $DisabledOptions
                    Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -LicenseOptions $LicenseOptions -ErrorAction SilentlyContinue -ErrorVariable dependency
                    if ($dependency) {
                        Write-Warning "Unable to remove: $($remop[$i])`, probably due to a dependency"
                    }
                    else {
                        Write-Output "$($user.userprincipalname) removing option: $($remop[$i])"
                    }
                }
                else {
                    Write-Output "$($user.userprincipalname) does not have SKU: $($hash4sku[$remop[$i]])`, cannot remove option: $($remop[$i])"
                }
            }
        }
        # If no switches or options provided, user(s) will receive a base license (predefined by I.T. dept)
        if ($BaseSkuRemove) {
            if ((Get-MsolAccountSku |where {$_.accountskuid -eq $PrimarySku}).consumedunits -lt (Get-MsolAccountSku |? {$_.accountskuid -eq $PrimarySku}).activeunits) {
                for ($i = 0; $i -lt $BaseSkuRemove.count; $i++) {
                    Write-Host "NOT IN IF: $($user.licenses.accountskuid) $($BaseSkuRemove[$i])"
                    if ($user.licenses.accountskuid -contains $BaseSkuRemove[$i]) {
                        Write-Host "IN IF: $($user.licenses.accountskuid) $($BaseSkuRemove[$i])"
                        # Collect options of the SKU to add in the new sku THEN we will remove the old SKU
                        ForEach ($License in $user.licenses | Where {$_.AccountSkuID -eq $SkuE3}) {
                            $License.ServiceStatus |  ForEach {
                                if (($_.ProvisioningStatus -eq "Disabled") -and ($_.ServicePlan.ServiceName -notin "FLOW_O365_P2", "POWERAPPS_O365_P2")) {
                                    $DisabledOptions += $_.ServicePlan.ServiceName
                                } 
                            }
                        }
                        Write-Host "UPN: $($user.userprincipalname) DISABLED: $DisabledOptions"
                        # For MDWise
                        # Remove EMS
                        Write-Host "REMOVING EMS"
                        Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -RemoveLicenses $SkuEMS -Verbose -ErrorAction Continue
                        # Removing BaskSKU
                        Write-Host "REMOVING E3"
                        Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -RemoveLicenses $BaseSkuRemove[$i] -Verbose -ErrorAction Continue
                        # Add SPE with respect to EnterprisePack options (match options)
                        Write-Output "$($user.userprincipalname) Assigning: $PrimarySku SKU now"
                        $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $PrimarySku -DisabledPlans $DisabledOptions
                        Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -AddLicenses $PrimarySku -LicenseOptions $LicenseOptions -ErrorAction Continue
                        Write-Output "$($user.userprincipalname) Assigning: mdwise:MICROSOFT_BUSINESS_CENTER"
                        Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -AddLicenses "mdwise:MICROSOFT_BUSINESS_CENTER"
                    }        
                }
                <#
                if ($user.licenses.accountskuid -contains $PrimarySku) {
                    Write-Output "$($user.userprincipalname) is already assigned SKU: $($PrimarySku). Modifying options if necessary."
                    ForEach ($License in $user.licenses | Where {$_.AccountSkuID -eq $PrimarySku}) {
                        $License.ServiceStatus | ForEach {
                            if ($_.ServicePlan.ServiceName -eq "OFFICESUBSCRIPTION") {
                                $DisabledOptions += $_.ServicePlan.ServiceName
                            }
                        }
                    }
                    $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $PrimarySku -DisabledPlans $DisabledOptions
                    Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -LicenseOptions $LicenseOptions -ErrorAction Continue      
                }
                else {
                    Write-Output "$($user.userprincipalname) is not assigned SKU: $($PrimarySku)`. Adding SKU with Base Options"
                    $LicenseOptions = New-MsolLicenseOptions -AccountSkuId $PrimarySku -DisabledPlans $BaseDisabledOptions
                    Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -AddLicenses $PrimarySku -LicenseOptions $LicenseOptions -ErrorAction Continue
                }
                #>
            }
            Else {
                Write-Output "Out of $PrimarySku licenses"
                Write-Output "Exiting Script"
                Break
            }
        }
    } #End of Process Block 
    End {
    }
}