script "card-route-behavior"
local sTrainUUID
local sSpotA

on setSpots pDataA
   put pDataA into sSpotA
end setSpots

function getSpots
   return sSpotA
end getSpots

on preOpenCard    
    local tTempA, tTrainA, tModuleA
    local tTransferA
    
    // set up transfer train menu
    set the text of button "transferTrainMenu" to transferMenuText()
    set the menuhistory of button "transferTrainMenu" to 1 -- make the first tab from the left the active one
    set the hilited of button "transfer" to false
    
    put the cTrainUUID of this card into sTrainUUID
    put trainByUUID(sTrainUUID) into tTrainA
    
    put tTrainA["symbol"] into field "symbol"
    put quote & tTrainA["name"] & quote into field "name"
    
    put yardDetail(tTrainA["origin"]) into field "origin"
    put yardDetail(tTrainA["destination"]) into field "destination"
    
    set the dgText of group "dgOrders" to tTrainA["orders"]
    
    put tTrainA["route"] into tTempA
    put jsonToArray(tTempA) into tTempA
    
    set the dgData of group "dgRoute" to tTempA
    
    // List all Modules
    put module.findMany() into tModuleA
    set the dgData of group "dgModules" to tModuleA
    
    if the cSchedulingEngine of stack "Module Operations" = "MRBT" then
        hide group "Select Consignee"
    else
        show group "Select Consignee"
    end if
    
    set the menuhistory of button "tabSelect" to 1 -- make the first tab from the left the active one
end preOpenCard

function transferMenuText
    local tMenuText
    
    put "Select Train..." & return into tMenuText
    put trainSymbolNameAsCSV() after tMenuText
    
    return tMenuText
end transferMenuText

/*
Add's details of a trains route. A line item may be a module stop or a train order
*/
on addStop
    local tDataA, tStopA, theLine, theNewLine
    
    ## Adding a Module or Route Comment?
    If the visible of group "dgModules" then
        put addModuleStop() into tStopA
    else if the visible of group "dgOrders" then
        put addTrainOrder() into tStopA
    end if
    
    -- insert after selected line or at end of route
    put the dgHilitedLines of group "dgRoute" into theLine
    if theLine is not a number then
        put the dgNumberOfLines of group "dgRoute" into theLine
    end if
    
    add 1 to theLine
    
    send "AddData tStopA, theLine" to group "dgRoute"
    
    ## Refresh the data grid
    dispatch "ResetList" to group "dgRoute"
    
    set the dgProps["sort by column"] of group "dgRoute" to "Stop"
    
    put the dgHilitedLine of group "dgRoute" into theNewLine
    set the dgVScrollPercent of group "dgRoute" to (theNewLine)/(the dgNumberOfLines of group "dgRoute")
end addStop

/*
Returns selected train order from UI. Name of the stop is set to [[Train Order]] to signify this is not a workorder
*/
function addTrainOrder
    local theLine, tStopA
    
    ## Adding a Route Comment to Route
    -- get the selected module
    put the dgHilitedLines of group "dgOrders" into theLine
    
    if theLine = "" then
        answer error "No Route Comment Selected" with "OK"
        exit to top
    end if
    
    put the dgDataOfLine[theLine] of group "dgOrders" into tStopA
    
    put "[[Train Order]]" into tStopA["name"]
    
    return tStopA
end addTrainOrder

