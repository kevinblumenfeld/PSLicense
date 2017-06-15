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
            "DESKLESSPACK"                   = "Office 365 (Plan K1)" 
            "DESKLESSWOFFPACK"               = "Office 365 (Plan K2)" 
            "LITEPACK"                       = "Office 365 (Plan P1)" 
            "EXCHANGESTANDARD"               = "Office 365 Exchange Online Only" 
            "STANDARDPACK"                   = "Office 365 Enterprise E1" 
            "STANDARDWOFFPACK"               = "Office 365 Enterprise E2" 
            "ENTERPRISEPACK"                 = "Office 365 (Plan E3)" 
            "ENTERPRISEPACKLRG"              = "Office 365 (Plan E3)" 
            "ENTERPRISEWITHSCAL"             = "Office 365 (Plan E4)" 
            "STANDARDPACK_STUDENT"           = "Office 365 (Plan A1) for Students" 
            "STANDARDWOFFPACKPACK_STUDENT"   = "Office 365 (Plan A2) for Students" 
            "ENTERPRISEPACK_STUDENT"         = "Office 365 (Plan A3) for Students" 
            "ENTERPRISEWITHSCAL_STUDENT"     = "Office 365 (Plan A4) for Students" 
            "STANDARDPACK_FACULTY"           = "STANDARDPACK_FACULTY" 
            "STANDARDWOFFPACKPACK_FACULTY"   = "STANDARDWOFFPACKPACK_FACULTY" 
            "ENTERPRISEPACK_FACULTY"         = "O365 Education E3 for Faculty" 
            "ENTERPRISEWITHSCAL_FACULTY"     = "ENTERPRISEWITHSCAL_FACULTY" 
            "ENTERPRISEPACK_B_PILOT"         = "ENTERPRISEPACK_B_PILOT" 
            "STANDARD_B_PILOT"               = "STANDARD_B_PILOT"
            "STANDARDWOFFPACK_STUDENT"       = "O365 Education E1 for Students"
            "STANDARDWOFFPACK_IW_STUDENT"    = "O365 Education for Students"
            "EXCHANGEENTERPRISE_FACULTY"     = "Exch Online Plan 2 for Faculty"
            "STANDARDWOFFPACK_IW_FACULTY"    = "O365 Education for Faculty"
            "POWER_BI_STANDARD"              = "Power BI (free)"
            "IT_ACADEMY_AD"                  = "IT_ACADEMY_AD"
            "EXCHANGESTANDARD_STUDENT"       = "Exchange Online (Plan 1) for Students"
            "OFFICESUBSCRIPTION_STUDENT"     = "Office ProPlus Student Benefit"
            "OFFICESUBSCRIPTION_FACULTY"     = "O365 ProPlus for Faculty"
            "AX_SELF-SERVE_USER"             = "AX SELF-SERVE USER"
            "POWERAPPS_INDIVIDUAL_USER"      = "PowerApps and Logic Flows"
            "POWER_BI_INDIVIDUAL_USER"       = "POWER_BI_INDIVIDUAL_USER"
            "POWER_BI_PRO"                   = "POWER_BI_PRO"
            "AX_ENTERPRISE_USER"             = "AX ENTERPRISE USER"
            "AX_TASK_USER"                   = "AX_TASK_USER"
            "AX_SANDBOX_INSTANCE_TIER2"      = "AX_SANDBOX_INSTANCE_TIER2"
            "EMS"                            = "Enterprise Mobility + Security E3"
            "RIGHTSMANAGEMENT_ADHOC"         = "RIGHTSMANAGEMENT_ADHOC"
            "EMSPREMIUM"                     = "EMSPREMIUM"
            "ENTERPRISEPREMIUM"              = "Office 365 Enterprise E5"
            "EXCHANGEENTERPRISE"             = "Exchange Online (Plan 2)"
            "SHAREPOINTENTERPRISE"           = "SharePoint Online (Plan 2)"
            "VISIOCLIENT"                    = "Visio Pro for Office 365"
            "PROJECTONLINE_PLAN_1"           = "Project Online with Project for Office 365"
            "PROJECTPREMIUM"                 = "Project Online Premium"
            "PROJECTCLIENT"                  = "Project for Office 365"
            "PROJECTESSENTIALS"              = "Project Online Essentials"
            "PROJECTPROFESSIONAL"            = "Project Online Professional"
            "FLOW_FREE"                      = "Microsoft Flow Free"
            "PROJECT_MADEIRA_PREVIEW_IW_SKU" = "PROJECT_MADEIRA_PREVIEW_IW"
            "ATP_ENTERPRISE"                 = "Exchange Online ATP"
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
                    "RMS_S_PREMIUM2" { $thisLicense = "RMS_S_PREMIUM2" }
                    "RMS_S_PREMIUM" { $thisLicense = "RMS_S_PREMIUM" }
                    "RMS_S_ENTERPRISE" { $thisLicense = "RMS_S_ENTERPRISE" }
                    "ADALLOM_S_STANDALONE" { $thisLicense = "ADALLOM_S_STANDALONE" }  
                    "INTUNE_A" { $thisLicense = "INTUNE" }     
                    "AAD_PREMIUM_P2" { $thisLicense = "AAD_PREMIUM_P2" }  
                    "MFA_PREMIUM" { $thisLicense = "MFA_PREMIUM" }     
                    "AAD_PREMIUM" { $thisLicense = "AAD_PREMIUM" }
                    "AX_SELF-SERVE_USER" { $thisLicense = "AX_SELF-SERVE_USER"}
                    "POWERVIDEOSFREE" { $thisLicense = "POWERVIDEOSFREE"}
                    "POWERFLOWSFREE" { $thisLicense = "POWERFLOWSFREE"}
                    "POWERAPPSFREE" { $thisLicense = "POWERAPPSFREE"}
                    "SQL_IS_SSIM" { $thisLicense = "SQL_IS_SSIM"}
                    "BI_AZURE_P1" { $thisLicense = "BI_AZURE_P1"}
                    "EXCHANGE_S_FOUNDATION" { $thisLicense = "EXCHANGE_S_FOUNDATION"}
                    "BI_AZURE_P2" { $thisLicense = "BI_AZURE_P2"}
                    "BI_AZURE_P2_Dynamics" { $thisLicense = "BI_AZURE_P2_Dynamics"}
                    "AX_ENTERPRISE_USER" { $thisLicense = "AX_ENTERPRISE_USER"}
                    "Deskless" { $thisLicense = "Deskless"}
                    "FLOW_O365_P2" { $thisLicense = "FLOW_O365_P2"}
                    "POWERAPPS_O365_P2" { $thisLicense = "POWERAPPS_O365_P2"}
                    "TEAMS1" { $thisLicense = "TEAMS1"}
                    "PROJECTWORKMANAGEMENT" { $thisLicense = "PROJECTWORKMANAGEMENT"}
                    "SWAY" { $thisLicense = "SWAY"}
                    "INTUNE_O365" { $thisLicense = "INTUNE_O365"}
                    "YAMMER_ENTERPRISE" { $thisLicense = "YAMMER_ENTERPRISE"}
                    "RMS_S_ENTERPRISE" { $thisLicense = "RMS_S_ENTERPRISE"}
                    "OFFICESUBSCRIPTION" { $thisLicense = "OFFICESUBSCRIPTION"}
                    "MCOSTANDARD" { $thisLicense = "MCOSTANDARD"}
                    "SHAREPOINTWAC" { $thisLicense = "SHAREPOINTWAC"}
                    "SHAREPOINTENTERPRISE" { $thisLicense = "SHAREPOINTENTERPRISE"}
                    "EXCHANGE_S_ENTERPRISE" { $thisLicense = "EXCHANGE_S_ENTERPRISE"}
                    "AX_TASK_USER" { $thisLicense = "AX_TASK_USER"}
                    "AX_SANDBOX_INSTANCE_TIER2" { $thisLicense = "AX_SANDBOX_INSTANCE_TIER2"}
                    "EXCHANGE_S_FOUNDATION" { $thisLicense = "EXCHANGE_S_FOUNDATION"}
                    "BI_AZURE_P0" { $thisLicense = "BI_AZURE_P0"}
                    "RMS_S_PREMIUM" { $thisLicense = "RMS_S_PREMIUM"}
                    "INTUNE_A" { $thisLicense = "INTUNE_A"}
                    "RMS_S_ENTERPRISE" { $thisLicense = "RMS_S_ENTERPRISE"}
                    "AAD_PREMIUM" { $thisLicense = "AAD_PREMIUM"}
                    "MFA_PREMIUM" { $thisLicense = "MFA_PREMIUM"}
                    "RMS_S_ADHOC" { $thisLicense = "RMS_S_ADHOC"}
                    "MCOVOICECONF" { $thisLicense = "MCOVOICECONF"}

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
