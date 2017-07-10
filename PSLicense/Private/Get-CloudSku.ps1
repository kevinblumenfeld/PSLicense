function Get-CloudSku { 
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
        $resultArray = @()
    }
    Process {
        # Define Hashtables for lookup 
        $u2fSku = @{ 
            "AX_ENTERPRISE_USER" = "AX ENTERPRISE USER"
            
        } 
        
        # Get a list of all Licenses that exist in the tenant 
        $licenses = (Get-AzureADSubscribedSku).SkuPartNumber
 
        # Loop through all License types found in the tenant 
        $table = [ordered]@{}
        foreach ($license in $licenses) {
            if ($u2fSku[$license]) {
                $table['License'] = $u2fSku[$license]
                $resultArray += [psCustomObject]$table
            }     
            else {
                $table['License'] = $license
                $resultArray += [psCustomObject]$table
            }
        }
    } 
    End {
        $array = $resultArray | ForEach-Object { '{0}' -f $_.License }
        $array
    }
}