[CmdletBinding()]
param (
    
    # File that contains SQL query
    [Parameter(
        Position = 0,
        ParameterSetName = "ParameterSetName",
        HelpMessage = "File that contains SQL query.")]
    [ValidateNotNullOrEmpty()]
    [string]
    $QueryFile = "query.sql",

    # ComputableFacts API Key
    [Parameter(
        Mandatory = $true,
        HelpMessage = "ComputableFacts API Key."
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $CfApiKey,

    # ComputableFacts API URL
    [Parameter(
        Mandatory = $true, 
        HelpMessage = "ComputableFacts API URL."
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $CfApiUrl,

    # Number of rows received for each API requests
    [Parameter(HelpMessage = "Number of rows received for each API requests.")]
    [int]
    $RowsPerPage = 10,

    # Delegate SQL request
    [Parameter(HelpMessage = "Delegate SQL request.")]
    [int]
    $Delegate = 1

)

Write-Debug "QueryFile=$QueryFile" 

$query = Get-Content $QueryFile

$start = 0

do {

    $currentQuery = "$query LIMIT $start, $RowsPerPage"
    Write-Debug "currentQuery=$currentQuery"

    $returnFormat = if ($requestNum -eq 1) { 'csv_with_header' } else { 'csv' }

    $response = Invoke-WebRequest "$CfApiUrl/api/v2/public/materialize/sql" `
        -Method 'GET' `
        -ContentType 'application/json; charset=utf-8' `
        -Headers @{'Authorization' = "Bearer $CfApiKey" } `
        -Body @{ 'query' = $currentQuery; 'format' = $returnFormat; 'delegate' = $Delegate }

    $json = ($response.Content | ConvertFrom-Json) 

    $json.data

    $start += $RowsPerPage

    Write-Debug $json.meta.count

} until ($json.meta.count -lt $RowsPerPage)



