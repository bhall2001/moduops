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
# Smarty uses the CPW of car requests for a weighted random selection.
# It is also possible to favor re-selection based on ui imput.
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
  
  local tTrainsA, tTrainLength, tCarCount, tRandomNum, tSelectedID, tDataA, tConsigneeA
  local tSelectedWO, tSelectedCar, tManifestIndex, tStopNum, tSpotA, tTrainId
  local tCarTypeA, tCarType, t2DataA, tUseConsignee, tConsigneeCnt, tModuleList
  local tTrainFull -- count cars selected but train can't fit
  
  unlock screen
  put "Starting Smarter Scheduler..." into field "status" of card "trainlists" of stack "Module Operations"
  lock screen
  
  put 1 into tManifestIndex
  put the cTrainUUID of card "Trainlists" of stack "Module Operations" into tTrainId
  put train.findOne(tTrainId) into tTrainsA
  
  // in the case where there is a minimum train length
  // set the length of the train to a random value
  // between min and max
  if tTrainsA["minLength"] is a number then
    put random(tTrainsA["length"] - tTrainsA["minLength"] + 1) + tTrainsA["minLength"] into tTrainsA["length"]
  end if
  
  put tTrainsA["route"] into sTrainRoute
  put jsonToArray(sTrainRoute) into sTrainRouteA
  
  put 0 into tTrainLength
  put 0 into sCumTotal
  put 0 into tConsigneeCnt
  
  put "" into sManifestA
  put "" into sWorkordersA
  put "" into tModuleList
  put "" into tUseConsignee
  
  __smtClearSpotUsed
  
  ##
  #------------------------------------------------------
  # Generate the weighted Workorder data
  #------------------------------------------------------
  ##
  __smtCreateWorklist
  
  ## Start a DB Transaction
  --  get mdbExecuteSQL("BEGIN TRANSACTION")
  
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
      
      put __smtBinarySearchWO(sWorkordersA, tRandomNum, 1, (number of elements of sWorkordersA)) into tSelectedID
      
      put sWorkordersA[tSelectedID] into tSelectedWO
      
      if sTrainRouteA[tSelectedWO["stop"]]["consigneeId"] is in "A, B, AB" then
        if sTrainRouteA[tSelectedWO["stop"]]["consigneeId"] <> tSelectedWO["direction"] then
          if tSelectedWO["direction"] <> "AB" then
            next repeat
          end if
        end if
        
        if tTrainsA["limitModules"] <> "" then
          if the number of lines of tModuleList = tTrainsA["limitModules"] then
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
        
        ## once a workorder is selected, check favor re-using the consignee
        if reuseConsignee(tSelectedWO["cpw"]) then 
          
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
        
        --        put mdbQueryByUUID("carType", tSelectedWO["carID"]) into tCarTypeA
        put carType.findOne(tSelectedWO["carID"]) into tCarTypeA
        
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
      if reuseConsignee(tSelectedWO["cpw"]) then
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
      
      --      put mdbQueryByUUID("carType", tSelectedWO["carID"]) into tCarTypeA
      put carType.findOne(tSelectedWO["carID"]) into tCarTypeA
      
      -- if there are no cars matching request move to next WO
      if tCarTypeA is not an array then
        next repeat
      end if
      
      put tCarTypeA into tCarType
      
      --      put mdbQueryByUUID("spot", tSelectedWO["spotID"]) into tSpotA
      put spot.findOne(tSelectedWO["spotID"]) into tSpotA
      
      ## If the spot is full, go to the next Workorder
      if tSpotA["used"] + tCarType["length"] > tSpotA["length"] then
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
      if (tTrainLength + tCarType["length"]) <= tTrainsA["length"] then
        put tTrainId into sManifestA[tManifestIndex]["trainId"]
        put tSelectedWO["id"] into sManifestA[tManifestIndex]["workorderId"]
        put tSelectedWO["stop"] into sManifestA[tManifestIndex]["stop"]
        add 1 to tManifestIndex
        add 1 to tCarCount
        add tCarType["length"] to tTrainLength
        put tSpotA["used"] + tCarType["length"] into tSpotA["used"]
        --        get mdbUpdateRecord(tSelectedWO["spotID"], "spot", tSpot)
        get spot.update(tSpotA)
        
        ##
        #------------------------------------------------------
        # Add to Manifest
        #------------------------------------------------------
        ##
        
      else
        add 1 to tTrainFull
        // after attempting to add 10 cars to train but failing
        // consider ourselves done
        if tTrainFull > 10 then 
          exit repeat
        end if
        next repeat
      end if
    end repeat
  end if
  
  ## End a DB Transaction
  --  get mdbExecuteSQL("COMMIT")
  
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
  
  --  get mdbDeleteManifestByTrainID(tTrainUUID)
  get manifest.deleteByTrainId(tTrainId)
  
  if sManifestA is an array then
    --    get mdbArrayToTable("manifest", sManifestA)
    repeat for each element anOrder in sManifestA
      get manifest.create(anOrder)
    end repeat
  end if
  
  --return sManifestA
  --   set the cManifestA of card "Trainlists" of stack "Module Operations" to sManifestA
  put "" into field "status" of card "trainlists" of stack "Module Operations"
  
