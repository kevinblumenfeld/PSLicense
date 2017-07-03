function Set-LACloudLicenseTEST {
    $resultArray = @()
    $skus = (Get-AzureADSubscribedSku)
    
    foreach ($sku in $skus) {
        $sku2service = @{}
        foreach ($plan in $sku.serviceplans.serviceplanname) {
            $sku2service['Sku'] = $sku.SkuPartNumber
            $sku2service['Service'] = $plan
            $resultArray += [psCustomObject]$sku2service
        }   
    }
    $resultArray
}