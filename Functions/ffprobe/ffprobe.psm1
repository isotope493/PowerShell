function Find-ffprobe_AudioFrameMetadata_ReturnArray
{
    param
    (
        [Parameter(Mandatory=$true)][string]$sourceFile,
        [Parameter()][bool]$IncludeMediaType=$true,
        [Parameter()][bool]$IncludeStreamIndex=$true,
        [Parameter()][bool]$IncludeKeyFrame=$true,
        [Parameter()][bool]$IncludePktPts=$true,
        [Parameter()][bool]$IncludePktPtsTime=$true,
        [Parameter()][bool]$IncludePktDts=$false,
        [Parameter()][bool]$IncludePktDtsTime=$false,
        [Parameter()][bool]$IncludeBestEffortTimestamp=$true,
        [Parameter()][bool]$IncludeBestEffortTimestampTime=$true,
        [Parameter()][bool]$IncludePktDuration=$true,
        [Parameter()][bool]$IncludePktDurationTime=$true,
        [Parameter()][bool]$IncludePktPos=$false,
        [Parameter()][bool]$IncludePktSize=$false,
        [Parameter()][bool]$IncludeSampleFmt=$false,
        [Parameter()][bool]$IncludeNbSamples=$false,
        [Parameter()][bool]$IncludeChannels=$false,
        [Parameter()][bool]$IncludeChannelLayout
    )

    # Will probe until first video frame discovered and store every line of output in 1D array for further processing.
    # Key output variables:
    # $workingArray
    begin 
    {
         ffprobe -i "$sourceFile" -show_Frames 2>1 | ForEach-Object ($_) {

            # Array to store raw output from ffprobe
            $workingArray+=@($_)
        }
    }
    
    process
    {
        # Find relative position of last "[/FRAME]" to beginning of array
        
        #region Define Variables
        # When looping through $workingArray, current line within array (startin at zero)
        $currentLine=0
        # Count number of lead-in audio frames before first video frame
        $leadinAudioFrames=0
        # Line within $workingArray of last full frame
        $linePositionLastFullFrame
        # Cumulative number of units before first video frame. Number of units within a frame is based on frame rate of source. 
        $total_Pkt_Duration=0
        # Cumulative duration of audio frames in seconds before first video frame.
        $total_Pkt_Duration_Time=0
        # Will assign which audio stream (if there are multiple) is being used to determine the lead-in audio before a video frame. Which stream is used in the case of multiple audio streams is the stream_Index within the first audio frame discovered.
        $AudioStreamIndex=$null
        # Use to information conditional statements if they are currently analyzing the first audio frame in the file. This condition will be used in combination with boolean varibles as to whether the current frame is an audio frame. Once the first audio frame is discoverd, this variable will turn to $false. It is used to help identify the audio stream_Index being used but once determined, switched to $false so as to avoid the stream_Index changing.
        $firstAudioFrame=$true
        # When looping through $workingArray, it will indicate when the current frame data has ended so it can be analyzed. It will switch to false at end of frame and true at start of frame.
        $openFrame=$null
        # Used to help sub-loops know where a frame begins within $workingArray.
        $openPosition=$null
        # Used to help sub-loops know where a frame ends within $workingArray.
        $closePosition=$null        
        # Indicates to condition statements if the current frame is an audio frame
        $isAudioFrame=$null
        # Will coun number of audio frames before first video frame
        $leadinAudioFrames=$null
        #endregion Define Variables

        # Loop through $workingArray to find position of last full frame entry ("[/FRAME]")
        # key output variables:
        #$linePositionLastFullFrame
        $workingArray | foreach-object {
            if ($_ -eq "[/FRAME]")
            {
                $global:linePositionLastFullFrame=$currentLine
            }
            $currentLine++           
        }

        # Loop through all lines of the $workingArray to process frame data
        for ($i=0; $i -le $linePositionLastFullFrame; $i++)
        {

            # If start of frame, indicate so and position within $workingArray
            if ($workingArray[$i] -eq "[FRAME]") {$openFrame=$true; $openPosition=$i;}
            # If end of frame, indicate so and position within $workingArray. Indicate $isAudioFrame is $false to force subsequent analysis to determine this.
            if ($workingArray[$i] -eq "[/FRAME]") {$openFrame=$false; $closePosition=$i; $isAudioFrame=$false}

            # If start-end of frame determined and $firstAudioFrame has not been switched to $false, evalue frame to determine if audio. If audio, swith $firstAudioFrame to $false to prevent re-entering this condition. Then determine the stream_Index that will be used for further analysis within audio frames. This loop will not extract data that will be used to RETURN in this function. It is evaluating initional conditional statements so analysis can be performed after this loop.
            if ($openFrame -eq $false -and $firstAudioFrame -eq $true)
            {
                # Determine if current frame is an audio frame
                # Key output variables:
                # [bool]$isAudioFrame
                for ($j=$openPosition; $j -le $closePosition; $j++)
                {
                    if (($workingArray[$j] -split "=")[0] -eq "media_Type" -and ($workingArray[$j] -split "=")[1] -eq "audio")
                    {
                        $isAudioFrame=$true
                        break
                    }
                }

                # If current frame is an audio frame, determine audio stream_Index to use
                # Key output variables:
                # [int32]$AudioStreamIndex
                if ($isAudioFrame -eq $true -and $firstAudioFrame -eq $true)
                {
                    # Switch $firstAudioFrame to $false so stream_Index does not change
                    $firstAudioFrame=$false
                    for ($j=$openPosition; $j -le $closePosition; $j++)
                    {
                        if (($workingArray[$j] -split "=")[0] -eq "stream_Index")
                        {
                            $AudioStreamIndex=($workingArray[$j] -split "=")[1]
                            # this condition will be re-evaluated in next loop so it is safe to set to $false
                            $isAudioFrame=$false 
                            break
                        }
                    }
                }  
            }

            # Analyze frame to determine if it is an audio frame and the stream_Index desired. If so, gather data to be RETURNED later.
            if ($openFrame -eq $false -and $firstAudioFrame -eq $false)
            {
                # Determine if current frame is an audio frame and is correct stream_Index
                for ($j=$openPosition; $j -le $closePosition; $j++)
                {
                    if (($workingArray[$j] -split "=")[0] -eq "media_Type" -and ($workingArray[$j] -split "=")[1] -eq "audio")
                    {
                        $isAudioFrame=$true
                    }
                    if (($workingArray[$j] -split "=")[0] -eq "stream_Index" -and ($workingArray[$j] -split "=")[1] -eq $AudioStreamIndex)
                    {
                        $correctAudioStream=$true
                    }
                    # Increment #leadinAudioFrames if current frame is audio frame and correct stream_Index.
                    if ($isAudioFrame -eq $true -and $correctAudioStream -eq $true) {$leadinAudioFrames++; break}
                }

                # Gather data if in an audio frame and the correct stream_Index
                if ($isAudioFrame -eq $true -and $correctAudioStream -eq $true)
                {
                    for ($j=$openPosition; $j -le $closePosition; $j++)
                    {
                        if (($workingArray[$j] -split "=")[0] -eq "pkt_Duration")
                        {
                            $total_Pkt_Duration+=($workingArray[$j] -split "=")[1]
                        }
                        if (($workingArray[$j] -split "=")[0] -eq "pkt_Duration_Time")
                        {
                            $total_Pkt_Duration_Time+=($workingArray[$j] -split "=")[1]
                        }
                    }
                }
            }
        }
    }
    # Return data related to audio lead-in for a video file with audio
    end 
    {
        $return=@($total_Pkt_Duration,$total_Pkt_Duration_Time,$leadinAudioFrames)
        return $return
    }
}

function Find-ffprobe_VideoFrameMetadata_ReturnArray
{}

function Find-ffprobe_VideoAudioFrameMetadata_ReturnArray
{}

function Find-ffprobe_AudioPacketMetadata_ReturnArray
{}

function Find-ffprobe_VideoPacketMetadata_ReturnArray
{}

function Find-ffprobe_VideoAudioPacketMetadata_ReturnArray
{}

function Find-ffprobe_AudioStreamMetadata_ReturnArray
{}

function Find-ffprobe_VideoStreamMetadata_ReturnArray
{}

function Find-ffprobe_VideoAudioStreamMetadata_ReturnArray
{}