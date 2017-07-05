function Set-LACloudLicenseV2 {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]] $pipelineUser,

        [Parameter(Mandatory = $false)]
        [switch] $RemoveSkus,
        
        [Parameter(Mandatory = $false)]
        [switch] $RemoveOptions,

        [Parameter(Mandatory = $false)]
        [switch] $AddSkus,

        [Parameter(Mandatory = $false)]
        [switch] $AddOptions

    )

    DynamicParam {          
        $DynamicParameters = @(
            @{
                Name             = 'addSku1'
                Type             = [array]
                Position         = 0
                Mandatory        = $false
                ValidateSet      = . Get-CloudSku
                ParameterSetName = 'ssCollection1'
            },
            @{
                Name             = 'addSku2'
                Type             = [array]
                Position         = 1
                Mandatory        = $false
                ValidateSet      = . Get-CloudSku
                ParameterSetName = 'ssCollection1'
            },
            @{
                Name             = 'addOption1'
                Type             = [array]
                Position         = 2
                Mandatory        = $false
                ValidateSet      = . Get-CloudSkuTable
                ParameterSetName = 'ssCollection1'
            },
            @{
                Name             = 'addOption2'
                Type             = [array]
                Position         = 3
                Mandatory        = $false
                ValidateSet      = . Get-CloudSkuTable
                ParameterSetName = 'ssCollection1'
            },
            @{
                Name             = 'addOption3'
                Type             = [array]
                Position         = 4
                Mandatory        = $false
                ValidateSet      = . Get-CloudSkuTable
                ParameterSetName = 'ssCollection1'
            }
        )
        $DynamicParameters | ForEach-Object {New-Object PSObject -Property $_} | New-DynamicParameter
    }

    # Function's Begin Block
    Begin {
        try {
            New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters -ErrorAction SilentlyContinue
        }
        catch {

        }
        # Create hashtable from Name to SkuId lookup
        $skuIdHash = @{}
        Get-AzureADSubscribedSku | Select SkuPartNumber,SkuId | ForEach-Object {
            $skuIdHash[$_.SkuPartNumber] = $_.SkuId
            # Write-Host "$_.SkuPartNumber"
        }

        # Assign Tenant and Location to a variable
        $tenant = ((Get-AzureADTenantDetail).verifiedDomains | where {$_.initial -eq "$true"}).name.split(".")[0]
        $location = "US"
        
        $friendlySku = @{
            "AX ENTERPRISE USER"                               = "AX_ENTERPRISE_USER";
            "AX SELF-SERVE USER"                               = "AX_SELF-SERVE_USER";
            "AX_SANDBOX_INSTANCE_TIER2"                        = "AX_SANDBOX_INSTANCE_TIER2";
            "AX_TASK_USER"                                     = "AX_TASK_USER";
            "Azure Active Directory Rights Management"         = "RMS_S_ENTERPRISE";
            "Azure Rights Management Services Ad-hoc"          = "RIGHTSMANAGEMENT_ADHOC";
            "Dynamics CRM Online Plan 2"                       = "CRMPLAN2";
            "Enterprise Mobility + Security E3"                = "EMS";
            "Enterprise Mobility + Security E5"                = "EMSPREMIUM";
            "ENTERPRISEPACK_B_PILOT"                           = "ENTERPRISEPACK_B_PILOT";
            "Exch Online Plan 2 for Faculty"                   = "EXCHANGEENTERPRISE_FACULTY";
            "Exchange Online (Plan 1)"                         = "EXCHANGE_L_STANDARD";
            "Exchange Online ATP"                              = "ATP_ENTERPRISE";
            "Exchange Online Plan 1"                           = "EXCHANGESTANDARD";
            "Exchange Online Plan 2 S"                         = "EXCHANGE_S_ENTERPRISE";
            "Exchange Online Plan 2"                           = "EXCHANGEENTERPRISE";
            "Information Rights Management for Faculty"        = "RIGHTSMANAGEMENT_STANDARD_FACULTY";
            "Information Rights Management for Students"       = "RIGHTSMANAGEMENT_STANDARD_STUDENT";
            "Intune (Volume License)"                          = "INTUNE_A_VL";
            "Lync Online (Plan 1)"                             = "MCOLITE";
            "Microsoft Dynamics CRM Online Additional Storage" = "CRMSTORAGE";
            "Microsoft Flow Free"                              = "FLOW_FREE";
            "Microsoft Imagine Academy"                        = "IT_ACADEMY_AD";
            "Microsoft PowerApps and Logic flows"              = "POWERAPPS_INDIVIDUAL_USER";
            "Microsoft Stream"                                 = "STREAM";
            "MICROSOFT_BUSINESS_CENTER"                        = "MICROSOFT_BUSINESS_CENTER";
            "O365 Education E1 for Students"                   = "STANDARDWOFFPACK_STUDENT";
            "O365 Education for Faculty"                       = "STANDARDWOFFPACK_IW_FACULTY";
            "O365 Education for Students"                      = "STANDARDWOFFPACK_IW_STUDENT";
            "Office 365 (Plan A1) for Students"                = "STANDARDPACK_STUDENT";
            "Office 365 (Plan E3)"                             = "ENTERPRISEPACKLRG";
            "Office 365 Education E4 for Faculty"              = "ENTERPRISEWITHSCAL_FACULTY";
            "Office 365 Education E4 for Students"             = "ENTERPRISEWITHSCAL_STUDENT";
            "Office 365 Enterprise E1"                         = "STANDARDPACK";
            "Office 365 Enterprise E2"                         = "STANDARDWOFFPACK";
            "Office 365 Enterprise E3 without ProPlus Add-on"  = "ENTERPRISEPACKWITHOUTPROPLUS";
            "Office 365 Enterprise E3"                         = "ENTERPRISEPACK";
            "Office 365 Enterprise E4"                         = "ENTERPRISEWITHSCAL";
            "Office 365 Enterprise E5"                         = "ENTERPRISEPREMIUM";
            "Office 365 Enterprise K1 with Yammer"             = "DESKLESSPACK_YAMMER";
            "Office 365 Enterprise K1 without Yammer"          = "DESKLESSPACK";
            "Office 365 Enterprise K2"                         = "DESKLESSWOFFPACK";
            "Office 365 Midsize Business"                      = "MIDSIZEPACK";
            "Office 365 Plan A2 for Faculty"                   = "STANDARDWOFFPACKPACK_FACULTY";
            "Office 365 Plan A2 for Students"                  = "STANDARDWOFFPACKPACK_STUDENT";
            "Office 365 Plan A3 for Faculty"                   = "ENTERPRISEPACK_FACULTY";
            "Office 365 Plan A3 for Students"                  = "ENTERPRISEPACK_STUDENT";
            "Office 365 ProPlus for Faculty"                   = "OFFICESUBSCRIPTION_FACULTY";
            "Office 365 Small Business Premium"                = "LITEPACK_P2";
            "Office Online STD"                                = "WACSHAREPOINTSTD";
            "Office Online"                                    = "SHAREPOINTWAC";
            "Office ProPlus"                                   = "OFFICE_PRO_PLUS_SUBSCRIPTION_SMBIZ";
            "Power BI for Office 365 Individual"               = "POWER_BI_INDIVIDUAL_USER";
            "Power BI for Office 365 Standalone"               = "POWER_BI_STANDALONE";
            "Power BI for Office 365 Standard"                 = "POWER_BI_STANDARD";
            "POWER_BI_PRO"                                     = "POWER_BI_PRO";
            "Project Lite"                                     = "PROJECTESSENTIALS";
            "Project Online for Faculty Plan 1"                = "PROJECTONLINE_PLAN_1_FACULTY";
            "Project Online for Faculty Plan 2"                = "PROJECTONLINE_PLAN_2_FACULTY";
            "Project Online for Students Plan 1"               = "PROJECTONLINE_PLAN_1_STUDENT";
            "Project Online for Students Plan 2"               = "PROJECTONLINE_PLAN_2_STUDENT";
            "Project Online Premium"                           = "PROJECTPREMIUM";
            "Project Online Professional"                      = "PROJECTPROFESSIONAL";
            "Project Online with Project for Office 365"       = "PROJECTONLINE_PLAN_1";
            "Project Pro for Office 365"                       = "PROJECTCLIENT";
            "PROJECT_MADEIRA_PREVIEW_IW"                       = "PROJECT_MADEIRA_PREVIEW_IW_SKU";
            "Secure Productive Enterprise E3"                  = "SPE_E3";
            "SharePoint Online (Plan 1) Lite"                  = "SHAREPOINTLITE";
            "SharePoint Online (Plan 1) MidMarket"             = "SHAREPOINTENTERPRISE_MIDMARKET";
            "SharePoint Online (Plan 2)"                       = "SHAREPOINTENTERPRISE";
            "SharePoint Online Plan 1"                         = "SHAREPOINTSTANDARD";
            "STANDARD_B_PILOT"                                 = "STANDARD_B_PILOT";
            "STANDARDPACK_FACULTY"                             = "STANDARDPACK_FACULTY";
            "Visio Pro for Office 365"                         = "VISIOCLIENT";
            "Yammer Enterprise"                                = "YAMMER_ENTERPRISE";
            "Yammer Midsize"                                   = "YAMMER_MIDSIZE"
        }

        $friendlyOption = @{
            "Azure Active Directory Premium P2"                                 = "AAD_PREMIUM_P2";
            "Azure Active Directory Premium Plan 1"                             = "AAD_PREMIUM";
            "Azure Information Protection Plan 1"                               = "RMS_S_PREMIUM";
            "Azure Information Protection Premium P2"                           = "RMS_S_PREMIUM2";
            "Azure Multi-Factor Authentication"                                 = "MFA_PREMIUM";
            "Azure Rights Management"                                           = "RMS_S_ENTERPRISE";
            "CRM for Partners"                                                  = "CRMIUR";
            "CRM Online"                                                        = "CRMSTANDARD";
            "CRM Test Instance"                                                 = "CRMTESTINSTANCE";
            "Customer Lockbox"                                                  = "LOCKBOX_ENTERPRISE";
            "Exchange Foundation for certain SKUs"                              = "EXCHANGE_S_FOUNDATION";
            "Exchange Kiosk"                                                    = "EXCHANGE_S_DESKLESS_GOV";
            "Exchange Online (Plan 1) for Students"                             = "EXCHANGESTANDARD_STUDENT";
            "Exchange Online (Plan 1)"                                          = "EXCHANGE_S_STANDARD_MIDMARKET";
            "Exchange Online (Plan 2) Ent"                                      = "EXCHANGE_S_ENTERPRISE";
            "Exchange Online (Plan 2)"                                          = "EXCHANGE_S_STANDARD";
            "Exchange Online Advanced Threat Protection"                        = "ATP_ENTERPRISE";
            "Exchange Online Archiving Govt"                                    = "EXCHANGE_S_ARCHIVE_ADDON_GOV";
            "Exchange Online Archiving"                                         = "EXCHANGEARCHIVE";
            "Exchange Online Kiosk"                                             = "EXCHANGE_S_DESKLESS";
            "Exchange Online POP"                                               = "EXCHANGETELCO";
            "Exchange Online Protection for Faculty"                            = "EOP_ENTERPRISE_FACULTY";
            "Exchange Online Protection"                                        = "EOP_ENTERPRISE";
            "Exchange Plan 2G"                                                  = "EXCHANGE_S_ENTERPRISE_GOV";
            "Flow for Office 365"                                               = "FLOW_O365_P3";
            "Flow"                                                              = "FLOW_O365_P2";
            "Intune for Office 365"                                             = "INTUNE_A";
            "Lync Online (Plan 1)"                                              = "MCOSTANDARD_MIDMARKET";
            "Lync Online (Plan 3)"                                              = "MCVOICECONF";
            "Lync Plan 2G"                                                      = "MCOSTANDARD_GOV";
            "Microsoft Business Center"                                         = "MICROSOFT_BUSINESS_CENTER";
            "Microsoft Cloud App Security"                                      = "ADALLOM_S_STANDALONE";
            "Microsoft Dynamics CRM Online Additional Storage"                  = "CRMSTORAGE";
            "Microsoft Dynamics Marketing Sales Collaboration"                  = "MDM_SALES_COLLABORATION";
            "Microsoft Forms (Plan E3)"                                         = "FORMS_PLAN_E3";
            "Microsoft Forms (Plan E5)"                                         = "FORMS_PLAN_E5";
            "Microsoft MyAnalytics"                                             = "EXCHANGE_ANALYTICS";
            "Microsoft Office 365 (Plan A1) for Faculty"                        = "STANDARDPACK_FACULTY";
            "Microsoft Office 365 (Plan A1) for Students"                       = "STANDARDPACK_STUDENT";
            "Microsoft Office 365 (Plan A2) for Students"                       = "STANDARDWOFFPACK_STUDENT";
            "Microsoft Office 365 (Plan E1)"                                    = "STANDARDPACK";
            "Microsoft Office 365 (Plan E2)"                                    = "STANDARDWOFFPACK";
            "Microsoft Office 365 (Plan G1) for Government"                     = "STANDARDPACK_GOV";
            "Microsoft Office 365 (Plan G2) for Government"                     = "STANDARDWOFFPACK_GOV";
            "Microsoft Office 365 (Plan G3) for Government"                     = "ENTERPRISEPACK_GOV";
            "Microsoft Office 365 (Plan G4) for Government"                     = "ENTERPRISEWITHSCAL_GOV";
            "Microsoft Office 365 (Plan K1) for Government"                     = "DESKLESSPACK_GOV";
            "Microsoft Office 365 (Plan K2) for Government"                     = "ESKLESSWOFFPACK_GOV";
            "Microsoft Office 365 Exchange Online (Plan 1) only for Government" = "EXCHANGESTANDARD_GOV";
            "Microsoft Office 365 Exchange Online (Plan 2) only for Government" = "EXCHANGEENTERPRISE_GOV";
            "Microsoft Planner"                                                 = "PROJECTWORKMANAGEMENT";
            "Microsoft Social Listening Professional"                           = "NBPROFESSIONALFORCRM";
            "Microsoft StaffHub"                                                = "Deskless";
            "Microsoft Stream for O365 E3 SKU"                                  = "STREAM_O365_E3";
            "Microsoft Stream for O365 E5 SKU"                                  = "STREAM_O365_E5";
            "Microsoft Teams"                                                   = "TEAMS1";
            "Mobile Device Management for Office 365"                           = "INTUNE_O365";
            "Office 365 (Plan P1)"                                              = "LITEPACK";
            "Office 365 Advanced eDiscovery"                                    = "EQUIVIO_ANALYTICS";
            "Office 365 Advanced Security Management"                           = "ADALLOM_S_O365";
            "Office 365 Education E1 for Faculty"                               = "STANDARDWOFFPACK_FACULTY";
            "Office 365 Education for Faculty"                                  = "STANDARDWOFFPACK_IW_FACULTY";
            "Office 365 Education for Students"                                 = "STANDARDWOFFPACK_IW_STUDENT";
            "Office 365 ProPlus"                                                = "OFFICESUBSCRIPTION";
            "Office 365 Threat Intelligence"                                    = "THREAT_INTELLIGENCE";
            "Office Online for Government"                                      = "SHAREPOINTWAC_GOV";
            "Office Online"                                                     = "SHAREPOINTWAC";
            "Office ProPlus Student Benefit"                                    = "OFFICESUBSCRIPTION_STUDENT";
            "Office ProPlus"                                                    = "OFFICESUBSCRIPTION_GOV";
            "OneDrive Pack"                                                     = "WACONEDRIVESTANDARD";
            "OneDrive"                                                          = "ONEDRIVESTANDARD";
            "Power BI Information Services"                                     = "SQL_IS_SSIM";
            "Power BI Pro"                                                      = "BI_AZURE_P2";
            "Power BI Reporting and Analytics"                                  = "BI_AZURE_P1";
            "PowerApps for Office 365"                                          = "POWERAPPS_O365_P3";
            "PowerApps"                                                         = "POWERAPPS_O365_P2";
            "Project Lite"                                                      = "PROJECT_ESSENTIALS";
            "Project Online (Plan 1)"                                           = "PROJECTONLINE_PLAN_1";
            "Project Online (Plan 2)"                                           = "PROJECTONLINE_PLAN_2";
            "Project Pro for Office 365"                                        = "PROJECT_CLIENT_SUBSCRIPTION";
            "SharePoint Online (Plan 1)"                                        = "SHAREPOINTENTERPRISE_MIDMARKET";
            "SharePoint Online (Plan 2) Project"                                = "SHAREPOINT_PROJECT";
            "SharePoint Online (Plan 2)"                                        = "SHAREPOINTENTERPRISE";
            "SharePoint Online Kiosk Gov"                                       = "SHAREPOINTDESKLESS_GOV";
            "SharePoint Online Kiosk"                                           = "SHAREPOINTDESKLESS";
            "SharePoint Online Partner Access"                                  = "SHAREPOINTPARTNER";
            "SharePoint Online Storage"                                         = "SHAREPOINTSTORAGE";
            "SharePoint Plan 2G"                                                = "SHAREPOINTENTERPRISE_GOV";
            "Skype for Business Cloud PBX"                                      = "MCOEV";
            "Skype for Business Online (Plan 2)"                                = "MCOSTANDARD";
            "Skype for Business PSTN Conferencing"                              = "MCOMEETADV";
            "Sway"                                                              = "SWAY";
            "Visio Pro for Office 365 Subscription"                             = "VISIO_CLIENT_SUBSCRIPTION";
            "Visio Pro for Office 365"                                          = "VISIOCLIENT";
            "Windows 10 Enterprise E3"                                          = "WIN10_PRO_ENT_SUB";
            "Windows Azure Active Directory Rights Management"                  = "RMS_S_ENTERPRISE_GOV";
            "Yammer Enterprise"                                                 = "YAMMER_ENTERPRISE";
            "Yammer"                                                            = "YAMMER_MIDSIZE"
        }
        if ($RemoveSkus) {
            $skusToRemove = (. Get-CloudSku | Out-GridView -Title "SKUs to Remove" -PassThru)
        }
        if ($RemoveOptions) {
            $optionsToRemove = (. Get-CloudSkuTable | Out-GridView -Title "Options to Remove" -PassThru)
        }
        if ($AddSkus) {
            $skusToAdd = (. Get-CloudSku | Out-GridView -Title "SKUs to Add" -PassThru)
        }
        if ($AddOptions) {
            $optionsToAdd = (. Get-CloudSkuTable | Out-GridView -Title "Options to Add" -PassThru)
        }
       
    }

    Process {
        $DisabledOptions = @()  
        $resultArray = @()   
        $rSkuGroup = @() 
        
        $user = Get-AzureADUser -ObjectId $_.userprincipalname
        $userlic = Get-AzureADUserLicenseDetail -ObjectId $_.userprincipalname
        Set-AzureADUser -ObjectId $_.userprincipalname -UsageLocation $location
        
        if ($skusToRemove) {
            Foreach ($rSku in $skusToRemove) {
                if ($friendlySku.$rSku -in (Get-AzureADUserLicenseDetail -ObjectId $_.userprincipalname).skupartnumber) {
                    $rSkuGroup += $friendlySku.$rSku 
                } 
            }
            Write-Verbose "$($_.userprincipalname) has the following Skus, removing these Sku now: $rSkuGroup "
            $LicensesToAssign = New-LicenseToAssign -Name $rSkuGroup
            Write-Output "$licensesToAssign"
            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $LicensesToAssign
        }

        if ($optionsToRemove) {
            $hash = @{}
            foreach ($rOpt in $optionsToRemove) {
                if ($hash.containskey($friendlySku[$rOpt.split("*")[0].trim(")")])) {
                    $hash.($friendlySku[$rOpt.split("*")[0].trim(")")]) += $friendlyOption[$rOpt.split("*")[1]] + ","
                }
                else {
                    $hash[$friendlySku[$rOpt.split("*")[0].trim(")")]] = $friendlyOption[$rOpt.split("*")[1]] + ","
                }
            }
            $hash.GetEnumerator() | ForEach-Object { 
                write-host $_.name 
                write-host $_.Value }
        }
                
        if ($skusToAdd) {
            Foreach ($rSku in $skusToAdd) {
                write-host "rSku: $($friendlySku.$rSku)"
            }
        }
        


        <# 
        $addOpts = $addOption1 + $addOption2 + $addOption3
        $hash = @{}
        for ($i = 0; $i -lt $addOpts.count; $i++) {
            if ($addOpts[$i]) {
                if ($hash.containskey($friendlySku[$addOpts[$i].split("*")[1].trim(")")])) {
                    $hash.($friendlySku[$addOpts[$i].split("*")[1].trim(")")]) += $friendlyOption[$addOpts[$i].split("*")[0]] + ","
                }
                else {
                    $hash[$friendlySku[$addOpts[$i].split("*")[1].trim(")")]] = $friendlyOption[$addOpts[$i].split("*")[0]] + ","
                }
            }
        }


        $hash.GetEnumerator() | ForEach-Object { 
            write-host $_.name 
            write-host $_.Value }
                #>

        # for ($i = 0; $i -lt ($hash.keys).Count; $i++)
        #foreach ($h in $hash) {
        #    write-host "1" $h.keys $h.values
        #}

        <# foreach ($opt in $addOpts) {
        #if ((Get-AzureADSubscribedSku).skupartnumber -notin $friendlyOption[$opt.Split("(")[1].trim(")")]) {
        $StandardLicense = Get-AzureADSubscribedSku | Where {$_.SkuId -eq "c7df2760-2c81-4ef7-b578-5b5392b571df"}
        # ((Get-AzureADSubscribedSku)| where {$_.SkuPartNumber -eq ($friendlyOption[$opt.Split("(")[1].trim(")")])})
        $TheFeaturesToDisable = "TEAMS1"  #$friendlySku[$opt.split("(")[0]]
        $SkuFeaturesToDisable = $StandardLicense.ServicePlans | ForEach-Object { $_ | Where {$_.ServicePlanName -in $TheFeaturesToDisable }}
        # $addSku = $StandardLicense.skuid
        $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
        $license.skuId = $StandardLicense.skuId
        $license.DisabledPlans = $SkuFeaturesToDisable.ServicePlanId
        $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $LicensesToAssign.AddLicenses = $License
        Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $LicensesToAssign

        # }
        #} 
        #>
    } #End of Process Block 
    End {
    }
}
