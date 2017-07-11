function Get-UserLicense {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param
    (
        [Parameter(Mandatory = $true)]
        $usr,

        [Parameter(Mandatory = $false)]
        [switch] $notDisabled,

        [Parameter(Mandatory = $false)]
        [switch] $onlyDisabled,

        [Parameter(Mandatory = $false)]
        [switch] $allLicenses

    )

    # Begin Block
    Begin {

        $u2fSku = @{ 
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
            "EMSPREMIUM"                         = "Enterprise Mobility + Security E5";
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
            "EXCHANGE_S_ENTERPRISE"              = "Exchange Online Plan 2 S";
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
            "SHAREPOINTENTERPRISE_MIDMARKET"     = "SharePoint Online (Plan 1) MidMarket";
            "SHAREPOINTLITE"                     = "SharePoint Online (Plan 1) Lite";
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
            "WACSHAREPOINTSTD"                   = "Office Online STD";
            "YAMMER_ENTERPRISE"                  = "Yammer Enterprise";
            "YAMMER_MIDSIZE"                     = "Yammer Midsize"
        } 
        $u2fOpt = @{
            "AAD_PREMIUM"                    = "Azure Active Directory Premium Plan 1";
            "AAD_PREMIUM_P2"                 = "Azure Active Directory Premium P2";
            "ADALLOM_S_O365"                 = "Office 365 Advanced Security Management";
            "ADALLOM_S_STANDALONE"           = "Microsoft Cloud App Security";
            "ATP_ENTERPRISE"                 = "Exchange Online Advanced Threat Protection";
            "BI_AZURE_P1"                    = "Power BI Reporting and Analytics";
            "BI_AZURE_P2"                    = "Power BI Pro";
            "CRMIUR"                         = "CRM for Partners";
            "CRMSTANDARD"                    = "CRM Online";
            "CRMSTORAGE"                     = "Microsoft Dynamics CRM Online Additional Storage";
            "CRMTESTINSTANCE"                = "CRM Test Instance";
            "Deskless"                       = "Microsoft StaffHub";
            "DESKLESSPACK_GOV"               = "Microsoft Office 365 (Plan K1) for Government";
            "ENTERPRISEPACK_GOV"             = "Microsoft Office 365 (Plan G3) for Government";
            "ENTERPRISEWITHSCAL_GOV"         = "Microsoft Office 365 (Plan G4) for Government";
            "EOP_ENTERPRISE"                 = "Exchange Online Protection";
            "EOP_ENTERPRISE_FACULTY"         = "Exchange Online Protection for Faculty";
            "EQUIVIO_ANALYTICS"              = "Office 365 Advanced eDiscovery";
            "ESKLESSWOFFPACK_GOV"            = "Microsoft Office 365 (Plan K2) for Government";
            "EXCHANGE_ANALYTICS"             = "Microsoft MyAnalytics";
            "EXCHANGE_S_ARCHIVE_ADDON_GOV"   = "Exchange Online Archiving Govt";
            "EXCHANGE_S_DESKLESS"            = "Exchange Online Kiosk";
            "EXCHANGE_S_DESKLESS_GOV"        = "Exchange Kiosk";
            "EXCHANGE_S_ENTERPRISE"          = "Exchange Online (Plan 2) Ent";
            "EXCHANGE_S_ENTERPRISE_GOV"      = "Exchange Plan 2G";
            "EXCHANGE_S_FOUNDATION"          = "Exchange Foundation for certain SKUs";
            "EXCHANGE_S_STANDARD"            = "Exchange Online (Plan 2)";
            "EXCHANGE_S_STANDARD_MIDMARKET"  = "Exchange Online (Plan 1)";
            "EXCHANGEARCHIVE"                = "Exchange Online Archiving";
            "EXCHANGEENTERPRISE_GOV"         = "Microsoft Office 365 Exchange Online (Plan 2) only for Government";
            "EXCHANGESTANDARD_GOV"           = "Microsoft Office 365 Exchange Online (Plan 1) only for Government";
            "EXCHANGESTANDARD_STUDENT"       = "Exchange Online (Plan 1) for Students";
            "EXCHANGETELCO"                  = "Exchange Online POP";
            "FLOW_O365_P2"                   = "Flow";
            "FLOW_O365_P3"                   = "Flow for Office 365";
            "FORMS_PLAN_E3"                  = "Microsoft Forms (Plan E3)";
            "FORMS_PLAN_E5"                  = "Microsoft Forms (Plan E5)";
            "INTUNE_A"                       = "Intune for Office 365";
            "INTUNE_O365"                    = "Mobile Device Management for Office 365";
            "LITEPACK"                       = "Office 365 (Plan P1)";
            "LOCKBOX_ENTERPRISE"             = "Customer Lockbox";
            "MCOEV"                          = "Skype for Business Cloud PBX";
            "MCOMEETADV"                     = "Skype for Business PSTN Conferencing";
            "MCOSTANDARD"                    = "Skype for Business Online (Plan 2)";
            "MCOSTANDARD_GOV"                = "Lync Plan 2G";
            "MCOSTANDARD_MIDMARKET"          = "Lync Online (Plan 1)";
            "MCVOICECONF"                    = "Lync Online (Plan 3)";
            "MDM_SALES_COLLABORATION"        = "Microsoft Dynamics Marketing Sales Collaboration";
            "MFA_PREMIUM"                    = "Azure Multi-Factor Authentication";
            "MICROSOFT_BUSINESS_CENTER"      = "Microsoft Business Center";
            "NBPROFESSIONALFORCRM"           = "Microsoft Social Listening Professional";
            "OFFICESUBSCRIPTION"             = "Office 365 ProPlus";
            "OFFICESUBSCRIPTION_GOV"         = "Office ProPlus";
            "OFFICESUBSCRIPTION_STUDENT"     = "Office ProPlus Student Benefit";
            "ONEDRIVESTANDARD"               = "OneDrive";
            "POWERAPPS_O365_P2"              = "PowerApps";
            "POWERAPPS_O365_P3"              = "PowerApps for Office 365";
            "PROJECT_CLIENT_SUBSCRIPTION"    = "Project Pro for Office 365";
            "PROJECT_ESSENTIALS"             = "Project Lite";
            "PROJECTONLINE_PLAN_1"           = "Project Online (Plan 1)";
            "PROJECTONLINE_PLAN_2"           = "Project Online (Plan 2)";
            "PROJECTWORKMANAGEMENT"          = "Microsoft Planner";
            "RMS_S_ENTERPRISE"               = "Azure Rights Management";
            "RMS_S_ENTERPRISE_GOV"           = "Windows Azure Active Directory Rights Management";
            "RMS_S_PREMIUM"                  = "Azure Information Protection Plan 1";
            "RMS_S_PREMIUM2"                 = "Azure Information Protection Premium P2";
            "SHAREPOINT_PROJECT"             = "SharePoint Online (Plan 2) Project";
            "SHAREPOINTDESKLESS"             = "SharePoint Online Kiosk";
            "SHAREPOINTDESKLESS_GOV"         = "SharePoint Online Kiosk Gov";
            "SHAREPOINTENTERPRISE"           = "SharePoint Online (Plan 2)";
            "SHAREPOINTENTERPRISE_GOV"       = "SharePoint Plan 2G";
            "SHAREPOINTENTERPRISE_MIDMARKET" = "SharePoint Online (Plan 1)";
            "SHAREPOINTPARTNER"              = "SharePoint Online Partner Access";
            "SHAREPOINTSTORAGE"              = "SharePoint Online Storage";
            "SHAREPOINTWAC"                  = "Office Online";
            "SHAREPOINTWAC_GOV"              = "Office Online for Government";
            "SQL_IS_SSIM"                    = "Power BI Information Services";
            "STANDARDPACK"                   = "Microsoft Office 365 (Plan E1)";
            "STANDARDPACK_FACULTY"           = "Microsoft Office 365 (Plan A1) for Faculty";
            "STANDARDPACK_GOV"               = "Microsoft Office 365 (Plan G1) for Government";
            "STANDARDPACK_STUDENT"           = "Microsoft Office 365 (Plan A1) for Students";
            "STANDARDWOFFPACK"               = "Microsoft Office 365 (Plan E2)";
            "STANDARDWOFFPACK_FACULTY"       = "Office 365 Education E1 for Faculty";
            "STANDARDWOFFPACK_GOV"           = "Microsoft Office 365 (Plan G2) for Government";
            "STANDARDWOFFPACK_IW_FACULTY"    = "Office 365 Education for Faculty";
            "STANDARDWOFFPACK_IW_STUDENT"    = "Office 365 Education for Students";
            "STANDARDWOFFPACK_STUDENT"       = "Microsoft Office 365 (Plan A2) for Students";
            "STREAM_O365_E3"                 = "Microsoft Stream for O365 E3 SKU";
            "STREAM_O365_E5"                 = "Microsoft Stream for O365 E5 SKU";
            "SWAY"                           = "Sway";
            "TEAMS1"                         = "Microsoft Teams";
            "THREAT_INTELLIGENCE"            = "Office 365 Threat Intelligence";
            "VISIO_CLIENT_SUBSCRIPTION"      = "Visio Pro for Office 365 Subscription";
            "VISIOCLIENT"                    = "Visio Pro for Office 365";
            "WACONEDRIVESTANDARD"            = "OneDrive Pack";
            "WIN10_PRO_ENT_SUB"              = "Windows 10 Enterprise E3";
            "YAMMER_ENTERPRISE"              = "Yammer Enterprise";
            "YAMMER_MIDSIZE"                 = "Yammer"
        }
    }

    Process {
        $resultArray = @() 
        $userLicense = Get-AzureADUserLicenseDetail -ObjectId $usr
        if ($notDisabled) {
            foreach ($ul in $userLicense) {
                $uLicHash = [ordered]@{}
                $uLicHash['Sku'] = $u2fSku.($ul.skupartnumber)
                foreach ($u in $ul.serviceplans) {
                    if ($u.ProvisioningStatus -ne 'Disabled') {
                        $uLicHash['Option'] = $u2fOpt.($u.Serviceplanname)
                        $uLicHash['Status'] = $u.ProvisioningStatus
                        $resultArray += [pscustomobject]$uLicHash   
                    }
                }
            }  
        }
        if ($onlyDisabled) {
            foreach ($ul in $userLicense) {
                $uLicHash = [ordered]@{}
                $uLicHash['Sku'] = $u2fSku.($ul.skupartnumber)
                foreach ($u in $ul.serviceplans) {
                    if ($u.ProvisioningStatus -eq 'Disabled') {
                        $uLicHash['Option'] = $u2fOpt.($u.Serviceplanname)
                        $uLicHash['Status'] = $u.ProvisioningStatus
                        $resultArray += [pscustomobject]$uLicHash   
                    }
                }
            }  
        }
       if ($allLicenses) {
            foreach ($ul in $userLicense) {
                $uLicHash = [ordered]@{}
                $uLicHash['Sku'] = $u2fSku.($ul.skupartnumber)
                foreach ($u in $ul.serviceplans) {
                    $uLicHash['Option'] = $u2fOpt.($u.Serviceplanname)
                    $uLicHash['Status'] = $u.ProvisioningStatus
                    $resultArray += [pscustomobject]$uLicHash
                }
            }  
        }
    } 
    End {
        $resultArray 
    }
}
