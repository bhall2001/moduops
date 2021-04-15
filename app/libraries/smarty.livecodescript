script "sMarty"
## ------------------------------------------------------------------------

##
# MRBT engine
#
# A Scheduling Engine for ModuOps
# sMarty adds some modern twists to the original MRBT scheduling engine.
#  - Car Requests are selected using a weighted random factor.
#  - Factors such as Railroad Favorability and Economy effect scheduling.
#  - Limit trains to maximum number of stops that it can make
#  
#
# @package   MRBT
# @author       bhall_2001@yahoo.com
# @copyright  Copyright (c) 2009 - 2015, Robert D. Hall
# @link         http://www.moduops.com
#
#
# This is the simpliest of the scheduling engines for ModuOps and is included
# free in the Application. In a nut shell, this scheduler randomly selects a module
# listed on a train's path, then random selects a Consignee, then randomly selects 
# a Car from the workorders of the Consignee.
#
#
# A Manifest is generated form the work selected for the train is returned to 
# ModuOps for processing and output.
#
##

## ------------------------------------------------------------------------

##
# Generate Manifest
#
# Function called by ModuOps to generate a Train's Manifest
#
# @package        MRBT
# @category     Scheduler
# @author            bhall_2001@yahoo.com
# @link                  http://www.moduops.com
##

## ------------------------------------------------------------------------

##
#------------------------------------------------------
# Script Local Variables
#------------------------------------------------------
##
local sTrainRoute -- Active Train's Route (List of stops)
local sTrainRouteA -- Active Train's Route (Array of stops)
local sManifestA -- Train's Manifest
local sCumTotal -- Cumulative Total for weighted random selection
local sWorkordersA -- All potential work for a given route
local sExcludeConsignee -- List of Consignees that train does not handle


