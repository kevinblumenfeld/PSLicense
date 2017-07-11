function Set-LACloudLicense {
    <#
    .SYNOPSIS 
        The user of this script can perform one or more of the following tasks against one or more Office 365 users:

        1.  Add a full license (SKU) with all options (ex. E3)
        2.  Add between one and three options (ex. Teams). If the user does not currently have the SKU assigned, it 
            will be added with only the option(s).
        3.  Remove between one and three option(s)
        4.  Automatically selects a "Base" set of options - Defined by I.T.
            This occurs when no options are selected at all - similar to steps below.  Also, see examples in the EXAMPLE section below
              a.  Remove: SKU: Exchange Online (Plan2)
              b.  Remove: SKU: Office 365 Enterprise E1
              c.  Remove: SKU: Office 365 Enterprise E2
              d.  Remove: SKU: SharePoint Online (Plan 2)
              e.  Add:    SKU: Office 365 Enterprise E3 (sans the option(s): 'OfficeProPlus')
        5.  Remove one or more SKU's

        =============
        Prerequisites
        =============
        
        1.  Download and install the Microsoft Online Services Sign-In Assistant
              https://download.microsoft.com/download/5/0/1/5017D39B-8E29-48C8-91A8-8D0E4968E6D4/en/msoidcli_64.msi

        2.  If not running Windows 10 or higher, Install WMF 5.1 or higher
              https://www.microsoft.com/en-us/download/details.aspx?id=54616 
        
        3.  Install the Windows Azure Active Directory Module for Windows PowerShell. From an elevated PowerShell prompt run
              Install-Module -Name MSOnline
        
        4.  From an elevated PowerShell prompt run:
              Set-ExecutionPolicy RemoteSigned -Force
        
        5.  The script files provided (including the folder they came in) must be copied to "C:\Program Files\WindowsPowerShell\Modules".
              Alternatively, the folder and files can be copied to any folder listed when executing, $env:PSModulepath -split ";" from PS.
        
        6.  To begin using the script(s), from an elevated PowerShell prompt run: 
              Import-Module License365

        7.  If not already connected to Office 365 from an elevated PowerShell prompt run (you will be prompted for appropriate credentials):
              Connect-Office365
            
    .DESCRIPTION
        Summary
                Use this function to license users for Office 365.  
                UserPrincipalName(s) are passed with a variable from the pipeline "|" to the function Set-LaCloudLicense.
                Drop the entire module (including folder structure) in any path found when running: PS C:\> $env:PSModulePath
        
        There are two primary methods to add a list of UPN(s) to a variable

        1.  By using a CSV (Example: $users = Import-CSV .\anylistofupns.csv)
        2.  By using Get-MsolUser and filtered parameters
              a.  Example: $users = Get-MsolUser -Department "IT Department"
              b.  Example: $users = Get-MsolUser -SearchString user1
              c.  For a full list of parameters on which to filter, execute this command: help Get-MsolUser -Full

        If a CSV is used
        
        1.  Must have a column populated with UPN(s)
        2.  The column of UPN(s) must have a header named, UserPrincipalName
        3.  The CSV may contain other columns as they will be ignored

        Example of CSV
        ------- -- ---

        UserPrincipalName
        user1@contoso.com
        user2@contoso.com
        user3@contoso.com
        user4@contoso.com

        Mandatory parameters are
            Users (ValueFromPipeline)
                
        Non-Mandatory parameters are: 
            E3, EMS, RemoveSKU, AddOption, AddOption2, AddOption3, RemoveOption, RemoveOption2, RemoveOption3, PowerAppsandLogicFlows, PowerBI, PowerBIPro, PowerBIFree, RMSAdhoc

    .EXAMPLE
        Adds the base set of options (predefined by I.T.) to a list of Office 365 user(s) from a CSV of UserPrincipalName(s)

        Import-CSV .\UserList.CSV | Set-LaCloudLicense

    .EXAMPLE
        Adds the base set of options to a list of Office 365 user(s) from a filtered list of Get-MsolUser
        
        Get-MsolUser -Department "Human Resources" | Set-LaCloudLicense

    .EXAMPLE
        Adds the SKUs E3 and EMS (with all options) to a list of Office 365 user(s) from a CSV of UserPrincipalName(s)
        
        Import-CSV .\UserList.CSV | Set-LaCloudLicense -E3 -EMS

    .EXAMPLE
        Adds the SKUs E3 and EMS (both, with all options) then removes the option "Flow" from a list of Office 365 user(s)
        
        Import-CSV .\UserList.CSV | Set-LaCloudLicense -E3 -EMS -RemoveOption Flow

    .EXAMPLE
        Adds the 3 options "Microsoft Teams, Sway & Flow" to a list of Office 365 user(s) from a CSV of UserPrincipalName(s)

        Import-CSV .\UserList.CSV | Set-LaCloudLicense -AddOption Teams -AddOption2 Sway -AddOption3 Flow

    .EXAMPLE
        Removes the option "Microsoft Sway" from a list of Office 365 user(s) from a CSV of UserPrincipalName(s)
        
        Import-CSV .\UserList.CSV | Set-LaCloudLicense -RemoveOption Sway
   
    .EXAMPLE
        Removes the SKUs E3 and EMS from a list of Office 365 user(s) from a CSV of UserPrincipalName(s)

        Import-CSV .\UserList.CSV | Set-LaCloudLicense -E3 -EMS -RemoveSKU
   
#>  
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param
    (
        # Users to be licensed
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]] $Users,

        [Parameter(Mandatory = $False)]
        [switch] $E3,
 
        [parameter(Mandatory = $False)]
        [switch] $E5,
          
        [parameter(Mandatory = $False)]
        [switch] $EMS,
         
        [parameter(Mandatory = $False)]
        [switch] $RemoveSKU,
 
        [parameter(Mandatory = $False)]
        [ValidateSet("Teams", "Sway", "Yammer", "Flow", "OfficePro", "StaffHub", "Planner", "PowerApps", "AzureRMS", "OfficeOnline", "SharePoint", "Skype", "Exchange", "Intune", "Azure_Info_Protection", "Azure_AD_Premium", "Azure_Rights_Mgt", "Azure_MultiFactorAuth")]
        [string] $AddOption,

        [parameter(Mandatory = $False)]
        [ValidateSet("Teams", "Sway", "Yammer", "Flow", "OfficePro", "StaffHub", "Planner", "PowerApps", "AzureRMS", "OfficeOnline", "SharePoint", "Skype", "Exchange", "Intune", "Azure_Info_Protection", "Azure_AD_Premium", "Azure_Rights_Mgt", "Azure_MultiFactorAuth")]
        [string] $AddOption2,
         
        [parameter(Mandatory = $False)]
        [ValidateSet("Teams", "Sway", "Yammer", "Flow", "OfficePro", "StaffHub", "Planner", "PowerApps", "AzureRMS", "OfficeOnline", "SharePoint", "Skype", "Exchange", "Intune", "Azure_Info_Protection", "Azure_AD_Premium", "Azure_Rights_Mgt", "Azure_MultiFactorAuth")]
        [string] $AddOption3,
 
        [parameter(Mandatory = $False)]
        [ValidateSet("Teams", "Sway", "Yammer", "Flow", "OfficePro", "StaffHub", "Planner", "PowerApps", "AzureRMS", "OfficeOnline", "SharePoint", "Skype", "Exchange", "Intune", "Azure_Info_Protection", "Azure_AD_Premium", "Azure_Rights_Mgt", "Azure_MultiFactorAuth")]
        [string] $RemoveOption,

        [parameter(Mandatory = $False)]
        [ValidateSet("Teams", "Sway", "Yammer", "Flow", "OfficePro", "StaffHub", "Planner", "PowerApps", "AzureRMS", "OfficeOnline", "SharePoint", "Skype", "Exchange", "Intune", "Azure_Info_Protection", "Azure_AD_Premium", "Azure_Rights_Mgt", "Azure_MultiFactorAuth")]
        [string] $RemoveOption2,

        [parameter(Mandatory = $False)]
        [ValidateSet("Teams", "Sway", "Yammer", "Flow", "OfficePro", "StaffHub", "Planner", "PowerApps", "AzureRMS", "OfficeOnline", "SharePoint", "Skype", "Exchange", "Intune", "Azure_Info_Protection", "Azure_AD_Premium", "Azure_Rights_Mgt", "Azure_MultiFactorAuth")]
        [string] $RemoveOption3,
  
        [Parameter(Mandatory = $False)]
        [switch] $PowerAppsandLogicFlows,
 
        [parameter(Mandatory = $False)]
        [switch] $PowerBI,
         
        [parameter(Mandatory = $False)]
        [switch] $PowerBIPro,

        [parameter(Mandatory = $False)]
        [switch] $PowerBIFree,
                 
        [parameter(Mandatory = $False)]
        [switch] $RMSAdhoc,

        [Parameter()]
        [string] $ErrorLog = $LogPreference
    )

    # Function's Begin Block
    Begin {

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
                        # For contoso
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
                        Write-Output "$($user.userprincipalname) Assigning: contoso:MICROSOFT_BUSINESS_CENTER"
                        Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -AddLicenses "contoso:MICROSOFT_BUSINESS_CENTER"
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