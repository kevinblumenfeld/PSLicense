function Get-LAConnected {
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
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param
    (

        [parameter(Mandatory = $true)]
        [string] $Tenant,
       
        [Parameter(Mandatory = $false)]
        [switch] $All365,
                
        [Parameter(Mandatory = $false)]
        [switch] $AzureOnly,        
                 
        [Parameter(Mandatory = $false)]
        [switch] $AzureAnd365,        
 
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
                $Credential = Get-Credential -Message "Enter a user name and password"
                $Credential.Password | ConvertFrom-SecureString | Out-File "$($KeyPath)\$Tenant.cred" -Force
                $Credential.UserName | Out-File "$($KeyPath)\$Tenant.ucred"
            }
        }
        if (! $AzureOnly) {
            # Office 365 Tenant
            Import-Module MsOnline
            Connect-MsolService -Credential $Credential

            # Exchange Online
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell -Credential $Credential -Authentication Basic -AllowRedirection -Verbose
            Export-PSSession $Session -OutputModule ExchangeOnline -Force
            Import-Module ExchangeOnline -Scope Global

        }

        # Security and Compliance Center
        if ($Compliance -or $All365) {
            $ccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
            Export-PSSession $ccSession -OutputModule ComplianceCenter -Force
            Import-Module ComplianceCenter -Scope Global
        }

        if ($ComplianceLegacy) {
            $UserCredential = Get-Credential 
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid -Credential $UserCredential -Authentication Basic -AllowRedirection 
            Import-PSSession $Session -AllowClobber -DisableNameChecking 
            $Host.UI.RawUI.WindowTitle = $UserCredential.UserName + " (Office 365 Security & Compliance Center)"
        }
        
        # Skype Online
        if ($Skype -or $All365) {
            Import-Module SkypeOnlineConnector
            $sfboSession = New-CsOnlineSession -Credential $Credential
            Import-PSSession $sfboSession
        }

        # Sharepoint Online
        if ($Sharepoint -or $All365) {
            Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -Verbose
            Connect-SPOService -Url ("https://" + $Tenant + "-admin.sharepoint.com") -credential $Credential

        }

        # Azure
        if ($AzureAnd365 -or $AzureOnly) {
            if (!(Test-Path ($KeyPath + $Tenant + ".json"))) {
                Login-AzureRmAccount
                Save-AzureRmContext -Path ($KeyPath + $Tenant + ".json")
                Import-AzureRmContext -Path ($KeyPath + $Tenant + ".json")
            }
            else {
                Import-AzureRmContext -Path ($KeyPath + $Tenant + ".json")
            }
            Write-Output "Select Subscription and Click "OK" in lower right-hand corner"
            $subscription = Get-AzureRmSubscription | Out-GridView -PassThru | Select id
            Select-AzureRmSubscription  -SubscriptionId $subscription.id
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