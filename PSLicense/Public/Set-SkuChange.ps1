function Set-SkuChange {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String[]] $skus,

        [Parameter(Mandatory = $true)]
        [String[]] $options,

        [Parameter(Mandatory = $false)]
        [switch] $add,

        [Parameter(Mandatory = $false)]
        [switch] $addAlready,
        
        [Parameter(Mandatory = $false)]
        [switch] $remove,        
        
        [Parameter(Mandatory = $false)]
        [switch] $addAlreadyOptions,
        
        [Parameter(Mandatory = $false)]
        [switch] $addOptions

    )
    $SkuFeaturesToEnable = @()
    $SkuFeaturesToDisable = @()
    $skuIdHash = @{}
    Get-AzureADSubscribedSku | Select SkuPartNumber, SkuId | ForEach-Object {
        $skuIdHash[$_.SkuPartNumber] = $_.SkuId
    }
    if ($remove) {
        $licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        foreach ($sku in $skus) {
            $license = New-Object Microsoft.Open.AzureAD.Model.AssignedLicense
            $license.SkuId = $skuIdHash.$sku
            $licensesToAssign.AddLicenses = @()
            $licensesToAssign.RemoveLicenses += $license.SkuId
        }
    }
    if ($add) {
        $licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        foreach ($sku in $skus) {
            $license = New-Object Microsoft.Open.AzureAD.Model.AssignedLicense
            $license.SkuId = $skuIdHash.$sku
            $licensesToAssign.AddLicenses += $license
        }
    }
    if ($addAlready) {
        $licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        foreach ($sku in $skus) {
            $StandardLicense = Get-AzureADSubscribedSku | Where {$_.SkuId -eq $skuIdHash.$sku}
            $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $license.SkuId = $StandardLicense.SkuId
            $licensesToAssign.AddLicenses += $license
        }
    }
    if ($addOptions) {
        $licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        foreach ($sku in $skus) {
            $StandardLicense = Get-AzureADSubscribedSku | Where {$_.SkuId -eq $skuIdHash.$sku}
            $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $license.SkuId = $StandardLicense.SkuId
            $licensesToAssign.AddLicenses += $license
        }
    }
    if ($addAlreadyOptions) {
        $licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        foreach ($sku in $skus) {
            $SkuFeaturesToEnable = $options
            $StandardLicense = Get-AzureADSubscribedSku | Where {$_.SkuId -eq $skuIdHash.$sku}
            $SkuFeaturesToDisable = $StandardLicense.ServicePlans | ForEach-Object { $_ | Where {$_.ServicePlanName -notin $SkuFeaturesToEnable }}
            $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $License.DisabledPlans = $SkuFeaturesToDisable.ServicePlanId
            $license.SkuId = $StandardLicense.SkuId
            $licensesToAssign.AddLicenses += $license
        }
    }
    $licensesToAssign 
}