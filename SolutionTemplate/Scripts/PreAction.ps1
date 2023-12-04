Param(
[System.Object] [Parameter(Mandatory = $true)] $Conn,
[string] [Parameter(Mandatory = $true)] $EnvironmentName,
[string] [Parameter(Mandatory = $true)] $Path
)

$ProgressPreference = 'SilentlyContinue'
. (Join-Path $PSScriptRoot "DeploymentFunctions.ps1")