end generateManifest

/*
reset spots to 0 indicating that all are free of equipment
*/
private command __smtClearSpotUsed
  local tSpotsA
  
  put spot.findMany() into tSpotsA
  
  repeat for each element aSpot in tSpotsA
    put 0 into aSpot["used"]
    get spot.update(aSpot)
  end repeat
end __smtClearSpotUsed


private command __smtCreateWorkList
  
  __smtCreateWorkOrderArray
  
  --get mdbDeleteTable("workList")
  --get mdbArrayToTable("workList", sWorkordersA)
end __smtCreateWorkList


private command __smtCreateWorkOrderArray
  local i
  local tStopNum = 1
  
  put "" into sExcludeConsignee
  
  ## Create the list of Consignees not to service
  repeat for each element aStop in sTrainRouteA
    if char 1 of aStop["consigneeId"] is "!" then
      put char 2 to -1 of aStop["consigneeId"] & return after sExcludeConsignee
    end if
  end repeat
  
  repeat for each element aStop in sTrainRouteA
    if char 1 of sTrainRouteA[tStopNum]["consigneeId"] is not "!" then
      ## Consignee should be scheduled on the train
      __smtAppendWorkorders tStopNum, sTrainRouteA[tStopNum]["moduleId"], sTrainRouteA[tStopNum]["consigneeId"], sTrainRouteA[tStopNum]["dir"]
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
end __smtCreateWorkOrderArray


private command __smtAppendWorkorders pStopNum, pModuleId, pConsigneeId, pTrainDir
  local tDataA
  local tWOIndex
  local tCriteriaA
  
  put the number of elements of sWorkordersA into tWOIndex
  
  if (pConsigneeID is not in "A,B,AB,ALL") and pConsigneeID is not empty then
    --    put mdbStopConsigneeWO(pConsigneeID) into tDataA
    put workorder.findByConsigneeId(pConsigneeId) into tDataA
  else
    --    put mdbStopModuleWO(pModuleUUID) into tDataA
    put workorder.findByModuleId(pModuleId) into tDataA
  end if
  
  repeat for each element aWO in tDataA
    ## Skip this workorder if the Consignee is on the Exclude list
    if aWO["consigneeId"] is in sExcludeConsignee then
      next repeat
    else
      add 1 to tWOIndex
      put aWO into sWorkordersA[tWOIndex]
      put pTrainDir into sWorkordersA[tWOIndex]["trainDir"]
      put pStopNum into sWorkordersA[tWOIndex]["stop"]
      put aWO["cpw"] + sCumTotal into sCumTotal
      put sCumTotal into sWorkordersA[tWOIndex]["cumTotal"]
    end if
  end repeat
end __smtAppendWorkorders


private function __smtBinarySearchWO @pArray pItem pLeft pRight
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
    put __smtBinarySearchWO(pArray, pItem, pLeft, tIndex) into tResult
  else
    put __smtBinarySearchWO(pArray, pItem, tIndex, pRight) into tResult
  end if
  return tResult
end __smtBinarySearchWO

