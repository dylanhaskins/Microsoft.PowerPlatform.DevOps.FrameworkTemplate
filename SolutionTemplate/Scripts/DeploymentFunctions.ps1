#
# _DeploymentFunctions.ps1
#

function Wait-BulkDeleteOperation
(
    [Microsoft.Xrm.Sdk.Query.QueryByAttribute] $bulkQuery,
    [Microsoft.Xrm.Sdk.EntityCollection] $entityCollection,
    [Int] $operationEndedStatus,
    [Microsoft.Xrm.Tooling.Connector.CrmServiceClient] $Conn
) {
    $createdBulkDeleteOperation = $null
    $ARBITRARY_MAX_POLLING_TIME = 180
    $minutesTicker = $ARBITRARY_MAX_POLLING_TIME

    while ($minutesTicker -gt 0) {
        #Make sure the async operation was retrieved.
        if ($entityCollection.Entities.Count -gt 0) {
            #Grab the one bulk operation that has been created.
            $createdBulkDeleteOperation = $entityCollection.Entities[0]

            #Check the operation's state.
            #NOTE: If a recurrence for the BulkDeleteOperation was
            #specified, the state of the operation will be Suspended,
            #not Completed, since the operation will run again in the
            #future.
            if ($createdBulkDeleteOperation.Attributes["statecode"].Value -ne $operationEndedStatus) {
                #The operation has not yet completed.  Wait a second for
                #the status to change.
                Start-Sleep -Seconds 30                
                $minutesTicker = $minutesTicker - .5
                #Retrieve a fresh version of the bulk delete operation.
                $entityCollection = $Conn.RetrieveMultiple($bulkQuery)
            }
            else {
                #Stop polling as the operation's state is now complete.
                $minutesTicker = 0
                Write-Host "The BulkDeleteOperation record has been retrieved."
               
            }
        }
        else {
            #Wait a second for async operation to activate.
            Start-Sleep -Seconds 1             
            $minutesTicker--
            #Retrieve the entity again.
            $entityCollection = $Conn.RetrieveMultiple($bulkQuery);
        }
    }
    return $createdBulkDeleteOperation
}

function Set-SystemSettings
(
    [Microsoft.Xrm.Tooling.Connector.CrmServiceClient] $Conn
) {
    Write-Host "Setting System Settings"
		
    #Fetching Organization entity records and updating the settings
    $orgs = Get-CrmRecords -conn $Conn -EntityLogicalName "organization" -Fields "organizationid", "featureset"

    #Check if any record fetched
    if ($orgs.CrmRecords.Count -gt 0) {
        #Updating settings
        $syssettings = $orgs.CrmRecords[0]

        $updateFields = @{ }
        $updateFields.Add("disablesocialcare", $true)   
        $updateFields.Add("isduplicatedetectionenabled", $false)   
        $updateFields.Add("displaynavigationtour", $false)        
        $updateFields.Add("isauditenabled", $true)
		$updateFields.Add("isuseraccessauditenabled", $true)
		$updateFields.Add("isreadauditenabled", $true)		
        $updateFields.Add("autoapplysla", $false)   
        $updateFields.Add("suppresssla", $false)   
        $updateFields.Add("allowusersseeappdownloadmessage", $false)   
        $updateFields.Add("globalhelpurlenabled", $false)   
        $updateFields.Add("defaultcountrycode", "+64")   
        $updateFields.Add("isdefaultcountrycodecheckenabled", $true)   
        $updateFields.Add("enablebingmapsintegration", $false)   
        $updateFields.Add("isautosaveenabled", $false)   
        $updateFields.Add("plugintracelogsetting", (New-CrmOptionSetValue 2))   
        $updateFields.Add("useskypeprotocol", $false)   
        $updateFields.Add("defaultcrmcustomname", "Admin (Classic UI)")   			
        $updateFields.Add("localeid", 5129)   # New Zealand
        $updateFields.Add("enablelpauthoring", $false)
        $updateFields.Add("autoapplydefaultoncasecreate", $false)
        $updateFields.Add("autoapplydefaultoncaseupdate", $false)
        $updateFields.Add("enablemicrosoftflowintegration", $false)
        $updateFields.Add("isexternalsearchindexenabled", $true)
		$updateFields.Add("ispresenceenabled", $false)
        $updateFields.Add("allowlegacyclientexperience", $false)
        $updateFields.Add("iscontextualemailenabled", $true)

        if ($null -ne $syssettings.featureset -and $syssettings.featureset.Contains("<name>FCB.GUIDEDHELP</name><value>true</value>")) {
            $updateFields.Add("featureset", $syssettings.featureset.Replace("<name>FCB.GUIDEDHELP</name><value>true</value>", "<name>FCB.GUIDEDHELP</name><value>false</value>"))
        }

        #updating record			
        Set-CrmRecord -conn $Conn -Fields $updateFields -Id $syssettings.organizationid -EntityLogicalName "organization"
    } 

    Write-Host $("Updated CRM System Settings.")
}

