script "card-trainlists-behavior"
local sPageWidth, sManifestStyle
local sTrainUUID, sTrainA, sTrainRouteA
local sModuleA
local sConsigneeA
local sSpotA
local sManifestA
local sCarTypeA
local sPrevModule, sPrevConsignee, sPrevSpot

on buildManifest
    local tManifest, tTrainA, tTempA
    
    put the cWidth of this card into sPageWidth
    put the cPageStyle of this card into sManifestStyle
    put the cTrainUUID of card "Trainlists" into sTrainUUID
    put mdbQueryByUUID("train", sTrainUUID) into tTrainA
    put tTrainA[1]["route"] into tTempA
    put jsonToArray(tTempA) into sTrainRouteA
    
    -----
    local manifest,tActiveTrain,tTrains
    local tCarID,theCarName,tWOID
    local tConsigneeID,theConsigneeName,theSpotName
    local tCarTypes,tModules
    local tModuleID,manifestRemarks,tSpotID
    local trainManifest,moduleName,theModule
    local tSpots,tWorkorders,tConsignees
    -----
    
    lock screen
    
    put "" into tManifest
    put "" into field "trainlist"
    
    -- Manifest Header
    put outputHeader(tTrainA[1]) after tManifest
    
    -- Train Origin, Car Count & Length
    put outputTrainOrigin(tTrainA[1], sPageWidth) after tManifest
    
    -- Crew Instruction
    put outputCrewInstructions(tTrainA[1]) after tManifest
    
    -- Train Manifest
    put addManifest(sManifestStyle, sPageWidth) after tManifest
    
    -- Termination Instructions
    put outputTerminationInstructions(tTrainA[1]) after tManifest
    
    -- Footer
    put outputFooter(tTrainA[1], sPageWidth) after tManifest
    
    set the htmlText of field "trainlist" to tManifest
    if sPageWidth = "Half" then
        put the htmlText of field "trainlist" into tManifest
        
        --dispatch "outputTwoColumns" with tManifest
        put outputTwoColumns(tManifest) into tManifest
        
    end if
    
    set the htmlText of field "trainlist" to tManifest
    
    if sManifestStyle = "MRBT" then
        set the textfont of cd fld "trainlist" to "Courier"
    else if sManifestStyle = "Modern" then
        set the textfont of cd fld "trainlist" to "Arial"
    end if
    
    unlock screen
end buildManifest

function addManifest pManifestStyle pPageWidth
   local tOutput, tIndex, tManifestA, tFlag
   
   ## load in all cars for a train into the Manifest
   if the cSchedulingEngine of stack "Module Operations" = "MRBT" then
      put mdbMRBTOutput(sTrainUUID) into sManifestA
   else
      put mdbSmartyOutput(sTrainUUID) into sManifestA
   end if
   
   ## add in all train orders of a route into the Manifest
   put 1 into tIndex
   put "" into tManifestA
   
   repeat for each element aStop in sTrainRouteA
      if aStop["moduleID"] is empty then -- we have a Train Order
         
         ## Insert Train Order into the correct order of the Train's Manifest
         put "" into tManifestA
         put 1 into tIndex
         put false into tFlag
         repeat with i = 1 to the number of elements of sManifestA
            if not tFlag and (sManifestA[i]["stop"] > aStop["stop"]) then -- We found the point Train Order belongs
               put aStop["stop"] into tManifestA[tIndex]["stop"]
               put aStop["consignee"] into tManifestA[tIndex]["description"]
               add 1 to tIndex
               put true into tFlag
            end if
            put sManifestA[i] into tManifestA[tIndex]
            add 1 to tIndex
         end repeat
         if not tFlag then -- hit the end of the list so add in the Train Order
            put aStop["stop"] into tManifestA[tIndex]["stop"]
            put aStop["consignee"] into tManifestA[tIndex]["description"]
         end if
         put tManifestA into sManifestA
      end if
   end repeat
   
   if tManifestA is not empty then
      put tManifestA into sManifestA
   end if
   
   -- Format each line of work scheduled for a train
   ##put "<p><font size=8>" after manifest
   put "" into sPrevModule
   
   repeat for each element aWorkorder in sManifestA
      
      ## Check if this is a Train Order and add to output
      if aWorkorder["workorderID"] = "" then
         put "<p>" & aWorkorder["description"] & "</p>" after tOutput
         next repeat
      end if
      
      -- Module Name only when there's a new module in Manifest
      if aWorkorder["moduleName"] <> sPrevModule then
         put outputModuleName(pManifestStyle, aWorkorder["moduleName"], aWorkorder["stop"]) after tOutput
         
         -- Add module remarks
         if aWorkOrder["moduleRemarks"] is not empty then
            put formatRemarks(aWorkOrder["moduleRemarks"]) after tOutput
         end if
         
         put aWorkorder["moduleName"] into sPrevModule
      end if
      
      put outputSpot(pManifestStyle, pPageWidth, aWorkorder) after tOutput
      
      -- output car remarks on next line
      if aWorkorder["carTypeRemarks"] <> empty then
         put "<p>" & aWorkorder["carTypeRemarks"] & "</p>" & return after tOutput
      end if
  end repeat