command generateManifest
   
   ##
   #------------------------------------------------------
   # Get the Train's Route
   #------------------------------------------------------
   ##
   
   local tTrains, tTrainLength, tCarCount, tRandomNum, tSelectedID, tDataA, tConsigneeA
   local tSelectedWO, tSelectedCar, tManifestIndex, tStopNum, tSpotA, tSpot, tTrainUUID
   local tCarTypeA, tCarType, t2DataA, tUseConsignee, tConsigneeCnt, tModuleList
   
   unlock screen
   put "Starting sMarty Scheduler..." into field "status" of card "trainlists" of stack "Module Operations"
   lock screen
   
   put 1 into tManifestIndex
   put the cTrainUUID of card "Trainlists" of stack "Module Operations" into tTrainUUID
   put mdbQueryByUUID("train", tTrainUUID) into tTrains
   put tTrains[1]["route"] into sTrainRoute
   put jsonToArray(sTrainRoute) into sTrainRouteA
   
   put 0 into tTrainLength
   put 0 into sCumTotal
   put 0 into tConsigneeCnt
   
   put "" into sManifestA
   put "" into sWorkordersA
   put "" into tModuleList
   put "" into tUseConsignee
   
   smtClearSpotUsed
   
   ##
   #------------------------------------------------------
   # Generate the weighted Workorder data
   #------------------------------------------------------
   ##
   smtCreateWorklist
   
   ## Start a DB Transaction
   get mdbExecuteSQL("BEGIN TRANSACTION")
   
   -- if there is no train route defined, display an error
   if sWorkordersA is empty then
      put "" into field "trainlist" of card "Trainlists" of stack "Module Operations"
      put "" into field "status" of card "Trainlists" of stack "Module Operations"
      answer error "This train has no route defined!"
      exit to top
   end if
   
   if sWorkordersA is an array then
      repeat 1000 times
         
         ##
         #------------------------------------------------------
         # Select a Workorder
         #------------------------------------------------------
         ##
         
         ## Select a random number from 1 to the Cumulative Total
         put random(sCumTotal) into tRandomNum
         
         put smtBinarySearchWO(sWorkordersA, tRandomNum, 1, (number of elements of sWorkordersA)) into tSelectedID
         
         put sWorkordersA[tSelectedID] into tSelectedWO
         
         if sTrainRouteA[tSelectedWO["stop"]]["consigneeID"] is in "A, B, AB" then
            if sTrainRouteA[tSelectedWO["stop"]]["consigneeID"] <> tSelectedWO["direction"] then
               if tSelectedWO["direction"] <> "AB" then
                  next repeat
               end if
            end if
            
            if tTrains[1]["limitModules"] <> "" then
                if the number of lines of tModuleList = tTrains[1]["limitModules"] then
                else
                    if lineOffset(tSelectedWO["moduleID"], tModuleList) = 0 then
                        put tSelectedWO["moduleID"] & return after tModuleList
                    end if
                end if
                
                if lineOffset(tSelectedWO["moduleID"], tModuleList) = 0 then
                    next repeat
                end if
            end if
            
            if (tUseConsignee <> "") then
                ###if (tSelectedWO["spotID"] = tUseConsignee) then
                if (tSelectedWO["track"] = tUseConsignee) then
                    add 1 to tConsigneeCnt
                    if tConsigneeCnt > 60 then -- catches an infinite loop if no Consignee's match
                        put 0 into tConsigneeCnt
                        put "" into tUseConsignee
                        next repeat
                    end if
                else -- select another workorder for looking for the consignee
                    next repeat
                end if
            end if
            
            ## once a workorder is selected, favor re-using the consignee
            if (random(10) <=  8*(tSelectedWO["CPW"]/7)) then 
            
           ### if random(tSelectedWO["CPW"]) >= random(4) then
                ###put tSelectedWO["spotID"] into tUseConsignee
                put tSelectedWO["track"] into tUseConsignee
            else
                put "" into tUseConsignee
                put 0 into tConsigneeCnt
            end if
            
            ##
            #------------------------------------------------------
            # Check If Spot Has Room for Car Selected
            #------------------------------------------------------
            ##
            
            put mdbQueryByUUID("carType", tSelectedWO["carID"]) into tCarTypeA
            
            -- if there are no cars matching request move to next WO
            if tCarTypeA is not an array then
                next repeat
            end if
         end if
         
         if (tUseConsignee <> "") then
            ###if (tSelectedWO["spotID"] = tUseConsignee) then
            if (tSelectedWO["track"] = tUseConsignee) then
               add 1 to tConsigneeCnt
               if tConsigneeCnt > 60 then -- catches an infinite loop if no Consignee's match
                  put 0 into tConsigneeCnt
                  put "" into tUseConsignee
                  next repeat
               end if
            else -- select another workorder for looking for the consignee
               next repeat
            end if
         end if
         
         ## once a workorder is selected, favor re-using the selected track
         if reuseConsignee(tSelectedWO["CPW"]) then
            put tSelectedWO["track"] into tUseConsignee
         else
            put "" into tUseConsignee
            put 0 into tConsigneeCnt
         end if
         
         ##
         #------------------------------------------------------
         # Check If Spot Has Room for Car Selected
         #------------------------------------------------------
         ##
         
         put mdbQueryByUUID("carType", tSelectedWO["carID"]) into tCarTypeA
         
         -- if there are no cars matching request move to next WO
         if tCarTypeA is not an array then
            next repeat
         end if
         
         put tCarTypeA[1] into tCarType
         
         put mdbQueryByUUID("spot", tSelectedWO["spotID"]) into tSpotA
         put tSpotA[1] into tSpot
         
         ## If the spot is full, go to the next Workorder
         if tSpot["used"] + tCarType["length"] > tSpot["length"] then
            put "" into tUseConsignee
            put 0 into tConsigneeCnt
            next repeat
         end if
         
         ##
         #------------------------------------------------------
         # Add to Manifest
         #------------------------------------------------------
         ##
         
         --put mdbQueryByUUID("carType", tSelectedWO["carID"]) into tSelectedCar
         if (tTrainLength + tCarType["length"]) < tTrains[1]["length"] then
            put tTrainUUID into sManifestA[tManifestIndex]["trainID"]
            put tSelectedWO["UUID"] into sManifestA[tManifestIndex]["workorderID"]
            put tSelectedWO["stop"] into sManifestA[tManifestIndex]["stop"]
            add 1 to tManifestIndex
            add 1 to tCarCount
            add tCarType["length"] to tTrainLength
            put tSpot["used"] + tCarType["length"] into tSpot["used"]
            get mdbUpdateRecord(tSelectedWO["spotID"], "spot", tSpot)
            
            ##
            #------------------------------------------------------
            # Add to Manifest
            #------------------------------------------------------
            ##
            
         else
            exit repeat
         end if
      end repeat
   end if
   
   ## End a DB Transaction
   get mdbExecuteSQL("COMMIT")
   
   ##
   #------------------------------------------------------
   # Return the final Manifest
   #------------------------------------------------------
   ##
   
   unlock screen
   put "Generating Manifest..." into field "status" of card "trainlists" of stack "Module Operations"
   lock screen
   
   set the cCarCount of card "Trainlists" of stack "Module Operations" to tCarCount
   set the cTrainLength of card "Trainlists" of stack "Module Operations" to tTrainLength
   
   get mdbDeleteManifestByTrainID(tTrainUUID)
   
   if sManifestA is an array then
      get mdbArrayToTable("manifest", sManifestA)
   end if
   
   --return sManifestA
   set the cManifestA of card "Trainlists" of stack "Module Operations" to sManifestA
   put "" into field "status" of card "trainlists" of stack "Module Operations"
   
