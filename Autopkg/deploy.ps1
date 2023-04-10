$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$Log = $directorypath + '\deploypath'
$path1 = '.\deploypath\deploypath.txt'

$lin_num =  (Get-Content $path1).Length

For ($i=1; $i -le $lin_num; $i++) {
    
    $deploy =  Get-Content $path1 | Select-Object -First $i | Select-Object -last 1 | ForEach-Object {$_}

    $path = Get-ChildItem "$deploy\**\Deploy_UAT.cmd"

    Write-Output "Deployment path $deploy"

    $UAT = Test-Path $path

    if ($UAT -eq "True"){

        Write-Output "$path".Replace("Deploy_UAT.cmd","") | Set-location

        #.\Deploy_UAT.cmd

        Set-Location $Log ; Set-location ..
    }

    else {

        Write-Output "$deploy Deploy_UAT.cmd not found"
    }
}