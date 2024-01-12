script "card-edit-equipment-request-behavior"
constant kFIELD_NAMES = "id,cpw,remarks"

local sActiveModule
local sActiveConsignee
local sCarTypeA
local sWorkorderId


on preOpenCard
  set the visible of button "cancel" of me to the cIsNew of this card
  
  
  // update layout name field
  put config.get("name") into field "layoutName"
end preOpenCard


on openCard
  local tSpotA, tConsigneeA, tModuleA, tWorkorderA, tSelectedIndex, tSelectedLine
  local tDataA
  local tResult
  local tSpotId
  
  lock screen
  
  put the cActiveModule of card "Edit Consignee" into sActiveModule
  put the cActiveConsignee of card "Edit Consignee" into sActiveConsignee
  put the cWorkorderUUID of card "Equipment Request" into sWorkorderId
  
  # Display the Consignee Name
  put consignee.findOne(sActiveConsignee) into tConsigneeA
  put tConsigneeA["name"] into field "name"
  
  # Display Module Name
  put module.findOne(sActiveModule) into tModuleA
  put tModuleA["name"] into field "module"
  
  if sWorkorderId is not "" then // we are editting an existing workorder
    // get workorder from database
    put workorder.findOne(sWorkorderId) into tWorkorderA
    
    // add data to ui
    put tWorkorderA["id"] into field "id"
    put tWorkorderA["cpw"] into field "cpw"
    put tWorkorderA["remarks"] into field "remarks"
    
    // set the equipment list to allow only selecting 1 item
    set the dgProps["multiple lines"] of group "dgCarTypes" of me to false
    
    // hilite workorder spot
    --    put tWorkorderA["spotId"] into tSpotId
    --    if tSpotId is not empty then
    --      dispatch "FindIndex" to group "dgSpots" with "id", tSpotId
    --      put the result into tSelectedIndex
    --      set the dgHilitedindex of group "dgSpots" to tSelectedIndex
    --      send "selectionChanged" to group "dgSpots" in 1 milliseconds
    --    end if
    
    --    put the cModuleUUID of this card into tModuleId
    --    if tModuleId is not empty then
    --      dispatch "FindIndex" to group "dgModules" with "id", tModuleId
    --      put the result into tSelectedIndex
    --      set the dgHilitedindex of group "dgModules" to tSelectedIndex
    --      send "selectionChanged" to group "dgModules" in 1 milliseconds
    --    end if
    
  else // we are creating a new workoder
    --    put uuid() into field "id"
    put "1" into field "cpw"
    put "" into field "remarks"
    
    // allow selecting multiple lines
    set the dgProps["multiple lines"] of group "dgCarTypes" of me to true
  end if
  
  put spot.findByModuleId(sActiveModule) into tSpotA
  
  if tSpotA is "" then
    answer error "Please define a spot for this Module first."
    go to card "Edit Consignee"
    exit openCard
  else
    set the dgData of group "dgSpots" to tSpotA
    
    // load all car types
    put carType.findMany() into sCarTypeA
    
    if sCarTypeA is "" then
      answer error "Please define Rolling Stock first."
      go to card "Edit Consigness"
      exit openCard
    else
      set the dgData of group "dgCarTypes" to sCarTypeA
    end if
  end if
  
  dispatch "FindIndex" to group "dgSpots" with "id", tWorkorderA["spotID"]
  put the result into tSelectedIndex
  set the dgHilitedindex of group "dgSpots" to tSelectedIndex
  put the dgHilitedLine of group "dgSpots" -1 into tSelectedLine
  set the dgVScrollPercent of group "dgSpots" to (tSelectedLine)/(the dgNumberOfLines of group "dgSpots")
  
  dispatch "FindIndex" to group "dgCarTypes" with "id", tWorkorderA["carID"]
  put the result into tSelectedIndex
  set the dgHilitedindex of group "dgCarTypes" to tSelectedIndex
  put the dgHilitedLine of group "dgCarTypes" -1 into tSelectedLine
  set the dgVScrollPercent of group "dgCarTypes" to (tSelectedLine)/(the dgNumberOfLines of group "dgCarTypes")
  
  // set the cancel flag to false
  set the cIsCancel of this card to false
  
  set the visible of button "cancel" of me to the cIsNew of this card
  
  unlock screen
  
  pass openCard
