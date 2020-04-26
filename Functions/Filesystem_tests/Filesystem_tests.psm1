# Returns boolean; $true if folder (1) folder already exists or (2) folder doesn't exist but can be created; $false if it CANNOT be created.
# SYNTAX: Test-ReturnBool_FolderCanBeCreated -TestPath [string]$TestPath
function Test-ReturnBool_PathHasNotInvalidColons
{
    [CmdletBinding()]
    param (
        [Parameter()][string]$pathString
    )

    #$inputStringCharArray="$pathString".ToCharArray()

    $ColonCount=0
    $lastColonPosition=$null

    $counter=0
    foreach ($i in "$pathString".ToCharArray())
    {
        if ($i -eq ':')
        {
            $colonCount++
            $lastColonPosition=$counter
        }
        $counter++
    }

    if ($colonCount -gt 1 -or $lastColonPosition -eq 0 -or $lastColonPosition -gt 1) {return $false}
    else {return $true}
}
function Test-ReturnBool_FolderCanBeCreated
{
    [CmdletBinding()]
    param
    (
        [Parameter()][string]$TestPath
    )
    if (!(Test-ReturnBool_PathHasNotInvalidColons "$testPath")) {return $false}
    if ((Test-Path -Path "$testPath")) {return $true} 
    elseif (!(Test-Path -Path "$testPath"))
    {
        try
        {
            New-Item -ItemType "directory" -Path "$testPath" 
            # Just to be safe
            if ((Test-Path -Path "$testPath") -eq $true -and (Get-ChildItem "$testPath" | Measure-Object).Count -eq 0)
            {
                $null=(Remove-Item -Path "$testPath")
                return $true
            }

            return $true
        }
        catch [System.Management.Automation.ActionPreferenceStopException]
        {
            if ($Error[0].Exception.GetType().Name -eq 'DriveNotFoundException') 
            {
                return $false 
            }
        }
        catch
        {
            return $false          
        }
    }
}

function Test-ReturnBool_PathIsWinDriveRoot
{
    [CmdletBinding()]
    param
    (
        [Parameter()][string]$InputString
    ) 
    if ("$InputString".trim() -match "^([\.\\]*)$")
    {
        $InputString=[System.IO.Path]::GetFullPath($InputString)
    }

    $condition_1=("$InputString".trim() -match "^[A-Za-z]:\\$")
    $condition_2=("$InputString".trim() -match "^[A-Za-z]:$")
    $condition_3=("$InputString".trim() -match "^\\$")

    if ($condition_1 -or $condition_2 -or $condition_3)
    {
        return $true
    }
    else {return $false}
}

