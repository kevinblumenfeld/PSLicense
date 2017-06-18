function Get-LAConnected {
    <#

.SYNOPSIS
   Connects to Office 365 services and/or Azure

.DESCRIPTION
   Connects to Office 365 services and/or Azure.

   Connects to some or all of the Office 365/Azure services based on switches provided at runtime.

   Office 365 tenant name, for example, either contoso or contoso.onmicrosoft.com must be provided with -Tenant parameter
   For AzureOnly, provide a unique name for the -Tenant parameter

   Locally saves and encrypts to a file the username and password.
   The encrypted file...
      
   1. can only be used on the computer and within the user's profile from which it was created.
   2. is the same .txt for all the Office 365 Services.
   3. for Azure is seperate and is a .json file.
   
   If Azure or Azureonly switch is used for first time:
   
   1. User will login as normal when prompted by Azure
   2. User will be prompted to select which Azure Subscription
   3. Select the subscription and click "OK"

   If Azure or Azureonly switch is used:

   1. User will be prompted to pick username used previously
   2. If a new username is to be used (e.g. username not found when prompted), click Cancel to be prompted to login.
   3. User will be prompted to select which Azure Subscription
   4. Select the subscription and click "OK"

   Directories used/created during the execution of this script 
   
   1. C:\ps
   2. C:\ps\creds
   3. C:\ps\<tenantspecified>

   All saved credentials are saved in C:\ps\creds
   Transcipt is started and kept in C:\ps\<tenantspecified>
   
.EXAMPLE
   Get-LAConnected -Tenant Contoso -AzureOnly

   Connects to Azure Only
   For the mandatory parameter, Tenant, simply provide something that uniquely identifies the Azure Tenant
    
.EXAMPLE
   Get-LAConnected -Tenant Contoso

   Connects by default to MS Online Service (MSOL) and Exchange Online (unless AzureOnly switch is used)
   Office 365 tenant name, for example, either contoso or contoso.onmicrosoft.com must be provided with -Tenant parameter

.EXAMPLE
   Get-LAConnected -Tenant Contoso -Skype

   Connects by default to MS Online Service (MSOL) and Exchange Online
   Connects to Skype Online

.EXAMPLE
   Get-LAConnected -Tenant Contoso -SharePoint

   Connects by default to MS Online Service (MSOL) and Exchange Online
   Connects to SharePoint Online

.EXAMPLE
   Get-LAConnected -Tenant Contoso -Compliance

   Connects by default to MS Online Service (MSOL) and Exchange Online
   Connects to Compliance & Security Center

.EXAMPLE
   Get-LAConnected -Tenant Contoso -All365

   Connects to MS Online Service (MSOL), Exchange Online, Skype, SharePoint & Compliance
   
.EXAMPLE
   Get-LAConnected -Tenant Contoso -All365 -Azure

   Connects to Azure, MS Online Service (MSOL), Exchange Online, Skype, SharePoint & Compliance
   
.EXAMPLE
   Get-LAConnected -Tenant Contoso -Skype -Azure

   Connects to Azure, MS Online Service (MSOL), Exchange Online & Skype
   This is to illustrate that any number of individual services can be used to connect.
      
#>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param
    (

        [parameter(Mandatory = $true)]
        [string] $Tenant,
       
        [Parameter(Mandatory = $false)]
        [switch] $All365,
                
        [Parameter(Mandatory = $false)]
        [switch] $Azure,    

        [Parameter(Mandatory = $false)]
        [switch] $AzureOnly,    
 
        [parameter(Mandatory = $false)]
        [switch] $Skype,
          
        [parameter(Mandatory = $false)]
        [switch] $Sharepoint,
         
        [parameter(Mandatory = $false)]
        [switch] $Compliance,

        [parameter(Mandatory = $false)]
        [switch] $ComplianceLegacy,
          
        [parameter(Mandatory = $false)]
        [switch] $AzurePreview
        
    )

    Begin {
        if ($Tenant -match 'onmicrosoft') {
            $Tenant = $Tenant.Split(".")[0]
        }
    }
    Process {

        $RootPath = "c:\ps\"
        $KeyPath = $Rootpath + "creds\"

        # Create Directory for Transact Logs
        if (!(Test-Path ($RootPath + $Tenant + "\logs\"))) {
            New-Item -ItemType Directory -Force -Path ($RootPath + $Tenant + "\logs\")
        }

        Start-Transcript -path ($RootPath + $Tenant + "\logs\" + "transcript-" + ($(get-date -Format _yyyy-MM-dd_HH-mm-ss)) + ".txt")

        # Create KeyPath Directory
        if (!(Test-Path $KeyPath)) {
            try {
                New-Item -ItemType Directory -Path $KeyPath -ErrorAction STOP | Out-Null
            }
            catch {
                throw $_.Exception.Message
            }           
        }
        if (! $AzureOnly) {
            if (Test-Path ($KeyPath + "$($Tenant).cred")) {
                $PwdSecureString = Get-Content ($KeyPath + "$($Tenant).cred") | ConvertTo-SecureString
                $UsernameString = Get-Content ($KeyPath + "$($Tenant).ucred") 
                $Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $UsernameString, $PwdSecureString 
            }
            else {
                $Credential = Get-Credential -Message "Enter a username and password"
                $Credential.Password | ConvertFrom-SecureString | Out-File "$($KeyPath)\$Tenant.cred" -Force
                $Credential.UserName | Out-File "$($KeyPath)\$Tenant.ucred"
            }
        }
        if (! $AzureOnly) {
            # Office 365 Tenant
            Import-Module MsOnline
            Connect-MsolService -Credential $Credential

            # Exchange Online
            $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell -Credential $Credential -Authentication Basic -AllowRedirection -Verbose
            Import-Module (Import-PSSession $exchangeSession -AllowClobber) -Global | Out-Null
        }

        # Security and Compliance Center
        if ($Compliance -or $All365) {
            $ccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
            Import-Module (Import-PSSession $ccSession -AllowClobber) -Global | Out-Null
        }

        if ($ComplianceLegacy) {
            # $UserCredential = Get-Credential 
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid -Credential $Credential -Authentication Basic -AllowRedirection 
            Import-PSSession $Session -AllowClobber -DisableNameChecking 
            $Host.UI.RawUI.WindowTitle = $UserCredential.UserName + " (Office 365 Security & Compliance Center)"
        }
        
        # Skype Online
        if ($Skype -or $All365) {
            $sfboSession = New-CsOnlineSession -Credential $Credential
            Import-Module (Import-PSSession $sfboSession -AllowClobber) -Global | Out-Null
        }

        # Sharepoint Online
        if ($Sharepoint -or $All365) {
            Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -Verbose
            Connect-SPOService -Url ("https://" + $Tenant + "-admin.sharepoint.com") -credential $Credential
        }

        # Azure
        if ($AzureOnly -or $Azure) {
            $json = Get-ChildItem -Recurse -Include '*@*.json' -Path 'C:\ps\creds'
            if ($json) {
                Write-Host   "*********************************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
                Write-Host   "*********************************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
                Write-Output "Select the Azure username and Click `"OK`" in lower right-hand corner"
                Write-Output "Otherwise, if this is the first time using this Azure username click `"Cancel`""
                Write-Host   "*********************************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
                Write-Host   "*********************************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
                $json = $json | select name | Out-GridView -PassThru -Title "Select Azure username or click Cancel to use another"
            }
            if (!($json)) {
                $azlogin = Login-AzureRmAccount
                Save-AzureRmContext -Path ($KeyPath + ($azlogin.Context.Account.Id) + ".json")
                Import-AzureRmContext -Path ($KeyPath + ($azlogin.Context.Account.Id) + ".json")
            }
            else {
                Import-AzureRmContext -Path ($KeyPath + $json.name)
            }
            Write-Host   "*************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
            Write-Host   "*************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
            Write-Output "Select Subscription and Click "OK" in lower right-hand corner"
            Write-Host   "*************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
            Write-Host   "*************************************************************" -foregroundcolor "magenta" -backgroundcolor "yellow"
            $subscription = Get-AzureRmSubscription | Out-GridView -PassThru -Title "Choose Azure Subscription"| Select id
            Select-AzureRmSubscription -SubscriptionId $subscription.id
        }

        # Azure AD (Preview)
        If ($AzurePreview) {
            install-module azureadpreview
            import-module azureadpreview
            Connect-AzureAD -Credential $Credential
        }

    }
    End {
    } 
}