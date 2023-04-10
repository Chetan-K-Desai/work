$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$path2 = $directorypath + '\Projects'
$path1 = $directorypath + '.\lmsrelease.txt'
$Log = $directorypath + '.\Error.log'

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
        #Set-Location $path2\$repo | git checkout $branch | git pull
        Write-Output "Latest changes are pulled"
    } 

    else {
        Write-Output "Cloning new repo"
        Set-Location $path2 | git clone -b $branch https://bitbucket.org/lmsrecruitmentsystems/$repo.git
        Set-Location .\$repo
        git submodule update --init --force --recursive
        Write-Output "submodule is updated"
        
        Write-Output nuget restore
        Start-BitsTransfer https://dist.nuget.org/win-x86-commandline/latest/nuget.exe.

        $path4 = Get-ChildItem ".\*.sln"
        $path5 = Get-ChildItem ".\**\*.sln"     

        echo "$path4"
        echo "$path5"

    #$a = (Test-Path $path4)
    if ((Test-Path ".\*.sln") -eq "False") {
        .\nuget.exe restore $path4 2> $Log\$repo.txt
    }

    if ((Test-Path ".\**\*.sln") -eq "True"){
        .\nuget.exe restore $path5 2> $Log\$repo.txt
    }
    #.\nuget.exe restore $path4 2> $Log\$repo.txt
    }
    
    $b = Test-Path .\Package
    if ($b -ne "True") {
        Set-Location .\**\Package
    }

    else {
        Set-Location .\Package
    }
    .\Package.ps1 2>> $Log\$repo.txt

    $e = Select-String -Pattern "localReleaseFolder" .\package.settings.ps1 | ForEach-Object { $elements = $_ -split '";'; $elements[0] } | ForEach-Object { $elements = $_ -split '= "'; $elements[1] }
    echo $e >> $Log\deploypath.txt #; Test-path $e >> $Log\deploypath.txt

}

Set-Location $path2
Set-Location ..\
Remove-Item -Recurse -Force -path $path2
#Remove-Item  -Recurse -path .\Error.log\*