function Get-ReturnString_UniqueAvaliableFolderName
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][String]$NewFolderBaseName,
        [Parameter(Mandatory=$false)][int32]$AppendedNumberTotalDigits=4,
        [Parameter(Mandatory=$false)][int32]$StartNumber=1,
        [Parameter(Mandatory=$false)][bool]$ForceNumbering=$false
    )

    begin
    { 
        #region     Embedded Functions

        # "Variables" that may change throughout script.
        # Functions are used to accomplish this task
        function BaseLen {return "$base".trim().Length}      
        function BaseLenIsInclusiveOf
        {
            [CmdletBinding()]
            param
            (
                [Parameter()]$low=2147483648,
                [Parameter()]$high=2147483647
            )

            if ($low -eq "-"){$low=-2147483648 -as [int32]}
            if ($high -eq "+"){$high=2147483647 -as [int32]}

            $baseLength=(BaseLen)
            if ($baseLength -ge $low -and $baseLength -le $high) {return $true} else {return $false}
        }

        function BaseLeading_. {if ((BaseLenIsInclusiveOf 0 0)) {return $false} else {return (Edit-ReturnString_TrimThenSubstring "$base" 0 1) -eq "."}}
        function BaseLeading_\ {if ((BaseLenIsInclusiveOf 0 0)) {return $false} else {return (Edit-ReturnString_TrimThenSubstring "$base" 0 1) -eq "\"}}
        function BaseLeading_\. {if ((BaseLenIsInclusiveOf 0 0)) {return $false} else {return (Edit-ReturnString_TrimThenSubstring "$base" 0 2) -eq "\."}}
        function baseSubStr_0_LenMinus1 {if ((BaseLenIsInclusiveOf 0 0)){return "$base"} else {return Edit-ReturnString_TrimThenSubstring "$base" 0 ((BaseLen)-1)}}            
        function BaseLeading_\\ {if ((BaseLenIsInclusiveOf 0 1)){return $false} else {return (Edit-ReturnString_TrimThenSubstring "$base" 0 2) -eq "\\"}}
        #function baseSubStr_1_2 {if ((BaseLenIsInclusiveOf 0 2)){return $base} else{return Edit-ReturnString_TrimThenSubstring $base 1 2}}
        function Base2ndChar_: {if ((BaseLenIsInclusiveOf 0 1)) {return $false} else {return (Edit-ReturnString_TrimThenSubstring "$base" 1 1) -eq ":"}}
        function Base2ndChar_\ {if ((BaseLenIsInclusiveOf 0 1)) {return $false} else {return (Edit-ReturnString_TrimThenSubstring "$base" 1 1) -eq "\"}}
        #function baseSubStr_1_2_Is:_:\ {if ((BaseLenIsInclusiveOf 0 2)){return $false} else {return (Edit-ReturnString_TrimThenSubstring $base 1 2) -eq ":\"}}
        function Base2nd3rdChar_.\ {if ((BaseLenIsInclusiveOf 0 2)){return $false} else {return (Edit-ReturnString_TrimThenSubstring "$base" 1 2) -eq ".\"}}
        #function baseSubStr_1_LenMinus1 {if ((BaseLenIsInclusiveOf 0 1)){return $base} else {return Edit-ReturnString_TrimThenSubstring $base 1 ((BaseLen)-1)}}
        #function baseSubStr_LenMinus1_1 {if ((BaseLenIsInclusiveOf 0 0)){return $base} else {return Edit-ReturnString_TrimThenSubstring $base ((BaseLen)-1) 1}}
        function BasePathExists {return (Test-Path -Path "$base")}
        function BasePathIsValid {return (Test-Path "$base" -IsValid)}
        function NoNewFldr_BasePathIsRelative
        {
            if ((("$base" -eq '.\') -or ("$base" -eq '.')) -and !(Base2ndChar_:))
            {
                return $true
            }
            else
            {
                return $false
            }
        }

        #endregion  Embedded Functions  

        #region     Global Variable & Shortened Parameter Variable Names

        # Parameter Variables
        [string]$base=$NewFolderBaseName
        $leading=$AppendedNumberTotalDigits
        $start=$StartNumber
        $force=$ForceNumbering

        # Other Variables
        $uncServer=""
        $uncShare=""
        $uncRootPath=""
        $uncRootIsValid=$false
        $baseIsOnlyUNCroot=$false
        $uncFolder=""

        $uniqueFolderBaseName="Unique Folder Base"
        $forceUniqueFolder=$false
        $isWinDriveRoot=$false
        $baseIsOnlyUNCroot=$false

        

        #endregion  Global Variable & Shortened Parameter Variable Names

        # Test if $NewFolderBaseName passed by user is in a valid format. If not, insert generic $NewFolderBaseName in current directory
        #Test-Path -Path $NewFolderBaseName

        # Reformat UNC

        if ((BaseLeading_\\))
        {            
            $uncServer=("$base" -split "\\")[2]
            $uncShare=("$base" -split "\\")[3]

            $uncRootPath="\\$uncServer\$uncShare"

            if ($uncShare -ne "")
            {
                $uncRootIsValid=((Test-Path -Path "$uncRootPath"))
            }

            if ($uncRootIsValid)
            {
                $counter=0
                foreach ($i in ("$base" -split "\\"))
                {
                    if ($counter -le 3){}
                    elseif ($counter -eq 4)
                    {
                        $uncFolder+=$i
                    }
                    else 
                    {
                        $uncFolder+="\"+$i
                    }    
                    $counter++
                }
    
                if ("$uncFolder" -eq "")
                {
                    $baseIsOnlyUNCroot=$true
                }
            }
            else
            {
                $base=".\"
            }
        }

        # Determine if $base is a Windows drive root only (e.g. "c:\"; "c:"; "\" -- NOT "c:\<something more>")

        if (!(BaseLeading_\\))
        {
            $isWinDriveRoot=((Test-ReturnBool_PathIsWinDriveRoot "$base"))
        }
        
        # Test if $base folder can be created. In not, $base=".\"
        if (!($isWinDriveRoot) -and ($uncRootIsValid -or !(BaseLeading_\\)))
        {
            if (!(Test-ReturnBool_FolderCanBeCreated "$base"))
            {
                $base=".\"
            }
        }
        # $base is current path (.\ OR .) or is invalid format --> $base=".\UniquePath"
        if ((BasePathExists))
        {
            if ($baseIsOnlyUNCroot) 
            {
                $forceUniqueFolder=$true
            }
            elseif ((NoNewFldr_BasePathIsRelative) -or !(BasePathIsValid)) 
            {
                $forceUniqueFolder=$true
                $base=(Resolve-Path .\)
            }    
            elseif ((Test-ReturnBool_PathIsWinDriveRoot "$base"))
            {
                $forceUniqueFolder=$true
                $base=(Resolve-Path "$base").path
            }
            # If $base exists and is NOT root drive", resolve full path        
            elseif ((BasePathExists) -and (BaseLenIsInclusiveOf 4 +) -and (Base2ndChar_:))
            {
                $base=(Resolve-Path -Path "$base").Path
            }
        }
        # If $base doesn't exist AND ...
        elseif (!(BasePathExists))
        { 
            if ($uncRootIsValid -and !($baseIsOnlyUNCroot))
            {
                $base=(Join-Path "$uncRootPath" -ChildPath "$uncFolder")
            }
            # AND ... check if it is relative       
            elseif ((BaseLeading_.) -and ((Base2ndChar_\) -or (Base2nd3rdChar_.\)))
            {
                $base=(Join-Path ((Resolve-Path .\).path) -ChildPath "$base")
            }
            elseif ((Base2ndChar_:) -and (BaseLenIsInclusiveOf 2 3))
            {
                $forceUniqueFolder=$true
                $base=(Resolve-Path -path ".\")
            }
            elseif ((Base2ndChar_:) -and (BaseLenIsInclusiveOf 4 +))
            {
                #do nothin
            }
            elseif ((BaseLeading_\) -and !(BaseLeading_\\))
            {
                $base=(Get-Location).drive.Root.Substring(0,2)+"$base"
            }
            else
            {
                $base=(Join-Path -path (Resolve-Path -path .\) -ChildPath "$base")
            }
        }
        # if (!($uncRootIsValid) -and !(BasePathExists))
        # {
        #     #$base=[system.io.path]::GetFullPath((Join-path -path (Resolve-Path -Path .\) -ChildPath "$base"))
        $base=[system.io.path]::GetFullPath($base)
        # }
        # elseif(($uncRootIsValid))
        # {

        # }

        if (!($isWinDriveRoot))
        {
            $base="$base".TrimEnd('\')
        }
    }

    process
    {
        if ((BasePathExists) -and $forceUniqueFolder)
        {
            $base=(Join-Path "$base" -ChildPath "$uniqueFolderBaseName")
        }

        if (!(BasePathExists) -and $force -eq $false)
        {
            return "$base".TrimEnd('\')
        }
        elseif (!(BasePathExists) -and $force -eq $true)
        {
            $formattedCounter=("{0:d$leading}" -f $start)
            return "$("$base".trimend('\')) $formattedCounter"
        }

        if ((BasePathExists))
        {    
            $folderExists=$true
            while ($folderExists)
            {
                $formattedCounter=("{0:d$leading}" -f $start)
                $newPath="$base $formattedCounter"
                if (Test-Path -Path "$newPath") {$start++; continue}
                elseif (!(Test-Path -Path "$newPath"))
                {
                    $folderExists=$false
                    return "$($newPath.trimend('\'))"
                }
            }
        }
        return "$base".trimend('\')
    }

    End
    {

    }



        # # No longer applicable
        # #region First character '\'; Transform to Windows format
        # if ((baseSubStr_0_1) -eq '\' -and (BaseLen) -eq 1)
        # {
        #     Write-Output "2"
        #     $base=(Get-Location).Drive.Name+"`:\"
        # } 
        # elseif ((baseSubStr_0_1) -eq '\' -and (BaseLen) -gt 1)
        # {
        #     Write-Output "2"
        #     $base=(Get-Location).Drive.Name+"`:\"+(baseSubStr_1_LenMinus1)
        # }

        # #endregion First character '\'; Transform to Windows format

}
