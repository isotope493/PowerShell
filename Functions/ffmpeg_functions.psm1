Import-Module .\DateTime_Functions.psm1
# Syntax DateTime_HMS_Time_To_Seconds -inputHMStime HH:MM:SS.sss

function ffmpeg_TrimFrameExactly_ReturnFile
{
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)][Alias("Source","Src")][string]$SourceFile,
        [Parameter(mandatory=$true)][Alias("Container","Cntr")][string]$OutputContainer,
        [Parameter(mandatory=$true)][Alias("Destination","Dstn")][string]$DestinationPath,
        [Parameter(mandatory=$true)][Alias("OutputFileNoExt","OutFileNoExt")][string]$OutpuFileNoExtension,
        # [Parameter()][Alias("StartF","StrtF","SFrm","SF","StrtFrm")][int32]$StartFrame=$null,
        # [Parameter()][Alias("EndF","EFrm","EF","EndFrm")][int32]$EndFrame=$null,
        # [Parameter()][Alias("StartT","StrtT","STm","ST","StrtTm")][double]$StartTimeSeconds=$null,
        # [Parameter()][Alias("EndT","EnT","ETm","ET","EnTm")][double]$EndTimeSeconds=$null,
        # [Parameter()][Alias("StartT","StrtT","STm","ST","StrtTm")][string]$StartTimeHMS=$null,
        # [Parameter()][Alias("EndT","EnT","ETm","ET","EnTm")][string]$EndTimeHMS=$null,
        # [Parameter()][Alias("AppendStartEndTimes")][bool]$AppendStartEndTimesFromSourceToOutputFileName=$false        
    )

    $source=(Resolve-Path $SourceFile)

    $baseName=([IO.FileIno]$source).$baseName

    write-output $baseName

    # if ($null -ne $StartFrame -and $null -ne $EndFrame)
    # {
    #     # Get frame rate from ffprobe
    #     $frameRate="=ffprobe -i $source COMMAND HERE"
    #     $start=$StartFrame/$frameRate
    #     $end=$EndFrame/$frameRate
    #     $duration=$end-$start

    # }
    # elseif ($null -ne $StartTimeSeconds -and $null -ne $EndTimeSeconds)
    # {}
    # elseif ($null -ne $StartTimeHMS -and $null -ne $EndTimeHMS)
    # {
    #     DateTime
    # }
    # else {exit}

    #ffmpeg.exe -err_detect ignore_err -i "$source" -ss $start -t $duration -c copy "$DestinationPath\$OutpuFileNoExtension.$OutputContainer"
}

function ffmpeg_TrimFrameKeyFrameMargins_ReturnFile
{}

function ffmpeg_ConcatenateClips_ReturnFile
{}

function ffmpeg_Encode_ReturnFile
{}