end generateManifest

on smtClearSpotUsed
   local tSpotsA
   
   put mdbTableToArray("spot") into tSpotsA
   
   repeat for each element aSpot in tSpotsA
      put 0 into aSpot["used"]
      get mdbUpdateRecord(aSpot["UUID"], "spot", aSpot)
      
   end repeat
end smtClearSpotUsed

on smtCreateWorkList
   
   smtCreateWorkOrderArray
      
   --get mdbDeleteTable("workList")
   --get mdbArrayToTable("workList", sWorkordersA)
end smtCreateWorkList

on smtCreateWorkOrderArray
   local i
   local tStopNum = 1
   
   put "" into sExcludeConsignee
   
   ## Create the list of Consignees not to service
   repeat for each element aStop in sTrainRouteA
      if char 1 of aStop["consigneeID"] is "!" then
         put char 2 to -1 of aStop["consigneeID"] & return after sExcludeConsignee
      end if
   end repeat
   
   repeat for each element aStop in sTrainRouteA
      if char 1 of sTrainRouteA[tStopNum]["consigneeID"] is not "!" then
         ## Consignee should be scheduled on the train
         smtAppendWorkorders tStopNum, sTrainRouteA[tStopNum]["moduleID"], sTrainRouteA[tStopNum]["consigneeID"], sTrainRouteA[tStopNum]["dir"]
      end if
      add 1 to tStopNum
   end repeat
      
   /*
   local tTempA
   ## Now re-order the array
   put 1 into i
   repeat for each element aWorkorder in sWorkOrdersA
      put aWorkorder into tTempA[i]
      add 1 to i
   end repeat
   put "" into sWorkOrdersA
   put tTempA into sWorkOrdersA
   */
end smtCreateWorkOrderArray

on smtAppendWorkorders pStopNum, pModuleUUID, pConsigneeID, pTrainDir
   local tDataA
   local tWOIndex
   
   put the number of elements of sWorkordersA into tWOIndex
   
   if (pConsigneeID is not in "A,B,AB,ALL") and pConsigneeID is not empty then
      put mdbStopConsigneeWO(pConsigneeID) into tDataA
   else
      put mdbStopModuleWO(pModuleUUID) into tDataA
   end if
   
   repeat for each element aWO in tDataA
      ## Skip this workorder if the Consignee is on the Exclude list
      if aWO["consigneeID"] is in sExcludeConsignee then
         next repeat
      else
         add 1 to tWOIndex
         put aWO into sWorkordersA[tWOIndex]
         put pTrainDir into sWorkordersA[tWOIndex]["trainDir"]
         put pStopNum into sWorkordersA[tWOIndex]["stop"]
         put aWO["CPW"] + sCumTotal into sCumTotal
         put sCumTotal into sWorkordersA[tWOIndex]["cumTotal"]
      end if
   end repeat
end smtAppendWorkorders

function smtBinarySearchWO @pArray pItem pLeft pRight
   local tIndex
   local tResult
   # create a new range pointer that points to the item that lies
   # right between the left and right range pointers
   put round ((pLeft + pRight) / 2) into tIndex
   
   #if we are at the first index then we are done
   if tIndex = 1 then
      put tIndex into tResult
   # if we have found the matching item then stop processing and return it
   else if pArray[tIndex-1]["cumTotal"] < pItem and pArray[tIndex]["cumTotal"] >= pItem then
      put tIndex into tResult
      
      # if any of the range pointers have the same value
      # then the item we are looking for does not exist in the array and we return 0
   else if (pLeft = pRight or pLeft = tIndex or pRight = tIndex) then
      put 1 into tResult
      
      # if we have not yet found a match and none of the range pointers have the same
      # value then call logarithmicSearch again with a smaller search range
      # we are effectively halving the search area, each time we call logarithmicSearch
   else if pArray[tIndex]["cumTotal"] > pItem then
      put smtBinarySearchWO(pArray, pItem, pLeft, tIndex) into tResult
   else
      put smtBinarySearchWO(pArray, pItem, tIndex, pRight) into tResult
   end if
   return tResult
end smtBinarySearchWO

/*
Shoud the Consignee be scheduled again to favor current selected

Parameters:
pCPW integer for Cars per week
Returns:
boolean
*/
private function reuseConsignee pCPW
   ## Removed on 01/27/19 RDH
   ## Evaluating if random based on CPW works better
   ## random(10) <=  8*(tSelectedWO["CPW"]/7)
   return random(pCPW) <= pCPW/2
end reuseConsignee