return tOutput
end addManifest

on openCard   
   put trainsAsArray() into sTrainA
   
   ##put mdbTableToArray("train") into sTrainA
   
   set the dgData of group "dgTrains" to sTrainA
   
   put "" into cd fld "trainlist"
   
   pass openCard
end openCard

on closeCard
   put "" into cd fld "trainlist"
end closeCard


/*
Output the car type description/class/short/code and Consignee. Information is on
one line of the train's Manifest
*/
function outputSpot pManifestStyle pPageWidth pDataA
   local tTemp, tCharCount
   local tResult, tConsignee, tCarDesc
   local tCarCode
   
   // Determine the format of the Car Short Description or Code. This is based
   // on the checkbox to use Car Type Code in UI
   if (the hilite of button "useCode") and (pDataA["code"] is not "") then
      put pDataA["code"] into tCarCode
   else
      if pPageWidth = "Half" then
         put pDataA["class"] & "-" & pDataA["short"] into tCarCode
      else
         put pDataA["description"] into tCarCode
      end if
   end if
   
   put tCarCode && pDataA["Length"] & "'" into tCarDesc
   
   /*
   if pPageWidth = "Half" then
      put tCarCode & " " & pDataA["Length"] &  "'" into tCarDesc
   else
      if the cPageStyle of this card = "MRBT" then
         put tCarCode & " " & pDataA["Length"] &  "'" into tCarDesc
      else
         put pDataA["description"] & " " & pDataA["length"] & "'" into tCarDesc
      end if
   end if
   */
   
   put "" into tResult
   
   if pDataA["consigneeName"] <> sPrevConsignee then
      if pDataA["consigneeRemarks"] is not empty then
         put formatRemarks( pDataA["consigneeRemarks"] ) after tResult
      end if
   end if
   
   put pDataA["consigneeName"] into sPrevConsignee
   
   switch pManifestStyle
      case "Modern"
         -- start with a place for a check mark and the reporting marks of rollingstock
         put "<p>[ ] Set Out ________________ " after tResult
         
         -- now put in either the car code or description based on radio button in UI
         ##if the hilite of button "1/2 Page Width" then
         ##put tCarTypes[tCarID]["Short"] & " (" & tCarTypes[tCarID]["Length"] &  ")" after manifest
         ##else
         --put tTemp after tResult
         ##end if
         put tCarDesc after tResult
         
         if pPageWidth="Half" then
            put "</p><p>      " after tResult
         end if
         
         put " to " & pDataA["spot"] after tResult
         /*
         put " to " & pDataA["consigneeName"] after tResult
         
         // RDH THIS IS LIKELY NEEDING SOME FIXING
         if pDataA["consigneeName"] <> pDataA["spot"] then
            put " " & pDataA["spot"] after tResult
         end if
         */
         break
      case "MRBT"
         /*
         put "  " & pDataA["consigneeName"] into tTemp
         if pDataA["consigneeName"] <> pDataA["spot"] then
            put " " & pDataA["spot"] after tTemp
         end if
         */
         
         put " " & pDataA["spot"] after tTemp
         
         put number of characters of tTemp into tCharCount
         
         if pPageWidth = "Half" then
            if tTemp > 23 then
               put character 1 to 12 of tTemp & "-" & character (tCharCount-10) to tCharCount of tTemp into tTemp
            else
               put "                                " after tTemp
               put character 1 to 24 of tTemp into tTemp
            end if
         else
            if tCharCount > 31 then
               put character 1 to 16 of tTemp & "-" & character (tCharCount-14) to tCharCount of tTemp into tTemp
               put "  " after tTemp
            else
               put "                                " after tTemp
               put character 1 to 34 of tTemp into tTemp
            end if
         end if
         
         put "  " after tTemp
         
         put tCarDesc after tTemp
         put "                                                  " after tTemp
         put character 1 to 56 of tTemp into tTemp
         
         put " ___________________ " after tTemp
         
         if pPageWidth="Half" then
            put character 1 to 46 of tTemp & "<br />" & return after tResult
         else
            put tTemp & "<br />" & return after tResult
         end if
   end switch
   
   return tResult
