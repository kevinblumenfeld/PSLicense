function Set-LACloudLicenseV2 {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]] $pipelineUser,

        [Parameter(Mandatory = $false)]
        [switch] $RemoveSkus,
        
        [Parameter(Mandatory = $false)]
        [switch] $RemoveOptions,

        [Parameter(Mandatory = $false)]
        [switch] $AddSkus,

        [Parameter(Mandatory = $false)]
        [switch] $AddOptions,

        [Parameter(Mandatory = $false)]
        [switch] $SwapSkus,

        [Parameter(Mandatory = $false)]
        [switch] $WhileSwapIgnoreSourceOptions,
        
        [Parameter(Mandatory = $false)]
        [switch] $SwapDestAdd,
                
        [Parameter(Mandatory = $false)]
        [switch] $TemplateMode,

        [Parameter(Mandatory = $false)]
        [switch] $InspectUserLicenses,      

        [Parameter(Mandatory = $false)]
        [switch] $InspectUserLicensesNotDisabled,        
        
        [Parameter(Mandatory = $false)]
        [switch] $InspectUserLicensesOnlyDisabled,        
                
        [Parameter(Mandatory = $false)]
        [switch] $DisplayAllSkusAndOptions        
        
    )

    # Begin Block
    Begin {

        # Create hashtable from Name to SkuId lookup
        $skuIdHash = @{}
        Get-AzureADSubscribedSku | Select SkuPartNumber, SkuId | ForEach-Object {
            $skuIdHash[$_.SkuPartNumber] = $_.SkuId
        }

        # Assign Tenant and Location to a variable
        $tenant = ((Get-AzureADTenantDetail).verifiedDomains | where {$_.initial -eq "$true"}).name.split(".")[0]
        $location = "US"
        
        # Friendly 2 Ugly hashtable Lookups
        $f2uSku = @{
            "AX ENTERPRISE USER" = "AX_ENTERPRISE_USER"

        }

        $f2uOpt = @{
 
            "Microsoft MyAnalytics" = "EXCHANGE_ANALYTICS"
     
        }

        # Based on Runtime switches, Out-GridView(s) are presented for user input
        if ($RemoveSkus) {
            [string[]]$skusToRemove = (. Get-CloudSku | Out-GridView -Title "SKUs to Remove" -PassThru)
        }
        if ($RemoveOptions) {
            [string[]]$optionsToRemove = (. Get-CloudSkuTable | Out-GridView -Title "Options to Remove" -PassThru)
        }
        if ($AddSkus) {
            $skusToAdd = (. Get-CloudSku | Out-GridView -Title "SKUs to Add" -PassThru)
        }
        if ($AddOptions) {
            [string[]]$optionsToAdd = (. Get-CloudSkuTable | Out-GridView -Title "Options to Add" -PassThru)
        } 
        if ($SwapSkus) {
            $swapSource = (. Get-CloudSku | Out-GridView -Title "Swap Sku - SOURCE" -PassThru)
            $swapDest = (. Get-CloudSku | Out-GridView -Title "Swap Sku - DESTINATION" -PassThru)
        }
        if ($SwapDestAdd) {
            [string[]]$destAdd = (. Get-CloudSkuTable | Out-GridView -Title "DESTINATION Options to Add" -PassThru)
        }
        if ($TemplateMode) {
            [string[]]$template = (. Get-CloudSkuTable | Out-GridView -Title "Create a Template to Apply - All existing Options will be replaced if Sku is selected here" -PassThru)
        }
        if ($DisplayAllSkusAndOptions) {
            [string[]]$allSkusOptions = (. Get-Sku2Service | Out-GridView -Title "All Skus and Options")
        }
  
    }

    Process {

        # Define Arrays
        $removeSkuGroup = @() 
        $addSkuGroup = @()
        $addAlreadySkuGroup = @()
        $enabled = @()
        $disabled = @()
        $sKey = @()
        $sourceIgnore = @()
        $source = @()

        if ($InspectUserLicenses) {
            (. Get-UserLicense -user $_.userprincipalname | Out-GridView -Title "User License Summary $($_.UserPrincipalName)")
        }
        if ($InspectUserLicensesNotDisabled) {
            (. Get-UserLicense -notDisabled -user $_.userprincipalname | Out-GridView -Title "User License Summary $($_.UserPrincipalName)")
        }
        if ($InspectUserLicensesOnlyDisabled) {
            (. Get-UserLicense -onlyDisabled -user $_.userprincipalname | Out-GridView -Title "User License Summary $($_.UserPrincipalName)")
        }

        # Set user-specific variables
        $user = Get-AzureADUser -ObjectId $_.userprincipalname
        $userLicense = Get-AzureADUserLicenseDetail -ObjectId $_.userprincipalname
        Set-AzureADUser -ObjectId $_.userprincipalname -UsageLocation $location
        
        if ($SwapSkus) {
            if ($SwapSource -eq $swapDest) {
                Write-Output "Source and Destination Skus are identical"
                Write-Output "Source Sku: $($f2uSku.$SwapSource) and Destination Sku: $($f2uSku.$swapdest) are identical."
                Write-Output "Please choose a different Source or Destination Sku"                
                Break
            }
            if ($userLicense.skupartnumber.Contains($swapSource)) {
                if (($f2uSku.$swapdest) -and ($f2uSku.$SwapSource)) {
                    (Get-AzureADSubscribedSku | Where {$_.skupartnumber -eq $f2uSku.$swapdest}) | ForEach-Object {
                        if (($_.prepaidunits.enabled - $_.consumedunits) -lt "1") {
                            Write-Output "Out of $($f2uSku.$swapdest) licenses.  Please allocate more then rerun."
                            Break 
                        }
                        $dest = $_.serviceplans.serviceplanname
                        $source = ((Get-AzureADUserLicenseDetail -ObjectId $user.UserPrincipalName | Where {$_.skupartnumber -eq $f2uSku.$SwapSource}).serviceplans | Where {$_.provisioningstatus -ne 'Disabled'}).serviceplanname
                        if ($source) {
                            if ($WhileSwapIgnoreSourceOptions) {
                                [string[]]$sourceIgnore = (. Get-CloudSkuTable -sourceIgnore -sourceSku $f2uSku.$SwapSource | Out-GridView -Title "SOURCE Options to Ignore" -PassThru)
                            }
                            if ($sourceIgnore) {
                                $sourceIgnore = $sourceIgnore | % {
                                    if ($f2uOpt[($_)]) {
                                        $f2uOpt[($_).split("*")[1]]
                                    }
                                    else {
                                        ($_).split("*")[1]
                                    }
                                } 
                                $source = $source | Where {$sourceIgnore -notcontains $_}
                            }
                        }
                        $destarray = Get-UniqueString $dest
                        $sourcearray = Get-UniqueString $source
                        $options2swap = $sourcearray.keys | Where {$destarray.keys -match $_}
                        $options2swap = $options2swap | % {$destarray[$_]}
                        $licensesToAssign = Set-SkuChange -addTheOptions -skus $f2uSku.$swapdest -options $options2swap
                        try {
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign -ErrorAction Stop
                            $licensesToAssign = Set-SkuChange -remove -skus $f2uSku.$SwapSource
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
                        }
                        catch {
                            $_
                        }
                    }
                }
                if ((!($f2uSku.$swapdest)) -and ($f2uSku.$SwapSource)) {
                    (Get-AzureADSubscribedSku | Where {$_.skupartnumber -eq $swapdest}) | ForEach-Object {
                        if (($_.prepaidunits.enabled - $_.consumedunits) -lt "1") {
                            Write-Output "Out of $swapdest licenses.  Please allocate more then rerun."
                            Break 
                        }
                        $dest = $_.serviceplans.serviceplanname
                        $source = ((Get-AzureADUserLicenseDetail -ObjectId $user.UserPrincipalName | Where {$_.skupartnumber -eq $f2uSku.$SwapSource}).serviceplans | Where {$_.provisioningstatus -ne 'Disabled'}).serviceplanname
                        if ($source) {
                            if ($WhileSwapIgnoreSourceOptions) {
                                [string[]]$sourceIgnore = (. Get-CloudSkuTable -sourceIgnore -sourceSku $f2uSku.$SwapSource | Out-GridView -Title "SOURCE Options to Ignore" -PassThru)
                            }
                            if ($sourceIgnore) {
                                $sourceIgnore = $sourceIgnore | % {
                                    if ($f2uOpt[($_)]) {
                                        $f2uOpt[($_).split("*")[1]]
                                    }
                                    else {
                                        ($_).split("*")[1]
                                    }
                                } 
                                $source = $source | Where {$sourceIgnore -notcontains $_}
                            }
                        }
                        $destarray = Get-UniqueString $dest
                        $sourcearray = Get-UniqueString $source
                        $options2swap = $sourcearray.keys | Where {$destarray.keys -match $_}
                        $options2swap = $options2swap | % {$destarray[$_]}
                        $licensesToAssign = Set-SkuChange -addTheOptions -skus $swapdest -options $options2swap
                        try {
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign -ErrorAction Stop
                            $licensesToAssign = Set-SkuChange -remove -skus $f2uSku.$SwapSource
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
                        }
                        catch {
                            $_
                        }
                    }
                }
                if (($f2uSku.$swapdest) -and (!($f2uSku.$SwapSource))) {
                    (Get-AzureADSubscribedSku | Where {$_.skupartnumber -eq $f2uSku.$swapdest}) | ForEach-Object {
                        if (($_.prepaidunits.enabled - $_.consumedunits) -lt "1") {
                            Write-Output "Out of $($f2uSku.$swapdest) licenses.  Please allocate more then rerun."
                            Break 
                        }
                        $dest = $_.serviceplans.serviceplanname
                        $source = ((Get-AzureADUserLicenseDetail -ObjectId $user.UserPrincipalName | Where {$_.skupartnumber -eq $SwapSource}).serviceplans | Where {$_.provisioningstatus -ne 'Disabled'}).serviceplanname
                        if ($source) {
                            if ($WhileSwapIgnoreSourceOptions) {
                                [string[]]$sourceIgnore = (. Get-CloudSkuTable -sourceIgnore -sourceSku $SwapSource | Out-GridView -Title "SOURCE Options to Ignore" -PassThru)
                            }
                            if ($sourceIgnore) {
                                $sourceIgnore = $sourceIgnore | % {
                                    if ($f2uOpt[($_)]) {
                                        $f2uOpt[($_).split("*")[1]]
                                    }
                                    else {
                                        ($_).split("*")[1]
                                    }
                                } 
                                $source = $source | Where {$sourceIgnore -notcontains $_}
                            }
                        }
                        $destarray = Get-UniqueString $dest
                        $sourcearray = Get-UniqueString $source
                        $options2swap = $sourcearray.keys | Where {$destarray.keys -match $_}
                        $options2swap = $options2swap | % {$destarray[$_]}
                        $licensesToAssign = Set-SkuChange -addTheOptions -skus $f2uSku.$swapdest -options $options2swap
                        try {
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign -ErrorAction Stop
                            $licensesToAssign = Set-SkuChange -remove -skus $SwapSource
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
                        }
                        catch {
                            $_
                        }
                    }
                }
                if ((!($f2uSku.$swapdest)) -and (!($f2uSku.$SwapSource))) {
                    (Get-AzureADSubscribedSku | Where {$_.skupartnumber -eq $swapDest}) | ForEach-Object {
                        if (($_.prepaidunits.enabled - $_.consumedunits) -lt "1") {
                            Write-Output "Out of $swapdest licenses.  Please allocate more then rerun."
                            Break 
                        }
                        $dest = $_.serviceplans.serviceplanname
                        $source = ((Get-AzureADUserLicenseDetail -ObjectId $user.UserPrincipalName | Where {$_.skupartnumber -eq $SwapSource}).serviceplans | Where {$_.provisioningstatus -ne 'Disabled'}).serviceplanname
                        if ($source) {
                            if ($WhileSwapIgnoreSourceOptions) {
                                [string[]]$sourceIgnore = (. Get-CloudSkuTable -sourceIgnore -sourceSku $SwapSource | Out-GridView -Title "SOURCE Options to Ignore" -PassThru)
                            }
                            if ($sourceIgnore) {
                                $sourceIgnore = $sourceIgnore | % {
                                    if ($f2uOpt[($_)]) {
                                        $f2uOpt[($_).split("*")[1]]
                                    }
                                    else {
                                        ($_).split("*")[1]
                                    }
                                } 
                                $source = $source | Where {$sourceIgnore -notcontains $_}
                            }
                        }
                        $destarray = Get-UniqueString $dest
                        $sourcearray = Get-UniqueString $source
                        $options2swap = $sourcearray.keys | Where {$destarray.keys -match $_}
                        $options2swap = $options2swap | % {$destarray[$_]}
                        $licensesToAssign = Set-SkuChange -addTheOptions -skus $swapdest -options $options2swap
                        try {
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign -ErrorAction Stop
                            $licensesToAssign = Set-SkuChange -remove -skus $SwapSource
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
                        }
                        catch {
                            $_
                        }
                    }
                }
                Write-Verbose "$($user.UserPrincipalName) Source: $SwapSource Dest: $swapDest SOURCE OPTIONS: $Source"
            }
            else {
                Write-Verbose "$($user.UserPrincipalName) does not have source Sku:  $SwapSource, no changes will be made to this user"
            }
        }   

        # Remove Sku(s)
        if ($skusToRemove) {
            Foreach ($removeSku in $skusToRemove) {
                if ($f2uSku.$removeSku) {
                    if ($f2uSku.$removeSku -in (Get-AzureADUserLicenseDetail -ObjectId $_.userprincipalname).skupartnumber) {
                        $removeSkuGroup += $f2uSku.$removeSku 
                    } 
                }
                else {
                    if ($removeSku -in (Get-AzureADUserLicenseDetail -ObjectId $_.userprincipalname).skupartnumber) {
                        $removeSkuGroup += $removeSku 
                    } 
                }
            }
            if ($removeSkuGroup) {
                Write-Verbose "$($_.userprincipalname) has the following Skus, removing these Sku now: $removeSkuGroup "
                $licensesToAssign = Set-SkuChange -remove -skus $removeSkuGroup
                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
            }
            Else {
                Write-Verbose "$($_.userprincipalname) does not have any of the Skus requested for removal"
            }
        }
        # Remove Options.  Only if user is assigned Sku.
        if ($optionsToRemove) {
            $hashRem = @{}
            for ($i = 0; $i -lt $optionsToRemove.count; $i++) {
                if ($optionsToRemove[$i]) {
                    if ($f2uSku[$optionsToRemove[$i].split("*")[0]]) {
                        # FRIENDLY SKU TRACT 
                        if ($hashRem.containskey($f2uSku[$optionsToRemove[$i].split("*")[0]])) {
                            if ($f2uOpt[$optionsToRemove[$i].split("*")[1]]) {
                                #   FRIENDLY SKU  --  FRIENDLY OPTION    EXISTING
                                $hashRem.($f2uSku[$optionsToRemove[$i].split("*")[0]]) += @($f2uOpt[$optionsToRemove[$i].split("*")[1]])
                            }
                            else {
                                #   FRIENDLY SKU  --  UGLY OPTION    EXISTING
                                $hashRem.($f2uSku[$optionsToRemove[$i].split("*")[0]]) += @($optionsToRemove[$i].split("*")[1])
                            }
                        }
                        else {
                            if ($f2uOpt[$optionsToRemove[$i].split("*")[1]]) {
                                #   FRIENDLY SKU  --  FRIENDLY OPTION    FRESH!
                                $hashRem.($f2uSku[$optionsToRemove[$i].split("*")[0]]) = @($f2uOpt[$optionsToRemove[$i].split("*")[1]])
                            }
                            else {
                                #   FRIENDLY SKU  --  UGLY OPTION    FRESH!
                                $hashRem.($f2uSku[$optionsToRemove[$i].split("*")[0]]) = @($optionsToRemove[$i].split("*")[1])
                            }
                        }
                    }
                    # UGLY SKU TRACT 
                    else {
                        if ($hashRem.containskey($optionsToRemove[$i].split("*")[0])) {
                            if ($f2uOpt[$optionsToRemove[$i].split("*")[1]]) {
                                #   UGLY SKU  --  FRIENDLY OPTION    EXISTING
                                $hashRem.($optionsToRemove[$i].split("*")[0]) += @($f2uOpt[$optionsToRemove[$i].split("*")[1]])
                            }
                            else {
                                #   UGLY SKU  --  UGLY OPTION    EXISTING
                                $hashRem.($optionsToRemove[$i].split("*")[0]) += @($optionsToRemove[$i].split("*")[1])
                            }
                        }
                        else {
                            if ($f2uOpt[$optionsToRemove[$i].split("*")[1]]) {
                                #   UGLY SKU  --  FRIENDLY OPTION    FRESH!
                                $hashRem.($optionsToRemove[$i].split("*")[0]) = @($f2uOpt[$optionsToRemove[$i].split("*")[1]])
                            }
                            else {
                                #   UGLY SKU  --  UGLY OPTION    FRESH!
                                $hashRem.($optionsToRemove[$i].split("*")[0]) = @($optionsToRemove[$i].split("*")[1])
                            }
                        }
                    }
                }
            }
            $hashRem.GetEnumerator() | ForEach-Object { 
                Write-Verbose "$($user.UserPrincipalName) : $($_.key) : $($_.value) "
                # User already has Sku
                $sKey = $_.key
                if ($sKey -in $userLicense.skupartnumber) {
                    $disabled = $_.Value + ((($userLicense | Where {$_.skupartnumber -contains $sKey}).serviceplans | where {$_.provisioningStatus -eq 'Disabled'}).serviceplanname)
                    Write-Verbose "Options from Sku: $sKey to remove + options currently disabled: $disabled "
                    $licensesToAssign = Set-SkuChange -removeTheOptions -skus $sKey -options $disabled
                    Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign  
                }
                # User does not have Sku so do nothing
                else {
                    Write-Verbose "User does not have SKU, no options to remove"
                }
                  
            }
        }
        # Add Sku(s).  If user has Sku already, all options will be added        
        if ($skusToAdd) {
            Foreach ($addSku in $skusToAdd) {
                if ($f2uSku.$addSku) {
                    if ($f2uSku.$addSku -notin (Get-AzureADUserLicenseDetail -ObjectId $_.userprincipalname).skupartnumber) {
                        $addSkuGroup += $f2uSku.$addSku 
                    } 
                    if ($f2uSku.$addSku -in (Get-AzureADUserLicenseDetail -ObjectId $_.userprincipalname).skupartnumber) {
                        $addAlreadySkuGroup += $f2uSku.$addSku
                    } 
                }
                else {
                    if ($addSku -notin (Get-AzureADUserLicenseDetail -ObjectId $_.userprincipalname).skupartnumber) {
                        $addSkuGroup += $addSku 
                    } 
                    if ($addSku -in (Get-AzureADUserLicenseDetail -ObjectId $_.userprincipalname).skupartnumber) {
                        $addAlreadySkuGroup += $addSku
                    } 
                }
            }
            # Add fresh Sku(s)
            if ($addSkuGroup) {
                Write-Verbose "$($_.userprincipalname) does not have the following Skus, adding these Sku now: $addSkuGroup "
                $licensesToAssign = Set-SkuChange -add -skus $addSkuGroup
                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
            }
            # Backfill already assigned Sku(s) with any missing options
            if ($addAlreadySkuGroup) {
                Write-Verbose "$($_.userprincipalname) already has the following Skus, adding any options not currently assigned: $addAlreadySkuGroup "
                $licensesToAssign = Set-SkuChange -addAlready -skus $addAlreadySkuGroup
                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
            }
        }
        # Add Option(s). User will be assigned Sku with the options if user has yet to have Sku assigned 
        if ($optionsToAdd) {
            $hashAdd = @{}
            for ($i = 0; $i -lt $optionsToAdd.count; $i++) {
                if ($optionsToAdd[$i]) {
                    if ($f2uSku[$optionsToAdd[$i].split("*")[0]]) {
                        # FRIENDLY SKU TRACT 
                        if ($hashAdd.containskey($f2uSku[$optionsToAdd[$i].split("*")[0]])) {
                            if ($f2uOpt[$optionsToAdd[$i].split("*")[1]]) {
                                #   FRIENDLY SKU  --  FRIENDLY OPTION    EXISTING
                                $hashAdd.($f2uSku[$optionsToAdd[$i].split("*")[0]]) += @($f2uOpt[$optionsToAdd[$i].split("*")[1]])
                            }
                            else {
                                #   FRIENDLY SKU  --  UGLY OPTION    EXISTING
                                $hashAdd.($f2uSku[$optionsToAdd[$i].split("*")[0]]) += @($optionsToAdd[$i].split("*")[1])
                            }
                        }
                        else {
                            if ($f2uOpt[$optionsToAdd[$i].split("*")[1]]) {
                                #   FRIENDLY SKU  --  FRIENDLY OPTION    FRESH!
                                $hashAdd.($f2uSku[$optionsToAdd[$i].split("*")[0]]) = @($f2uOpt[$optionsToAdd[$i].split("*")[1]])
                            }
                            else {
                                #   FRIENDLY SKU  --  UGLY OPTION    FRESH!
                                $hashAdd.($f2uSku[$optionsToAdd[$i].split("*")[0]]) = @($optionsToAdd[$i].split("*")[1])
                            }
                        }
                    }
                    # UGLY SKU TRACT 
                    else {
                        if ($hashAdd.containskey($optionsToAdd[$i].split("*")[0])) {
                            if ($f2uOpt[$optionsToAdd[$i].split("*")[1]]) {
                                #   UGLY SKU  --  FRIENDLY OPTION    EXISTING
                                $hashAdd.($optionsToAdd[$i].split("*")[0]) += @($f2uOpt[$optionsToAdd[$i].split("*")[1]])
                            }
                            else {
                                #   UGLY SKU  --  UGLY OPTION    EXISTING
                                $hashAdd.($optionsToAdd[$i].split("*")[0]) += @($optionsToAdd[$i].split("*")[1])
                            }
                        }
                        else {
                            if ($f2uOpt[$optionsToAdd[$i].split("*")[1]]) {
                                #   UGLY SKU  --  FRIENDLY OPTION    FRESH!
                                $hashAdd.($optionsToAdd[$i].split("*")[0]) = @($f2uOpt[$optionsToAdd[$i].split("*")[1]])
                            }
                            else {
                                #   UGLY SKU  --  UGLY OPTION    FRESH!
                                $hashAdd.($optionsToAdd[$i].split("*")[0]) = @($optionsToAdd[$i].split("*")[1])
                            }
                        }
                    }
                }
            }
            $hashAdd.GetEnumerator() | ForEach-Object { 
                Write-Verbose "$($user.UserPrincipalName) : $($_.key) : $($_.value) "
                # User already has Sku
                $sKey = $_.key
                if ($sKey -in $userLicense.skupartnumber) {
                    $enabled = [pscustomobject]$_.Value + ((($userLicense | Where {$_.skupartnumber -contains $sKey}).serviceplans | Where {$_.provisioningstatus -ne 'Disabled'}).serviceplanname)
                    Write-Verbose "Options from Sku: $sKey to add + options currently enabled: $enabled "
                    $licensesToAssign = Set-SkuChange -addTheOptions -skus $sKey -options $enabled
                    Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign  
                }
                # User does not have Sku yet
                else {
                    $enabled = [pscustomobject]$_.Value
                    Write-Verbose "User does not have SKU: $sKey, adding Sku with options: $enabled "
                    $licensesToAssign = Set-SkuChange -addTheOptions -skus $sKey -options $enabled
                    Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign  
                }
            }
        }
        # Template mode - applies options to any Skus used in this template - will not respect existing Options (wipes them out)
        if ($template) {
            $hashTemplate = @{}
            for ($i = 0; $i -lt $template.count; $i++) {
                if ($template[$i]) {
                    if ($f2uSku[$template[$i].split("*")[0]]) {
                        # FRIENDLY SKU TRACT 
                        if ($hashTemplate.containskey($f2uSku[$template[$i].split("*")[0]])) {
                            if ($f2uOpt[$template[$i].split("*")[1]]) {
                                #   FRIENDLY SKU  --  FRIENDLY OPTION    EXISTING
                                $hashTemplate.($f2uSku[$template[$i].split("*")[0]]) += @($f2uOpt[$template[$i].split("*")[1]])
                            }
                            else {
                                #   FRIENDLY SKU  --  UGLY OPTION    EXISTING
                                $hashTemplate.($f2uSku[$template[$i].split("*")[0]]) += @($template[$i].split("*")[1])
                            }
                        }
                        else {
                            if ($f2uOpt[$template[$i].split("*")[1]]) {
                                #   FRIENDLY SKU  --  FRIENDLY OPTION    FRESH!
                                $hashTemplate.($f2uSku[$template[$i].split("*")[0]]) = @($f2uOpt[$template[$i].split("*")[1]])
                            }
                            else {
                                #   FRIENDLY SKU  --  UGLY OPTION    FRESH!
                                $hashTemplate.($f2uSku[$template[$i].split("*")[0]]) = @($template[$i].split("*")[1])
                            }
                        }
                    }
                    # UGLY SKU TRACT 
                    else {
                        if ($hashTemplate.containskey($template[$i].split("*")[0])) {
                            if ($f2uOpt[$template[$i].split("*")[1]]) {
                                #   UGLY SKU  --  FRIENDLY OPTION    EXISTING
                                $hashTemplate.($template[$i].split("*")[0]) += @($f2uOpt[$template[$i].split("*")[1]])
                            }
                            else {
                                #   UGLY SKU  --  UGLY OPTION    EXISTING
                                $hashTemplate.($template[$i].split("*")[0]) += @($template[$i].split("*")[1])
                            }
                        }
                        else {
                            if ($f2uOpt[$template[$i].split("*")[1]]) {
                                #   UGLY SKU  --  FRIENDLY OPTION    FRESH!
                                $hashTemplate.($template[$i].split("*")[0]) = @($f2uOpt[$template[$i].split("*")[1]])
                            }
                            else {
                                #   UGLY SKU  --  UGLY OPTION    FRESH!
                                $hashTemplate.($template[$i].split("*")[0]) = @($template[$i].split("*")[1])
                            }
                        }
                    }
                }
            }
            $hashTemplate.GetEnumerator() | ForEach-Object { 
                Write-Verbose "$($user.UserPrincipalName) : $($_.key) : $($_.value) "
                # User already has Sku
                $sKey = $_.key
                if ($sKey -in $userLicense.skupartnumber) {
                    $enabled = [pscustomobject]$_.Value
                    Write-Verbose "Only options that will be applied for Sku $sKey : $enabled "
                    $licensesToAssign = Set-SkuChange -addTheOptions -skus $sKey -options $enabled
                    Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign  
                }
                # User does not have Sku yet
                else {
                    $enabled = [pscustomobject]$_.Value
                    Write-Verbose "User does not have SKU: $sKey, adding Sku with options: $enabled "
                    $licensesToAssign = Set-SkuChange -addTheOptions -skus $sKey -options $enabled
                    Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign  
                }
            }
        }
    }
    End {

    }
}
