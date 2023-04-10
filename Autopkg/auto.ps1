$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$path2 = $directorypath + '\Projects'
$path1 = $directorypath + '.\lmsrelease.txt'
$Log = $directorypath + '.\Error.log'
$DP = $directorypath + '.\deploypath'
$path3 = Test-Path $path2

if ($path3 -ne "True") {
    New-Item $path2 -ItemType Directory
}

$lin_num =  (Get-Content $path1).Length

for ($i=1; $i -le $lin_num; $i++) {
    
    $repo =  Get-Content $path1 | Select-Object -First $i | Select-Object -last 1 | ForEach-Object { $elements = $_ -split ','; $elements[0] }
    $branch = Get-content $path1 | Select-Object -First $i | Select-Object -last 1 | ForEach-Object { $elements = $_ -split ','; $elements[1] }

    Write-Output "$repo"

    if (Test-Path $path2\$repo) {
        Set-Location $path2\$repo | git checkout $branch | git pull
        Write-Output "Latest changes are pulled"
    } 

    else {
        Write-Output "Cloning new repo"
        Set-Location $path2 | git clone -b $branch https://bitbucket.org/lmsrecruitmentsystems/$repo.git
        Set-Location .\$repo
        git submodule update --init --force --recursive
        Write-Output "submodule is updated"
        
        $path4 = Get-ChildItem ".\*.sln"
        
        Write-Output nuget restore
        Start-BitsTransfer https://dist.nuget.org/win-x86-commandline/latest/nuget.exe.
        .\nuget.exe restore $path4 2> $Log\$repo.txt

     }
    
    $a = Test-Path .\Package
    if ( $a -ne "True") {
        Set-Location .\**\Package
    }

    else {
        Set-Location .\Package
    }
    .\Package.ps1 2>> $Log\$repo.txt

    $e = Select-String -Pattern "localReleaseFolder" .\package.settings.ps1 | ForEach-Object { $elements = $_ -split '";'; $elements[0] } | ForEach-Object { $elements = $_ -split '= "'; $elements[1] }
    echo $e >> $DP\deploypath.txt

}

Set-Location $path2
Set-Location ..\
Remove-Item -Recurse -Force -path $path2