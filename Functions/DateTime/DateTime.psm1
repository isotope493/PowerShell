function Convert-HMS_Time_To_Seconds
# Syntax HMS_Time_To_Seconds -inputHMStime HH:MM:SS.sss
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory=$true)][string]$InputHMStime
    )

    Begin
    {
        $hour=($inputHMStime -split ":")[0] -as [int32]
        $minute=($inputHMStime -split ":")[1] -as [int32]
        $seconds=($inputHMStime -split ":")[2] -as [double]
    }

    Process
    {
        $timeInSeconds=($hour*3600+$minute*60+$seconds) -as [double]
        $return=$timeInSeconds
    }

    End
    {
        return $return
    }
    
}