function Get-LACloudLicense { 
    <#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
    Begin {

    }
    Process {
        # Define Hashtables for lookup 
        $Sku = @{ 
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
            "YAMMER_ENTERPRISE"                  = "Yammer Enterprise";
            "YAMMER_MIDSIZE"                     = "Yammer Midsize"
        } 
         
        # The Output will be written to this file in the current working directory
         
        $LogFile = ($(get-date -Format yyyy-MM-dd_HH-mm-ss) + "-licenses.csv")
 
        # Get a list of all Licenses that exist within the tenant 
        $licensetype = Get-MsolAccountSku # | Where {$_.SkuPartNumber -eq "STANDARDWOFFPACK_IW_STUDENT"} 
 
        # Loop through all License types found in the tenant 
        foreach ($license in $licensetype) {     
    
            # Build and write the Header for the CSV file 
            $headerstring = "DisplayName,UserPrincipalName,AccountSku" 
     
            foreach ($row in $($license.ServiceStatus)) { 
         
                # Build header string 
                switch -wildcard ($($row.ServicePlan.servicename)) { 
                    "AAD_PREMIUM" { $thisLicense = "Azure Active Directory Premium"}
                    "BI_AZURE_P1" { $thisLicense = "Power BI Reporting and Analytics"}
                    "CRMIUR" { $thisLicense = "CRM for Partners"}
                    "CRMSTANDARD" { $thisLicense = "CRM Online"}
                    "CRMSTORAGE" { $thisLicense = "Microsoft Dynamics CRM Online Additional Storage"}
                    "CRMTESTINSTANCE" { $thisLicense = "CRM Test Instance"}
                    "Deskless" { $thisLicense = "StaffHub"}
                    "DESKLESSPACK_GOV" { $thisLicense = "Microsoft Office 365 (Plan K1) for Government"}
                    "ENTERPRISEPACK_GOV" { $thisLicense = "Microsoft Office 365 (Plan G3) for Government"}
                    "ENTERPRISEWITHSCAL_GOV" { $thisLicense = "Microsoft Office 365 (Plan G4) for Government"}
                    "EOP_ENTERPRISE" { $thisLicense = "Exchange Online Protection"}
                    "EOP_ENTERPRISE_FACULTY" { $thisLicense = "Exchange Online Protection for Faculty"}
                    "ESKLESSWOFFPACK_GOV" { $thisLicense = "Microsoft Office 365 (Plan K2) for Government"}
                    "EXCHANGE_S_ARCHIVE_ADDON_GOV" { $thisLicense = "Exchange Online Archiving"}
                    "EXCHANGE_S_DESKLESS" { $thisLicense = "Exchange Online Kiosk"}
                    "EXCHANGE_S_DESKLESS_GOV" { $thisLicense = "Exchange Kiosk"}
                    "EXCHANGE_S_ENTERPRISE" { $thisLicense = "Exchange"}
                    "EXCHANGE_S_ENTERPRISE_GOV" { $thisLicense = "Exchange Plan 2G"}
                    "EXCHANGE_S_STANDARD" { $thisLicense = "Exchange Online (Plan 2)"}
                    "EXCHANGE_S_STANDARD_MIDMARKET" { $thisLicense = "Exchange Online (Plan 1)"}
                    "EXCHANGEARCHIVE" { $thisLicense = "Exchange Online Archiving"}
                    "EXCHANGEENTERPRISE_GOV" { $thisLicense = "Microsoft Office 365 Exchange Online (Plan 2) only for Government"}
                    "EXCHANGESTANDARD_GOV" { $thisLicense = "Microsoft Office 365 Exchange Online (Plan 1) only for Government"}
                    "EXCHANGESTANDARD_STUDENT" { $thisLicense = "Exchange Online (Plan 1) for Students"}
                    "EXCHANGETELCO" { $thisLicense = "Exchange Online POP"}
                    "FLOW_O365_P2" { $thisLicense = "Flow"}
                    "INTUNE_A" { $thisLicense = "Intune for Office 365"}
                    "LITEPACK" { $thisLicense = "Office 365 (Plan P1)"}
                    "MCOSTANDARD" { $thisLicense = "Skype"}
                    "MCOSTANDARD_GOV" { $thisLicense = "Lync Plan 2G"}
                    "MCOSTANDARD_MIDMARKET" { $thisLicense = "Lync Online (Plan 1)"}
                    "MCVOICECONF" { $thisLicense = "Lync Online (Plan 3)"}
                    "MDM_SALES_COLLABORATION" { $thisLicense = "Microsoft Dynamics Marketing Sales Collaboration"}
                    "MFA_PREMIUM" { $thisLicense = "Azure Multi-Factor Authentication"}
                    "NBPROFESSIONALFORCRM" { $thisLicense = "Microsoft Social Listening Professional"}
                    "OFFICESUBSCRIPTION" { $thisLicense = "Office ProPlus"}
                    "OFFICESUBSCRIPTION_GOV" { $thisLicense = "Office ProPlus"}
                    "OFFICESUBSCRIPTION_STUDENT" { $thisLicense = "Office ProPlus Student Benefit"}
                    "ONEDRIVESTANDARD" { $thisLicense = "OneDrive"}
                    "POWERAPPS_O365_P2" { $thisLicense = "PowerApps"}
                    "PROJECT_CLIENT_SUBSCRIPTION" { $thisLicense = "Project Pro for Office 365"}
                    "PROJECT_ESSENTIALS" { $thisLicense = "Project Lite"}
                    "PROJECTONLINE_PLAN_1" { $thisLicense = "Project Online (Plan 1)"}
                    "PROJECTONLINE_PLAN_2" { $thisLicense = "Project Online (Plan 2)"}
                    "PROJECTWORKMANAGEMENT" { $thisLicense = "Planner"}
                    "RMS_S_ENTERPRISE" { $thisLicense = "Azure Active Directory Rights Management"}
                    "RMS_S_ENTERPRISE_GOV" { $thisLicense = "Windows Azure Active Directory Rights Management"}
                    "RMS_S_PREMIUM" { $thisLicense = "Azure_Info_Protection_Premium"}
                    "SHAREPOINTDESKLESS" { $thisLicense = "SharePoint Online Kiosk"}
                    "SHAREPOINTDESKLESS_GOV" { $thisLicense = "SharePoint Online Kiosk Gov"}
                    "SHAREPOINTENTERPRISE" { $thisLicense = "SharePoint Online (Plan 2)"}
                    "SHAREPOINTENTERPRISE_GOV" { $thisLicense = "SharePoint Plan 2G"}
                    "SHAREPOINTENTERPRISE_MIDMARKET" { $thisLicense = "SharePoint Online (Plan 1)"}
                    "SHAREPOINTPARTNER" { $thisLicense = "SharePoint Online Partner Access"}
                    "SHAREPOINTSTORAGE" { $thisLicense = "SharePoint Online Storage"}
                    "SHAREPOINTWAC" { $thisLicense = "Office Online"}
                    "SHAREPOINTWAC_GOV" { $thisLicense = "Office Online for Government"}
                    "SQL_IS_SSIM" { $thisLicense = "Power BI Information Services"}
                    "STANDARDPACK" { $thisLicense = "Microsoft Office 365 (Plan E1)"}
                    "STANDARDPACK_FACULTY" { $thisLicense = "Microsoft Office 365 (Plan A1) for Faculty"}
                    "STANDARDPACK_GOV" { $thisLicense = "Microsoft Office 365 (Plan G1) for Government"}
                    "STANDARDPACK_STUDENT" { $thisLicense = "Microsoft Office 365 (Plan A1) for Students"}
                    "STANDARDWOFFPACK" { $thisLicense = "Microsoft Office 365 (Plan E2)"}
                    "STANDARDWOFFPACK_FACULTY" { $thisLicense = "Office 365 Education E1 for Faculty"}
                    "STANDARDWOFFPACK_GOV" { $thisLicense = "Microsoft Office 365 (Plan G2) for Government"}
                    "STANDARDWOFFPACK_IW_FACULTY" { $thisLicense = "Office 365 Education for Faculty"}
                    "STANDARDWOFFPACK_IW_STUDENT" { $thisLicense = "Office 365 Education for Students"}
                    "STANDARDWOFFPACK_STUDENT" { $thisLicense = "Microsoft Office 365 (Plan A2) for Students"}
                    "SWAY" { $thisLicense = "Sway"}
                    "TEAMS1" { $thisLicense = "Teams"}
                    "VISIO_CLIENT_SUBSCRIPTION" { $thisLicense = "Visio Pro for Office 365"}
                    "VISIOCLIENT" { $thisLicense = "Visio Pro for Office 365"}
                    "WACONEDRIVESTANDARD" { $thisLicense = "OneDrive Pack"}
                    "YAMMER_ENTERPRISE" { $thisLicense = "Yammer for the Enterprise"}
                    "YAMMER_MIDSIZE" { $thisLicense = "Yammer"}

                    default { $thisLicense = $row.ServicePlan.servicename } 
                } 
         
                $headerstring = ($headerstring + "," + $thisLicense) 
            } 
     
            Out-File -FilePath $LogFile -InputObject $headerstring -Encoding UTF8 -append 
     
            write-host ("Gathering users with the following subscription: " + $license.accountskuid) 
 
            $users = Get-MsolUser -all | where {$_.isLicensed -eq "True"}

            $skuid = $license.accountskuid

            foreach ($user in $users) {
                $userLicenses = $user.Licenses
                for ($i = 0; $i -lt $($userLicenses.count); $i++) {
                    $userSkuId = $userLicenses[$i].AccountSkuId

                    if ($userSkuId -eq $skuid) {
                        write-host ("Processing " + $user.displayname)
                        $datastring = ("`"" + $user.displayname + "`"" + "," + $user.userprincipalname + "," + $Sku.Item($userLicenses[$i].AccountSku.SkuPartNumber))

                        foreach ($row in $($userLicenses[$i].servicestatus)) {
			
                            # Build data string
                            $datastring = ($datastring + "," + $($row.provisioningstatus))
                        }
		
                        Out-File -FilePath $LogFile -InputObject $datastring -Encoding UTF8 -append
                    }
                }
            }

         
        }              
 
        write-host ("Script Completed.  Results available in " + $LogFile)

    }
    End {

    }
}
