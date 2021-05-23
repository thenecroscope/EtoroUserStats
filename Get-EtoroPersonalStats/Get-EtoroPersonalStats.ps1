Push-Location
$Fullpath = $MyInvocation.MyCommand.Path
$Directory = Split-Path $Fullpath -Parent
Set-Location $Directory

.\PublicConfigVars.Ps1
$UrlInfluxAPILookupKey = "URLInflux"
$UrlEtoroLookupKey = "URLPersonalUserStats"

$StrapiKeyValues = Invoke-RestMethod $URLStrapiEtoro
$EtoroUri = $StrapiKeyValues.$UrlEtoroLookupKey
$InfluxUri = $StrapiKeyValues.$UrlInfluxAPILookupKey

$MyProfileRaw = Invoke-RestMethod $EtoroUri

foreach ($month in $myProfileRaw.monthly) {
    $unixEpochStart = New-Object DateTime 1970, 1, 1, 0, 0, 0
    $MonthDate = Get-Date ($month.Start)
    $MonthGain = $Month.Gain
    $Timeval = [int64]((([datetime]$MonthDate) - $unixEpochStart).TotalMilliseconds * 1000000)
    $PostParams = "myprofileStats,parentusername=thenecroscope pctgain=$MonthGain $Timeval"
    Invoke-RestMethod -Uri $InfluxUri -Method POST -Body $PostParams | Out-Null
}