<#
    .Synopsis
       Generates users, groups, OUs, computers in an active directory domain.  Then places ACLs on random OUs
    .DESCRIPTION
       This tool is for research purposes and training only.  Intended only for personal use.  This adds a large number of objects into a domain, and should never be  run in production.
    .EXAMPLE
       There are currently no parameters for the tool.  Simply run the ps1 as a DA and it begins. Follow the prompts and type 'badblood' when appropriate and the tool runs.
    .OUTPUTS
       [String]
    .NOTES
       Written by David Rowe, Blog secframe.com/blog
       Twitter : @davidprowe
       I take no responsibility for any issues caused by this script.  I am not responsible if this gets run in a production domain.  
    .FUNCTIONALITY
       Adds a ton of stuff into a domain.  Adds Users, Groups, OUs, Computers, and a vast amount of ACLs in a domain.
    .LINK
       http://www.secframe.com/badblood
   
    #>

function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}
$basescriptPath = Get-ScriptDirectory
$totalscripts = 7

$i = 0
cls
write-host "Welcome to BadBlood"
Write-Host  'Press any key to continue...';
write-host "`n"
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
write-host "The first tool that absolutely mucks up your TEST domain"
write-host "This tool is never meant for production and can totally screw up your domain"
Write-Host  'Press any key to continue...';
write-host "`n"
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
Write-Host  'Press any key to continue...';
write-host "You are responsible for how you use this tool. It is intended for personal use only"
write-host "This is not intended for commercial use"
Write-Host  'Press any key to continue...';
write-host "`n"
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
write-host "`n"
$badblood = Read-Host -Prompt "Type `'badblood`' to deploy some randomness into a domain"
$badblood.tolower()
if($badblood -ne 'badblood'){exit}
if($badblood -eq 'badblood'){
   $Domain = Get-addomain
    Write-Progress -Activity "Random Stuff into A domain" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)


    .($basescriptPath + '\AD_LAPS_Install\InstallLAPSSchema.ps1')
    Write-Progress -Activity "Random Stuff into A domain: Install LAPS" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
    $I++
    .($basescriptPath + '\AD_OU_CreateStructure\CreateOUStructure.ps1')
    Write-Progress -Activity "Random Stuff into A domain - Creating OUs" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
    $I++
    $ousAll = Get-adorganizationalunit -filter *
    
    write-host "Creating Users on Domain" -ForegroundColor Green
    $NumOfUsers = Get-Random -Minimum 1000 -Maximum 5000
    $X=1
    Write-Progress -Activity "Random Stuff into A domain - Creating Users" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
    $I++
    .($basescriptPath + '\AD_Users_Create\CreateUsers.ps1')
    $createuserscriptpath = $basescriptPath + '\AD_Users_Create\'
    do{
      createuser -Domain $Domain -OUList $ousAll -ScriptDir $createuserscriptpath
        Write-Progress -Activity "Random Stuff into A domain - Creating $x/$NumOfUsers Users " -Status "Progress:" -PercentComplete ($x/$NumOfUsers*100)
    $x++
    }while($x -lt $NumOfUsers)
    
    $AllUsers = Get-aduser -Filter *
    
    write-host "Creating Groups on Domain" -ForegroundColor Green
    $NumOfGroups = Get-Random -Minimum 100 -Maximum 500
    $X=1
    Write-Progress -Activity "Random Stuff into A domain - Creating $NumOfGroups Groups" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
    $I++
    .($basescriptPath + '\AD_Groups_Create\CreateGroups.ps1')
    
    do{
        Creategroup
        Write-Progress -Activity "Random Stuff into A domain - Creating $x/$NumOfGroups Groups" -Status "Progress:" -PercentComplete ($x/$NumOfGroups*100)
    
    $x++
    }while($x -lt $NumOfGroups)
    $Grouplist = Get-ADGroup -Filter { GroupCategory -eq "Security" -and GroupScope -eq "Global"  } -Properties isCriticalSystemObject
    $LocalGroupList =  Get-ADGroup -Filter { GroupScope -eq "domainlocal"  } -Properties isCriticalSystemObject
    write-host "Creating Computers on Domain" -ForegroundColor Green
    $NumOfComps = 50..150|Get-random 
    $X=1
    Write-Progress -Activity "Random Stuff into A domain - Creating Computers" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
    .($basescriptPath + '\AD_Computers_Create\CreateComputers.ps1')
    $I++
    do{
        Write-Progress -Activity "Random Stuff into A domain - Creating $x/$NumOfComps computers" -Status "Progress:" -PercentComplete ($x/$NumOfComps*100)
        createcomputer
    $x++
    }while($x -lt $NumOfComps)
    $Complist = get-adcomputer -filter *
    
    $I++
    write-host "Creating Permissions on Domain" -ForegroundColor Green
    Write-Progress -Activity "Random Stuff into A domain - Creating Random Permissions" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
    .($basescriptPath + '\AD_Permissions_Randomizer\GenerateRandomPermissions.ps1')
    
    
    $I++
    write-host "Nesting objects into groups on Domain" -ForegroundColor Green
    .($basescriptPath + '\AD_Groups_Create\AddRandomToGroups.ps1')
    Write-Progress -Activity "Random Stuff into A domain - Adding Stuff to Stuff and Things" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
    AddRandomToGroups -Domain $Domain -Userlist $AllUsers -GroupList $Grouplist -LocalGroupList $LocalGroupList -complist $Complist
    
}
