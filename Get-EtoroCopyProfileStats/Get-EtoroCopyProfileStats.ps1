.\PublicConfigVars.Ps1
$UrlInfluxAPILookupKey = "URLInflux"
$UrlEtoroLookupKey = "URLCopyProfileStats"

$StrapiKeyValues = Invoke-RestMethod $URLStrapiEtoro
$EtoroUri = $StrapiKeyValues.$UrlEtoroLookupKey
$InfluxUri = $StrapiKeyValues.$UrlInfluxAPILookupKey

$UnixEpochStart = New-Object DateTime 1970, 1, 1, 0, 0, 0

[datetime]$TimeNow = Get-Date
$Timeval = [int64]((([datetime]$TimeNow) - $UnixEpochStart).TotalMilliseconds * 1000000)

$R = Invoke-RestMethod $EtoroUri

foreach ($profileObj in $r.AggregatedMirrors) {
    $ParentUsername = $profileObj.ParentUsername
    $NetProfit = $profileObj.NetProfit

    $postParams = "profiles,parentusername=$ParentUsername netprofit=$NetProfit $Timeval"
    Invoke-RestMethod -Uri $InfluxUri -Method POST -Body $postParams  | Out-Null
}