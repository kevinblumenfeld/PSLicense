function Get-Sku2Service {
    $resultArray = @()
    $skus = (Get-AzureADSubscribedSku)
    
    foreach ($sku in $skus) {
        $sku2service = [ordered]@{}
        foreach ($plan in $sku.serviceplans.serviceplanname) {
            $sku2service['Sku'] = $sku.SkuPartNumber
            $sku2service['Service'] = $plan
            $sku2service['Remaining'] = ($sku.prepaidunits.enabled - $sku.consumedunits)
            $sku2service['Total'] = ($sku.prepaidunits.enabled)
            $resultArray += [psCustomObject]$sku2service
        }   
    }
    $resultArray
}