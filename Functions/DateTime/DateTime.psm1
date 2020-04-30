function Convert-HMS_Time_To_Seconds_ReturnDouble
# Syntax HMS_Time_To_Seconds -inputHMStime HH:MM:SS.sss
{
    # REQUIRED MODULES
    #
    # No modules required

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