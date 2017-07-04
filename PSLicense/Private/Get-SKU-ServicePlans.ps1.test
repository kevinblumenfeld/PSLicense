$licensetype  = Get-MsolAccountSku
$AccountSkuId = $licensetype.accountskuid
$object = @()
$obj = @()
for($i = 0; $i -lt $AccountSkuId.count; $i++) {
    $Bsku = Get-MsolAccountSku | ? {$_.accountskuid -eq $AccountSkuId[$i]}
    # Write-Output `r`n("AccountSkuID: " + $Bsku.AccountSkuId)
    for($j = 0; $j -lt $Bsku.ServiceStatus.count; $j++){
        $aservice = $Bsku.ServiceStatus[$j].ServicePlan.ServiceName
        $object = New-Object -TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name AccountSkuID -Value $Bsku.accountskuid
        $object | Add-Member -MemberType NoteProperty -Name Service -Value $aservice
        # $objcol += $object
        # Write-Output $object
        # Write-Output `"$aservice`"` `{' '`$thisLicense' '`=` `"$aservice`"`}
        # Write-Output "$($Bsku) $($aservice)"
        # Write-Output `"$Bsku.AccountSkuId`"` `{' '`$thisLicense' '`=` `"$aservice`"`}
        # $object | Export-Csv .\object.csv -NoTypeInformation -Append
        $obj += $object
    }
}    $obj | FT -AutoSize