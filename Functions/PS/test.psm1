function Get-ParameterInputOrder_ReturnArray
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $My_Invocation
    )

    $precedingCharIsSpace=$false
    $inParameter=$false
    $inDoubleQuote=$false
    $currentParameter=$null
    $parameterArray=@()

    foreach ($i in $My_Invocation.ToCharArray())
    {
        if ($i -eq ' ' -and $inParameter)
        {
            $inParameter=$false
            $parameterArray+=,$currentParameter
            $precedingCharIsSpace=$true
        }
        elseif ($i -eq '-' -and !$inDoubleQuote -and $precedingCharIsSpace)
        {
            $inParameter=$true
            $currentParameter+=$i
            $precedingCharIsSpace=$false
        }
        elseif ($inParameter)
        {
            $currentParameter+=$i
        }
    }
    Write-Output $parameterArray
}