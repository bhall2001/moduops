script "mrbt"

## ------------------------------------------------------------------------

##
# MRBT engine
#
# A Scheduling Engine for ModuOps
# Based on the algorithm for the 90's software "Mad River and Big Timber"
#
# @package   MRBT
# @author       bhall_2001@yahoo.com
# @copyright  Copyright (c) 2009 - 2015, Robert D. Hall
# @link		      http://www.moduops.com
#
#
# This is the simpliest of the scheduling engines for ModuOps and is included
# free in the Application. In a nut shell, this scheduler randomly selects a module
# listed on a train's path, then random selects a Consignee, then randomly selects 
# a Car from the workorders of the Consignee.
#
# There is no weighting of any data and at each stage all items have an equal chance
# of selection.
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
# @category	    Scheduler
# @author            bhall_2001@yahoo.com
# @link	                 http://www.moduops.com
##

## ------------------------------------------------------------------------

##
#------------------------------------------------------
# Script Local Variables
#------------------------------------------------------
##
local sTrainRoute -- Active Train's Route
local sManifestA -- Train's Manifest

command generateManifest
  
  ##
  #------------------------------------------------------
  # Get the Train's Route
  #------------------------------------------------------
  ##
  
  local tTrains, tTrainLength, tCarCount, tRandomNum, tSelectedID, tDataA, tConsigneeA
  local tSelectedWO, tSelectedCar, tManifestIndex, tStopNum, tSpotA, tSpot, tTrainId
  local tCarTypeA, t2DataA, tModuleList
  local tUseConsignee, tConsigneeCnt
  
  unlock screen
  put "Starting MRBT Scheduler..." into field "status" of card "trainlists" of stack "Module Operations"
  lock screen
  
  // initialize local variables
  put 1 into tManifestIndex
  put the cTrainUUID of card "Trainlists" of stack "Module Operations" into tTrainId
  put train.findOne(tTrainId) into tTrains
  put tTrains["route"] into sTrainRoute
  put jsonToArray(sTrainRoute) into sTrainRoute
  put 0 into tTrainLength
  put empty into sManifestA
  clearSpotUsed
  put "" into tModuleList
  put "" into tUseConsignee
  put 0 into tConsigneeCnt
  
  repeat 1000 times
    ##
    #------------------------------------------------------
    # Select a Module
    #------------------------------------------------------
    ##
    
    if sTrainRoute is empty then 
      -- If the train does not have a route then don't schedule anything
      put "" into field "trainlist" of card "Trainlists" of stack "Module Operations"
      put "" into field "status" of card "Trainlists" of stack "Module Operations"
      answer error "This train does not have a route defined."
      exit to top 
    end if
    
    --put random(the number of lines of sTrainRoute) into tStopNum
    put random(the number of elements of sTrainRoute) into tStopNum
    --set the itemDelimiter to tab
    --put item 4 of line tStopNum of sTrainRoute into tSelectedID
    put sTrainRoute[tStopNum]["moduleID"] into tSelectedID
    
    ## Check for an empty moduleID
    ## empty moduleID implies this line on the train's route is a Train Order
    if tSelectedID is not empty then
      if the number of lines of tModuleList = 4 then
      else
        if lineOffset(tSelectedID, tModuleList) = 0 then
          put tSelectedID & return after tModuleList
        end if
      end if
      
      if lineOffset(tSelectedID, tModuleList) = 0 then
        next repeat
      end if
      
      ##
      #------------------------------------------------------
      # Select a Consignee
      #------------------------------------------------------
      ##
      
      put consignee.findByModuleId(tSelectedID) into tDataA
      if tDataA is not an array then
        --answer "Error..."
        next repeat
      end if
      put random(the number of elements of tDataA) into tRandomNum
      put tDataA[tRandomNum]["id"] into tSelectedID
      
      ##
      #------------------------------------------------------
      # Select a Workorder
      #------------------------------------------------------
      ##
      
      put workorder.findByConsigneeId(tSelectedID) into t2DataA
      
      -- If no workorders exist for consignee move on to the next WO
      if t2DataA is not an array then
        next repeat
      end if
      
      put random(the number of elements of t2DataA) into tRandomNum
      put t2DataA[tRandomNum] into tSelectedWO
      
      // check if we are re-using prior selected track or consignee
      if tUseConsignee <> "" then
        ###if (tSelectedWO["spotID"] = tUseConsignee) then
        if (tSelectedWO["track"] <> tUseConsignee) then
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
      --      if reuseConsignee(tSelectedWO["cpw"]) then 
      
      --        ### if random(tSelectedWO["CPW"]) >= random(4) then
      --        ###put tSelectedWO["spotID"] into tUseConsignee
      --        put tSelectedWO["track"] into tUseConsignee
      --      else
      --        put "" into tUseConsignee
      --        put 0 into tConsigneeCnt
      --      end if
      
      ##
      #------------------------------------------------------
      # Check If Spot Has Room for Car Selected
      #------------------------------------------------------
      ##
      
      put carType.findOne(tSelectedWO["carId"]) into tCarTypeA
      
      -- if there are no cars matching request move to next WO
      if tCarTypeA is not an array then
        next repeat
      end if
      
      put spot.findOne(tSelectedWO["spotId"]) into tSpotA
      
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
      --      if reuseConsignee(tSelectedWO["cpw"]) then
      --        put tSelectedWO["track"] into tUseConsignee
      --      else
      --        put "" into tUseConsignee
      --        put 0 into tConsigneeCnt
      --      end if
      
      ## If spot has no room for selected car try again...
      if tSpotA["used"] + tCarTypeA["length"] > tSpotA["length"] then
        put "" into tUseConsignee
        put 0 into tConsigneeCnt
        next repeat
      end if
      
      ##
      #------------------------------------------------------
      # Add to Manifest
      #------------------------------------------------------
      ##
      
      put carType.findOne(tSelectedWO["carId"]) into tSelectedCar
      if tTrainLength + tSelectedCar["length"] <= tTrains["length"] then
        put tTrainId into sManifestA[tManifestIndex]["trainId"]
        put tSelectedWO["id"] into sManifestA[tManifestIndex]["workorderId"]
        put tStopNum into sManifestA[tManifestIndex]["stop"]
        add 1 to tManifestIndex
        add 1 to tCarCount
        add tSelectedCar["length"] to tTrainLength
        put tSpotA["used"] + tCarTypeA["length"] into tSpotA["used"]
        get spot.update(tSpotA)
        unlock screen
        put "Scheduled " & tCarCount & " cars." into field "status" of card "trainlists" of stack "Module Operations"
        lock screen
      else
        exit repeat
      end if
    end if
  end repeat
  
  ## Add Train Orders to Manifest
  repeat with i = 1 to the number of elements of sTrainRoute
    if sTrainRoute[i]["Name"] = "Train Order" then
      put i into sManifestA[tManifestIndex]["stop"]
      put tTrainId into sManifestA[tManifestIndex]["trainId"]
      put sTrainRoute[i]["consignee"] into sManifestA[tManifestIndex]["trainOrder"]
      add 1 to tManifestIndex
    end if
  end repeat
  
  unlock screen
  put "Generating Manifest..." into field "status" of card "trainlists" of stack "Module Operations"
  lock screen
  
  ##
  #------------------------------------------------------
  # Return the final Manifest
  #------------------------------------------------------
  ##
  
  set the cCarCount of card "Trainlists" of stack "Module Operations" to tCarCount
  set the cTrainLength of card "Trainlists" of stack "Module Operations" to tTrainLength
  
  // TODO: refactor this
  --  get mdbDeleteManifestByTrainID(tTrainId)
  get manifest.deleteByTrainId(tTrainId)
  
  repeat for each element anOrder in sManifestA
    get manifest.create(anOrder)
  end repeat
  
  --return sManifestA
  --   set the cManifestA of stack "Module Operations" to sManifestA
  put "" into field "status" of card "trainlists" of stack "Module Operations"
  
end generateManifest


on clearSpotUsed
  local tSpotsA
  
  put spot.findMany() into tSpotsA
  
  repeat for each element aSpot in tSpotsA
    put 0 into aSpot["used"]
    get spot.update(aSpot)
  end repeat
end clearSpotUsed