/*
Returns the selected module details selected in the UI
*/
function addModuleStop
    local theLine, tStopA, tDataA
    
    -- get the selected module
    put the dgHilitedLines of group "dgModules" into theLine
    
    if theLine = "" then
        answer error "No Module Selected" with "OK"
        exit to top
    end if
    
    put the dgDataOfLine[theLine] of group "dgModules" into tStopA
    put tStopA["UUID"] into tStopA["moduleID"]
    delete variable tStopA["UUID"]
    
    if char 1 of the label of button "directionIndicator" is "D" then
        put "" into tStopA["dir"]
    else
        put char 1 of the label of button "directionIndicator" into tStopA["dir"]
    end if
    
    switch (the label of button "selectConsignees")
        case "All"
            put "All Consignees" into tStopA["consignee"]
            put "ALL" into tStopA["consigneeID"]
            break
        case "A Only"
            if the dgHilitedLines of group "dgConsignees" is empty then
                put "A Only" into tStopA["consignee"]
                put "A" into tStopA["consigneeID"]
            else
                put the dgHilitedLines of group "dgConsignees" into theLine
                put the dgDataOfLine[theLine] of group "dgConsignees" into tDataA
                put tDataA["name"] into tStopA["consignee"]
                put tDataA["UUID"] into tStopA["consigneeID"]
            end if
            break
        case "B Only"
            if the dgHilitedLines of group "dgConsignees" is empty then
                put "B Only" into tStopA["consignee"]
                put "B" into tStopA["consigneeID"]
            else
                put the dgHilitedLines of group "dgConsignees" into theLine
                put the dgDataOfLine[theLine] of group "dgConsignees" into tDataA
                put tDataA["name"] into tStopA["consignee"]
                put tDataA["UUID"] into tStopA["consigneeID"]
            end if
            break
        case "No Service"
            -- get the selected module
            put the dgHilitedLines of group "dgConsignees" into theLine
            if theLine = "" then
                answer error "No Consignee selected" with "OK"
                exit to top
            end if
            
            put the dgDataOfLine[theLine] of group "dgConsignees" into tDataA
            put "NOT " & tDataA["name"] into tStopA["consignee"]
            put "!" & tDataA["UUID"] into tStopA["consigneeID"]
            break
            
    end switch
    
    return tStopA
end addModuleStop

on closeCard
   local tResult
   put saveRecord() into tResult
   if tResult is false then answer error "Changes not saved due to error."
   
   uiClearData
end closeCard

on uiClearData
   put "" into field "symbol"
   put "" into field "origin"
   put "" into field "destination"
   put "" into field "name"
   set the dgText of group "dgRoute" to ""
   set the dgText of group "dgModules" to ""
   set the dgText of group "dgConsignees" to ""
   set the disabled of button "Save" to true
   set the label of button "directionIndicator" to "Direction Indicator (Optional)"
end uiClearData

on goTrainScreen
   dispatch "mouseUp" to button "Trains"
end goTrainScreen

on cancelPressed 
   if not the disabled of button "save" then
      answer  info "Would you like to save your changes?" with "No" or "Yes"
      if it is "Yes" then
         savePressed
         exit cancelPressed
       end if
    end if
    
    goTrainScreen
end cancelPressed

on savePressed
   local tResult
   
   set cursor to watch
   put saveRecord() into tResult
   if tResult then
      updateStatus "Train Route Saved"
      updateStatus ""
      goTrainScreen
      set cursor to arrow
   end if
end savePressed

function saveRecord
    local i, tTemp, tDataA, tResult
    
    lock screen
    updateStatus "Saving Route..."
    
    --put the dgText of group "dgRoute" into tDataA["route"]
    put the dgText of group "dgRoute" into tTemp
    set the dgText of group "dgRoute" to tTemp
    put the dgData of group "dgRoute" into tTemp
    put 1 into i
    repeat for each element aStop in tTemp
        put i into tTemp[i]["Stop"]
        add 1 to i
    end repeat
    
    put arrayToJson(tTemp, true) into tDataA["route"]
    
    put mdbUpdateRecord(sTrainUUID, "train", tDataA) into tResult
    
    if tResult is not a number then
        answer error tResult
        return false
    end if
    
    unlock screen
    updateStatus ""
    
    return true
end saveRecord

on reorderRoute pOriginatingIndex, pDroppedOnLine
   local tDataA, tTempA
   
   if pOriginatingIndex is not an integer then exit reorderRoute
   
   put the dgData of group "dgRoute" into tDataA
   put tDataA[pOriginatingIndex] into tTempA
   put tDataA[pDroppedOnLine] into tDataA[pOriginatingIndex]
   put tTempA into tDataA[pDroppedOnLine]
   
   set the dgData of group "dgRoute" to tDataA
   set the dgHilitedIndex of group "dgRoute" to pDroppedOnLine
end reorderRoute

