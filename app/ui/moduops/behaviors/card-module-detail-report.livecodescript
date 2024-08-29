script "card-module-detail-report"
on preOpenCard
   lock screen
end preOpenCard

on openCard
   local tModuleDetailA

   -- load report data
   put loadModuleDetailData() into tModuleDetailA
   set the pgData of widget "pgModuleDetail" to tModuleDetailA
end openCard

on closeCard

end closeCard


function loadModuleDetailData
   local tModuleDetailSQL

   put module.detailReport() into tModuleDetailSQL

end loadModuleDetailData


/**
* Load Car Type data from DB to UI
*/
on loadCarRequestData
   lock screen
   
   local tDataA
   local tModuleID
   local tWOA
   local tModuleA
   local tConsigneeA
   local tCarTypeA
   local tSpotA
   local tIndex=1
   
   // Reset Active DB Record and Get all Modules
   //dbResetQuery
   // limit search from Module Search field
   if field "searchModule" is not "" then
      dbLike "name", field "searchModule"
   end if
   
   put dbGet("module") into tModuleA
   
   if tModuleA is an array then
      // get counts for Consignee, Drop Zone and Car Requests
      repeat for each key aModule in tModuleA
         //wait for 0 seconds with messages
         put tModuleA[aModule]["UUID"] into tModuleID
         
         put mdbQueryWOByModuleID(tModuleID) into tWOA
         
         repeat for each key aRequest in tWOA
            //wait for 0 seconds with messages
            
            // Get the Consignee data for this Workorder
            //dbResetQuery
            dbWhere "UUID", tWOA[aRequest]["consigneeID"]
            put dbGet("consignee") into tConsigneeA
            
            // Get Car Type data for the car specified
            //dbResetQuery
            dbWhere "UUID", tWOA[aRequest]["carID"]
            put dbGet("carType") into tCarTypeA
            
            // Get Spot data for the selected Workorder
            dbWhere "UUID", tWOA[aRequest]["spotID"]
            put dbGet("spot") into tSpotA
            
            // Set the report output data elements
            put tModuleA[aModule]["name"] into tDataA[tIndex]["module"]
            put tConsigneeA[1]["name"] into tDataA[tIndex]["consignee"]
            put tCarTypeA[1]["class"] into tDataA[tIndex]["class"]
            put tCarTypeA[1]["short"] into tDataA[tIndex]["short"]
            put tCarTypeA[1]["length"] into tDataA[tIndex]["length"]
            put tSpotA[1]["track"] into tDataA[tIndex]["dropZone"]
            put tWOA[aRequest]["CPW"] into tDataA[tIndex]["CPW"]
            add 1 to tIndex
         end repeat
      end repeat   
      
      // update the UI with the results of the query
      set the dgData of group "dgCarRequests" to tDataA
      
   else
      // no data found so clear out the UI
      set the dgText of group "dgCarRequests" to ""
   end if
   
   unlock screen
end loadCarRequestData

on searchModule
   switch the cReportType of this card
      case "Car Requests"
         send "loadCarRequestData" to this card in 0 seconds
         //loadCarRequestData
         break
   end switch
end searchModule