end openCard


on closeCard 
  if the cIsCancel of this card then 
    exit closeCard
  end if
  
  lock screen
  put "" into field "module"
  put "" into field "name"
  put "" into field "CPW"
  put "" into field "remarks"
  set the dgText of group "dgSpots" to ""
  set the dgText of group "dgCarTypes" to ""
  set the disabled of button "Save" to true
  unlock screen
  
end closeCard


command handleDone
  if saveData() then
    goEditConsignee
  end if
end handleDone


/*
function getSpots
  local tSQL, tDataA
  
  put "SELECT   spot.track, spot.spot, spot.UUID, spot.moduleID" & return into tSQL
  put "FROM      spot" & return after tSQL
  put "WHERE    ( spot.moduleID = " & quote & sActiveModule & quote & " )" after tSQL
  
  dbResetQuery
  dbSetSQL tSQL
  put dbGet() into tDataA
  
  return tDataA
end getSpots
*/


on selectClass pClass
  local tDataA, i
  
  put char 1 of pClass into pClass
  put 1 into i
  repeat for each element aCar in sCarTypeA
    if aCar["class"] = pClass then
      put aCar into tDataA[i]
      add 1 to i
    end if
  end repeat
  
  set the dgData of group "dgCarTypes" to tDataA
end selectClass


function saveData
  local tDataA, tResult
  local tEquipmentSelected // list of line numbers in data grid for each equipment selected
  local tEquipmentA // array holding each line of equipement
  
  lock screen
  
  // Validate data entry. If failure, show error message and exit.
  validateData
  
  // Check validation result
  if the result is not empty then
    put the Result into tResult
    answer error tResult["errorText"][1]
    exit saveData
  end if
  
  put the dgHilitedLines of group "dgCarTypes" of me into tEquipmentSelected
  repeat for each item aLine in tEquipmentSelected
    put empty into tDataA
    put the dgDataOfLine[aLine] of group "dgCarTypes" of me into tEquipmentA
    
    
    
    // Move data entry fields into an array
    put field "id" into tDataA["id"]
    put field "cpw" into tDataA["cpw"]
    put field "remarks" into tDataA["remarks"]
    put the uSelectedID of group "dgSpots" into tDataA["spotID"]
    //put the uSelectedID of group "dgCarTypes" into tDataA["carID"]
    put tEquipmentA["id"] into tDataA["carID"]
    
    if sWorkorderId is "" then // this will always be the case when creating new workorders
      put uuid() into tDataA["id"]
      put sActiveConsignee into tDataA["consigneeID"]
      put workorder.create(tDataA) into tResult
    else   
      put workorder.update(tDataA) into tResult
    end if
  end repeat
  
  unlock screen
  return true
end saveData


/*
* Validate Form Data
*/
command validateData
  local tErrorIndex = 0
  local tErrorA
  
  -- Confirm there is a Consignee name
  if field "cpw" = "" then
    add 1 to tErrorIndex
    put "Please enter cars/week value" into tErrorA["errorText"][tErrorIndex]
  end if
  
  if the dgHilitedLine of group "dgSpots" is "" then
    add 1 to tErrorIndex
    put "Please select a Spot" into tErrorA["errorText"][tErrorIndex]
  else if the dgHilitedLine of group "dgCarTypes" is "" then
    add 1 to tErrorIndex
    put "Please select a Car Type" into tErrorA["errorText"][tErrorIndex]
  end if
  
  if tErrorIndex > 0 then
    return tErrorA for error
  end if
  
  return empty for error
end validateData


/*
* Return to the Edit Consignee screen
* 17-JAN-2017
*/
command goEditConsignee
  go to card "Edit Consignee"
end goEditConsignee


command deletePressed
  local tResult
  answer warning "Delete Current Equipment Request? (THIS CAN NOT BE UNDONE.)" with "Yes" or "No"
  if it is "no" then exit to top
  
  put workorder.delete(card field "id") into tResult
  
  go to card "Edit Consignee"
end deletePressed
