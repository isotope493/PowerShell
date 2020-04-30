function sandbox
{
    param ([string]$path,$test)

    foreach ($i in $path.ToCharArray())
    {
        Write-Output $i
    }
}