end outputSpot

function outputHeader pTrainA
   local tTrains, tActiveTrain, tHeader
   
   put "" into tHeader
   
   ## Output Page Header
   
   -- Event Title
   put "<b>" & cd fld "setup_name" of cd "Preferences" of stack "Module Operations" & "</b>" & return after tHeader
   
   -- Manifest Train details
   put "<p>TRAINLIST for TRAIN: " & pTrainA["symbol"] & "</p>" & return after tHeader
   
   ## Output train name if there is one listed
   if pTrainA["name"] is not empty then
      put "<p>Train -  " & pTrainA["name"] & "</p>" & return after tHeader
   end if
   
   return tHeader
end outputHeader

/*
returns the termination instructions as html
*/
function outputTerminationInstructions pTrainA
    local tOutput
    
    if pTrainA["terminationInstructions"] is not empty then
        put "<br />" into tOutput
        repeat for each line aLine in pTrainA["terminationInstructions"]
            put aline & "<br />" after tOutput
        end repeat
        // delete the last <br /> tag in output
        delete char -6 to -1 of tOutput
    end if
    
    return tOutput
end outputTerminationInstructions

/*
returns crew instructions as html
*/
function outputCrewInstructions pTrainA
    local tTrains, tActiveTrain, tInstructions
    
    if pTrainA["instructions"] <> empty then
        
        put "<p><b>CREW INSTRUCTIONS</b></p>" & return after tInstructions
        
        // output crew instructions from the train data
        repeat for each line aLine in pTrainA["instructions"]
            put aLine & "<br />" after tInstructions
        end repeat
        
        delete char -6 to -1 of tInstructions
        
        ###put pTrainA["instructions"] into field "convert"
        ###put the htmltext of fld "convert" after tInstructions
        
    end if  
    
    return tInstructions
end outputCrewInstructions

function outputModuleName pStyle, pModule, pStopNum
   local tResult
   
   switch pStyle
      case "Modern"
         put "<p><b>Scheduled work at " & pModule after tResult
         break
      case "MRBT"
         put "<p><b>" & pModule after tResult
   end switch
   
   if the cSchedulingEngine of stack "Module Operations" is not "MRBT" then
      if sTrainRouteA[pStopNum]["dir"] <> "" then
         put " (" after tResult
         switch sTrainRouteA[pStopNum]["dir"]
            case "O"
               put "Outbound" after tResult
               break
            case "R"
               put "Return" after tResult
               break
            case "N"
               put "North" after tResult
               break
            case "S"
               put "South" after tResult
               break
            case "E"
               put "East" after tResult
               break
            case "W"
               put "West" after tResult
               break
         end switch
         put ")" after tResult
      end if
   end if
   
   put "</b></p>" & return after tResult
   return tResult     
end outputModuleName

