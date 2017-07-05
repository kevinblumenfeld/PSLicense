function New-LicenseToAssign {
    [CmdletBinding()]
    param (
        [String[]]$Name
    )
    $skuIdHash = @{}
    Get-AzureADSubscribedSku | Select SkuPartNumber, SkuId | ForEach-Object {
        $skuIdHash[$_.SkuPartNumber] = $_.SkuId
    }
    $licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    foreach ($uglyname in $Name) {
        $license = New-Object Microsoft.Open.AzureAD.Model.AssignedLicense
        $license.SkuId = $skuIdHash[$uglyname]
        $licensesToAssign.AddLicenses = @()
        $licensesToAssign.RemoveLicenses = $license.SkuId
    }

    $licensesToAssign 
}