# SYNTAX: Edit-ReturnString_TrimThenSubstring || Edit-ReturnString_TrimThenSubstring [-InputString || Input] <string> [-StartPosition || Start] <string> [[-NumberOfCharacters || NumChars] <string>] [[-EndPosition || End] <string>] [[-DoNotTrim || Trim] <bool>]
function Edit-ReturnString_TrimThenSubstring
{
    # SYNTAX: Edit-ReturnString_TrimThenSubstring || Edit-ReturnString_TrimThenSubstring [-InputString || Input] <string> [-StartPosition || Start] <string> [[-NumberOfCharacters || NumChars] <string>] [[-EndPosition || End] <string>] [[-DoNotTrim || Trim] <bool>]

    <#
        .SYNOPSIS
            Edit-ReturnString_TrimThenSubstring will accept an "InputString" and return a substring based on the user-entered parameters: "StartPosition", "NumberOfCharacters", and "EndPosition".

            This function accepts both the "EndPosition" and "NumberOfCharacters" as parameters but only one is necessary to function.

            This function also accepts a boolean, "DoNotTrim" if you do not want the "InputString" trimmed for extraneous whitespace at the start and end of the string. It defaults to a false value

            See the DESCRIPTION in "Get-Help Edit-ReturnString_TrimThenSubstring" for greater detail
            See detailed PARAMETER information in "Get-Help Edit-ReturnString_TrimThenSubstring -Parameters *"

        .DESCRIPTION
            Edit-ReturnString_TrimThenSubstring will accept an "InputString" and return a substring based on the user-entered parameters: "StartPosition", "NumberOfCharacters", and "EndPosition".

            This function accepts both the "EndPosition" and "NumberOfCharacters" as parameters but only one is necessary to function.

            This function also accepts a boolean, "DoNotTrim" if you do not want the "InputString" trimmed for extraneous whitespace at the start and end of the string. It defaults to a false value
            ------------------------------------------------
            "StartPosition", "NumberOfCharacters", and "EndPosition" will accept arithmetic expressions (e.g. 3+2; 5-4)

            This function accepts both the "EndPosition" and "NumberOfCharacters" as parameters but only one is necessary to function.

            If both the "EndPosition" and "NumberOfCharacters" is specified, "NumberOfCharacters" will be used by default if within the range of the "StartPosition" and the length of the string. If "NumberOfCharacters" is outside those bound and "EndPosition" is also specificed, "EndPOsition" will be used. If "EndPosition" is not provided or outside the bounds, the "NumberOfCharacters" will be changed to either the "StartPosition" (1 character) or the length of the string depending which side "NumberOfCharacters" is out of bounds.

            If "StartPosition" is not a number or if either "NumberOfCharacters" or "EndPosition" is not a number, the function will return the "InputString".
            ------------------------------------------------
            See detailed PARAMETER information in "Get-Help Edit-ReturnString_TrimThenSubstring -Parameters *"
    #>

    [CmdletBinding(DefaultParameterSetName="First")]
    param 
    (
        # Enter string 
        [Parameter(Mandatory=$true,position=0,ParameterSetName="First")]
        [Parameter(Mandatory=$true,position=0,ParameterSetName="Second")]
            [Alias("Input")][string]$InputString,
        # Enter the start position of the substring
        [Parameter(Mandatory=$true,position=1,ParameterSetName="First")]
        [Parameter(Mandatory=$true,position=1,ParameterSetName="Second")]
            [Alias("Start")][string]$StartPosition,
        # (Preferred) Enter the number of characters from the start of the substring
        [Parameter(Mandatory=$false,position=2,ParameterSetName="First")]
        [Parameter(Mandatory=$false,position=2,ParameterSetName="Second")]
            [Alias("NumChars")][string]$NumberOfCharacters,
        # (Alternative) Enter the end position (within the input string) within the input string
        [Parameter(Mandatory=$false,position=3,ParameterSetName="First")]
        [Parameter(Mandatory=$false,position=3,ParameterSetName="Second")]
            [Alias("End")][string]$EndPosition,
        # (Optional) Enter $true/$false as whether to trim input string whitespace before extracting the substring
        # Default: $false
        [Parameter(Mandatory=$false,position=4,ParameterSetName="First")]
        [Parameter(Mandatory=$false,position=4,ParameterSetName="Second")]
            [Alias("Trim")][bool]$DoNotTrim=$false
    )

    $input=$InputString
    $start=$StartPosition
    $end=$EndPosition
    $chars=$NumberOfCharacters
    [int32]$stringLen=$input.Length
    

    
    if (!($start -match "^[\d\.]+$"))
        {$start=(Invoke-Expression "$start")}
    if (!($end -match "^[\d\.]+$") -and $end -ne "")
        {$end=(Invoke-Expression "$end")}
    if (!($echarsnd -match "^[\d\.]+$") -and $chars -ne "")
        {$chars=(Invoke-Expression "$chars")}

    $start=$start -as [int32]
    $end=$end -as [int32]
    $chars=$chars -as [int32]

    # If $start is not a number or ($end is not a number and $char is empty or not a number) ==> return $inputString
    # IF $start ![0-9] OR ($end ![0-9]  AND ($chars IsEmpty OR $chars ![0-9] ))) return $inputString
    if (!($start -match '^[0-9]+$') -or (!($end -match '^[0-9]+$') -and ($chars -eq "" -or !($chars -match '^[0-9]+$'))))
    {
        return $input
    }

    if ($chars -match '^[0-9]+$' -and $end -match '^[0-9]+$')
    {
        # If $chars is out of bounds AND $end is within bounds, use $end (bounds: $start - $stringLen)
        # (!(1 <= $chars <= $stringLen) AND ($start <= $end <= $stringLen)) ==> ($chars=$end-$start+1)
        if ((($start+$chars -gt $stringLen) -or ($start+$chars -lt 1)) -and ($end -le $stringLen) -and ($end -ge $start)) 
            {$chars=$end-$start+1}
        elseif ($start+$chars -gt $stringLen) {$chars=$stringLen-$start}
        elseif ($start+$chars -lt 1) {$chars=1}
    }
    # If $char is out of bounds, correct to end of string or start of string depending on which side is out of bounds
    elseif ($chars -match '^[0-9]+$' -and !($end -match '^[0-9]+$'))
    {
        if ($start+$chars -gt $stringLen) {$chars=$stringLen-$start}
        elseif ($start+$chars -lt 1) {$chars=1}
    }

    # IF $chars is a number, $end is irrelevant. (if $chars was out of bounds, it was corrected above with $end considered if existent)
    # If $chars is empty or not a number (AND $end is a number), ensure $end is within bounds; if not, correct to $start or $stringLen
    if ($chars -eq "" -or !($chars -match '^[0-9]+$'))
    {
        if ($end -gt $stringLen) {$end=$stringLen}
        if ($end -lt $start) {$end=$start+1}
        $chars=$end-$start
    }    

    if ($DoNotTrim){return "$input".Substring($start,$chars)}
    else {return "$input".Trim().Substring($start,$chars)}
}