function outputConsignee theStyle, theConsignee, theSpot
  -----
  local manifest,tConsignee,tConsignees
  local trainManifest,tSpotID,tConsigneeID
  -----

   
   /*
     -- add the consignee to the output     
      put item 5 of line i of trainManifest into tSpotID
      put tSpots[tSpotID]["ConsigneeID"] into tConsigneeID
      if the hilite of button "1/2 Page Width" then
         put "</p><p>      " after manifest
      end if
      put "  " & tConsignees[tConsigneeID]["Name"] & "                       " into tConsignee
      if tConsignees[tConsigneeID]["Name"] <> tSpots[tSpotID]["Spot"] then
         put " " & tSpots[tSpotID]["Spot"] after tConsignee
      end if
      
      put character 1 to 22 of tConsignee into tConsignee
      put tConsignee after manifest
      
      put "  " after manifest
      */
end outputConsignee

function outputTrainOrigin  pTrainA, pPageWidth
   local tTrainOut
   put "<p><b>Train departs " & yardDetail(pTrainA["origin"]) after tTrainOut
   
   if pPageWidth="Half" then
      put "</b></p><p><b>" after tTrainOut
   end if
   
   if the cCarCount of this card is empty then
       set the cCarCount of this card to 0
   end if

   put " with " & the cCarCount of this card after tTrainOut
   put " cars (" & the cTrainLength of this card & " feet)</b></p>" after tTrainOut
   
   return tTrainOut
end outputTrainOrigin

function outputFooter pTrainA, pPageWidth
   local tTrains, tActiveTrain, tFooter
   
   -- Footer of manifest starts here
   if pPageWidth = "Half" then
      ##put "<p> </p>" & return after tFooter
   end if
   put "<p><b>Train Terminates " & yardDetail(pTrainA["destination"]) & "</b></p>" after tFooter
   if pPageWidth = "Half" then
      ##put "<p> </p>" & return after tFooter
   end if
   put "<p>Train Complete at: ______________________</p>" & return after tFooter
   put "<p>Comments: </p>" & return after tFooter
   
   return tFooter
end outputFooter

function outputTwoColumns pManifest
  -----
  local tStartLine
  -----

   local tTemp, tReturn
   
   put wordWrappedHTML(pManifest, 54) into pManifest
   
   put "" into tTemp
   repeat with i = 1 to 39
      if (i = 39) and char 4 of line i of pManifest = "[" then
         put 39 into tStartLine
         exit repeat
      else        
         put line i of pManifest & return after tTemp
         put 40 into tStartLine
      end if
   end repeat
   
   if the number of lines of pManifest > 40 then
      put return & "<p></p>                            -- OVER --" after tTemp
   end if
   
   set the htmlText of cd fld "Column 1" of cd 1 of stack "2 Columns" to tTemp
   
   put tTemp & return into tReturn
   put "" into tTemp
   repeat with i = tStartLine to number of lines of pManifest
      put line i of pManifest & return after tTemp
   end repeat
      
   set the htmlText of cd fld "Column 2" of cd 1 of stack "2 Columns" to tTemp
   
   put tTemp after tReturn
   
   return pManifest   
end outputTwoColumns

on uiAdjustSpacing pSpacing
   set the textheight of cd fld "trainlist" to pSpacing
end uiAdjustSpacing


