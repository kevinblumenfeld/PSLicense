function Get-CloudSkuTable { 
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
    Param
    (
        [Parameter(Mandatory = $false)]
        [switch] $sourceIgnore,
        
        [Parameter(Mandatory = $false)]
        [string] $sourceSku
        
    )

    Begin {
        $resultArray = @()
    }
    Process {
        # Define Hashtables for lookup 
        $u2fSku = @{ 
           
            "AX_ENTERPRISE_USER" = "AX ENTERPRISE USER"
            
        } 
        $u2fOpt = @{

            "CRMIUR" = "CRM for Partners"
            
        }
        
        # Get a list of all Licenses that exist in the tenant 
        if ($sourceIgnore) {
            $licenses = Get-AzureADSubscribedSku | Where {$_.skupartnumber -eq $sourceSku}
        }
        else {
            $licenses = Get-AzureADSubscribedSku
        }
 
        # Loop through all License types found in the tenant 
        foreach ($license in $licenses) {     
            foreach ($row in $($license.ServicePlans.serviceplanname)) { 
                $table = [ordered]@{}
                if ($u2fSku[$($license.SkuPartNumber)]) {
                    $table['Sku'] = $u2fSku[$license.SkuPartNumber]
                }
                else {
                    $table['Sku'] = $license.SkuPartNumber
                }
                if ($u2fOpt[$row]) {
                    $table['Plan'] = $u2fOpt[$row]
                }
                else {
                    $table['Plan'] = $row
                }
                $resultArray += [psCustomObject]$table 
            } 
        }              
    }
    End {
        $array = $resultArray | ForEach-Object { '{0}*{1}' -f $_.Sku, $_.Plan }
        $array
    }
}