on scheduleMRBT
  -----
  local tArrayKey,tSpotID,tCarID
  local tManifest,tTrainRoute,tConsignees
  local tModuleID,tTrainOrders,tRandomWO
  local tModules,tCarTypes,tWOIndex
  local tTrainLength,tCarCount,randomNumber
  local tWillItFit
  local tWorkFactor,woCount
  -----

   set cursor to watch
   
   local tStopNum, tModule, tDirection, tRoute, tRouteIndustries
   local tTrains, freqTotal, tConsignee, tWorkorders, tSpots, tActiveTrain
   
   put "" into tManifest
   put the cTrains of stack "Module Operations" into tTrains
   put the cActiveTrain of stack "Module Operations" into tActiveTrain
   put tTrains[tActiveTrain]["Route"] into tTrainRoute
   
   if tTrainRoute = "" then
      answer warning "This train does not have a Route defined." with "OK"
      set the cManifest of stack "Module Operations" to tManifest
      break
   end if
   
   put the cConsignees of stack "Module Operations" into tConsignees
   put the cWorkorders of stack "Module Operations" into tWorkorders
   put the cModules of stack "Module Operations" into tModules
   put the cCarTypes of stack "Module Operations" into tCarTypes
   put the cSpots of stack "Module Operations" into tSpots
   
   put "" into tRouteIndustries
   put 0 into freqTotal
   put 1 into tWOIndex
   put 0 into cd fld "Train Length" of cd 1 of stack "MRBT"
   put 0 into cd fld "Car Count" of cd 1 of stack "MRBT"
   
   set the itemDelimiter to tab
   
   -- with each stop on the train route, list the consignees that are potentially serviced
   repeat with tStopNum = 1 to number of lines of tTrainRoute
      
      -- get the Module name for this stop
      put item 3 of line tStopNum of tTrainRoute into tModule
      
      -- get the Module ID
      put item 2 of line tStopNum of tTrainRoute into tModuleID
      
      -- check if this is a Special Train Order
      if tModuleID > 99999 then
         
         put tStopNum*1000 into tManifest[tModuleID]["index"]
         put tModuleID into tManifest[tModuleID]["ModuleID"]
         put tModule into tManifest[tModuleID]["Module"]
         
      else
         
         -- get the direction of the current module
         ##put item 2 of line tStopNum of tRoute into tDirection
         
         -- for the current module, get each consignee
         repeat for each element aWorkorder in tWorkorders
            if aWorkorder["ModuleID"] = tModuleID then
               put tWOIndex into tTrainOrders[tWOIndex]["ID"]
               put tStopNum into tTrainOrders[tWOIndex]["Stop"]
               put tModuleID into tTrainOrders[tWOIndex]["ModuleID"]
               put aWorkorder["ID"] into tTrainOrders[tWOIndex]["WOID"]
               put aWorkorder["ConsigneeID"] into tTrainOrders[tWOIndex]["ConsigneeID"]
               put tModules[tModuleID]["Name"] into tTrainOrders[tWOIndex]["Module"]
               put aWorkorder["SpotID"] into tTrainOrders[tWOIndex]["SpotID"]
               put aWorkorder["CarID"] into tTrainOrders[tWOIndex]["CarID"]
               put aWorkorder["CPW"] into tTrainOrders[tWOIndex]["CPW"]
               put freqTotal + aWorkorder["CPW"] into freqTotal
               put freqTotal into tTrainOrders[tWOIndex]["Total"]
               
               add 1 to tWOIndex
            end if
         end repeat
         
      end if
   end repeat
   
   -- with the industries listed, generate a random list of consingees to perform work at.
   ##put tRouteIndustries into field "routeIndustries"   
   set the dgData of group "dgTrainOrders" of cd 1 of stack "MRBT" to tTrainOrders
   put freqTotal into field "freqTotal" of cd 1 of stack "MRBT"
   
   
   -- Need to zero out each spots used length
   ##repeat for each element aSpot in tSpots
   ##put 0 into tSpots[aSpot["ID"]]["Used"]
   ##end repeat
   
   
   
   -- for lack of a better method right now, I've arbitraily picked a maximum of 100 workorders
   -- to attempt to schedule. Once I've got this software working better I'll come back and figure
   -- a better way to determine how many workorders to schedule.
   put "" into tRandomWO
   
   put (the cEconomy of stack "Module Operations")/1.5 into tWorkFactor
   
   -- not sure why this happens just yet but just encase cEcomomy is 0
   if tWorkFactor = 0 then put 2 into tWorkFactor
   
   put the number of elements of tTrainOrders into woCount
   put tTrains[tActiveTrain]["Length"] into tTrainLength
   put 1 into tCarCount
   
   repeat with i = 1 to (woCount*tWorkFactor)
      put random(freqTotal) into randomNumber
      ##put randomNumber & tab after tRandomIndustries
      
      put logarithmicSearch (tTrainOrders, randomNumber, 1, woCount) into tArrayKey
      if tArrayKey = 0 then 
         break
      end if
      
      put tTrainOrders[tArrayKey]["SpotID"] into tSpotID
      put tTrainOrders[tArrayKey]["CarID"] into tCarID
      
      if (tTrainLength-tCarTypes[tCarID]["Length"]) > 0 then
         put tSpots[tSpotID]["Length"] - tSpots[tSpotID]["Used"] - tCarTypes[tCarID]["Length"] into tWillItFit
         if  tWillItFit >= 0 then 
            put tTrainOrders[tArrayKey]["Stop"]*1000+tSpots[tSpotID]["Track"] into tManifest[tCarCount]["index"]
            put tTrainOrders[tArrayKey]["ConsigneeID"] into tManifest[tCarCount]["ConsigneeID"]
            put tTrainOrders[tArrayKey]["WOID"] into tManifest[tCarCount]["WOID"]
            put tTrainOrders[tArrayKey]["ModuleID"] into tManifest[tCarCount]["ModuleID"]
            put tTrainOrders[tArrayKey]["SpotID"] into tManifest[tCarCount]["SpotID"]
            put tSpots[tSpotID]["Spot"] into tManifest[tCarCount]["Spot"]
            put tSpots[tSpotID]["Track"] into tManifest[tCarCount]["Track"]
            put tTrainOrders[tArrayKey]["CarID"] into tCarID
            put tCarID into tManifest[tCarCount]["CarID"]
            put tTrainOrders[tArrayKey]["Module"] into tManifest[tCarCount]["Module"]
            put tCarTypes[tCarID]["Description"] into tManifest[tCarCount]["Description"]
            put tCarTypes[tCarID]["Length"] into tManifest[tCarCount]["Length"]
            subtract tCarTypes[tCarID]["Length"] from tTrainLength
            add tCarTypes[tCarID]["Length"] to tSpots[tSpotID]["Used"]
            add tCarTypes[tCarID]["Length"] to cd fld "Train Length" of cd 1 of stack "MRBT"
            add 1 to tCarCount
         end if
      else
         exit repeat
      end if
      
      put tCarCount-1 into cd fld "Car Count" of cd 1 of stack "MRBT"
      set the dgData of group "dgManifest" of cd 1 of stack "MRBT" to tManifest
      set the cManifest of stack "Module Operations" to tManifest
   end repeat
end scheduleMRBT

function spurExists moduleName, industryName, spurID, spurName
  -----
  local existingSpurs
  -----

   put field "SpurData" into existingSpurs
   set the itemDelimiter to tab
   
   repeat with spurIndex = 1 to number of lines of existingSpurs
      
      if (item 1 of line spurIndex of existingSpurs = moduleName) and (item 2 of line spurIndex of existingSpurs = industryName) and (item 3 of line spurIndex of existingSpurs = spurID) and (item 4 of line spurIndex of existingSpurs = spurName) then
         return true
         exit spurExists
      end if
   end repeat
   
   -- if we make it here then the spur does not already exists in the existing spur list
   return false
end spurExists

function logarithmicSearch @pArray pItem pLeft pRight
   local tIndex
   local tResult
   # create a new range pointer that points to the item that lies
   # right between the left and right range pointers
   put round ((pLeft + pRight) / 2) into tIndex
   
   #if we are at the first index then we are done
   if tIndex = 1 then
      put tIndex into tResult
   # if we have found the matching item then stop processing and return it
   else if pArray[tIndex-1]["Total"] < pItem and pArray[tIndex]["Total"] >= pItem then
      put tIndex into tResult
      
      # if any of the range pointers have the same value
      # then the item we are looking for does not exist in the array and we return 0
   else if (pLeft = pRight or pLeft = tIndex or pRight = tIndex) then
      put 1 into tResult
      
      # if we have not yet found a match and none of the range pointers have the same
      # value then call logarithmicSearch again with a smaller search range
      # we are effectively halving the search area, each time we call logarithmicSearch
   else if pArray[tIndex]["Total"] > pItem then
      put logarithmicSearch (pArray, pItem, pLeft, tIndex) into tResult
   else
      put logarithmicSearch (pArray, pItem, tIndex, pRight) into tResult
   end if
   return tResult
end logarithmicSearch

function formatRemarks pRemarks
   local tResult
   
   repeat with i = 1 to number of lines of pRemarks
      put "<p>" & line i of pRemarks & "</p>" & return after tResult
   end repeat   
   return tResult
end formatRemarks
