script "card-edit-drop-zone-behavior"
constant kFIELD_NAMES = "id,track,spot,length"

local sActiveModule
local sActiveSpot


on preOpenCard
  local tDataA
  
  put the cActiveSpot of this card into sActiveSpot
  put the cActiveModule of this card into sActiveModule
  
  // only show cancel button if this is a new request
  set the visible of button "cancel" to the cIsNew of this card
  
  // get the active spot from db
  put spot.findOne(sActiveSpot) into tDataA
  uiUpdateData tDataA
  
  buildMenu
  set the disabled of button "Save" to true
  
  // update layout name field
  put config.get("name") into field "layoutName"
  
  // update the length unit
  put "(" & config.get("lengthUnit") & ")" into field "lengthUnit"
end preOpenCard


on buildMenu
  local tDataA, tMenuItems
  
  // get all consignees for current module
  put consignee.findByModuleId(sActiveModule) into tDataA
  put " " & return into tMenuItems
  
  repeat for each element aConsignee in tDataA
    put aConsignee["name"] & return after tMenuItems
  end repeat
  
  set the text of button "Consignees" to tMenuItems
end buildMenu


on closeCard
  local tId
  
  if the cIsNew of this card is true then
    put field "id" into tId
    get spot.delete(tId)
    exit closeCard
  end if
  
  set the cModuleUUID of card "Modules/Towns" to the cActiveModule of this card
  
  uiClearFields
end closeCard


on goModulesScreen
  set the cModuleUUID of card "Modules/Towns" to the cActiveModule of this card
  dispatch "mouseUp" to button "Modules/Towns"
end goModulesScreen


command uiUpdateData pDataA
  local tModuleA
  
  lock screen
  // get module data
  put module.findOne(sActiveModule) into tModuleA
  
  // update module name
  put tModuleA["name"] into field "module"
  
  // update spot data in ui
  put pDataA["id"] into field "id"
  put pDataA["spot"] into field "spot"
  put pDataA["track"] into field "track"
  put pDataA["length"] into field "length"
  
  if pDataA["direction"] = "AB" then
    set the label of button "Direction Menu" to "A and B"
  else
    set the label of button "Direction Menu" to pDataA["direction"]
  end if
  
  // set value of the checkbox indicating spot is a Yard or not
  if pDataA["isYard"] is not a boolean then
    put false into pDataA["isYard"]
  end if
  set the hilite of button "isYard" to pDataA["isYard"]
  
  // set value of checkbox whether the spot is active or not
  if pDataA["active"] is a boolean then
    set the hilite of button "active" to pDataA["active"]
  else if pDataA["active"] = 1 then 
    set the hilite of button "active" to true
  else
    set the hilite of button "active" to false
  end if
  
  unlock screen
end uiUpdateData


on uiClearFields
  lock screen
  
  put "" into field "module"
  put "" into field "track"
  put "" into field "spot"
  put "" into field "length"
  set the label of button "Direction Menu" to ""
  set the label of button "Consignees" to ""
  set the hilite of button "isYard" to false
  set the hilite of button "active" to true
  
  set the disabled of button "Save" to true
  unlock screen
end uiClearFields


/*
update db when characters are typed in field
*/
private command __updateSpotField pFieldname
  local tDataA, tResult
  local tNewData
  
  if pFieldName is not among the items of kFIELD_NAMES then
    exit __updateSpotField
  end if
  
  put field pFieldname into tDataA[pFieldname]
  
  // convert track field to uppercase
  if pFieldname = "track" then
    put "" into tNewData
    repeat for each char i in field "track"
      put toUpper(i) after tNewData
    end repeat
    put tNewData into tDataA["track"]
  end if
  
  put field "id" into tDataA["id"]
  
  put spot.update(tDataA) into tResult
end __updateSpotField


on textChanged
  __updateSpotField the short name of the target
end textChanged


/*
update direction from menu pick
*/
command directionMenuPick pItemName
  local tResult, tDataA
  
  put field "id" into tDataA["id"]
  put pItemName into tDataA["direction"]
  put spot.update(tDataA) into tResult
end directionMenuPick


/*
update direction from menu pick
*/
command checkboxPick pItemName
  local tResult, tDataA
  
  put field "id" into tDataA["id"]
  put the hilited of button pItemName into tDataA[pItemName]
  put spot.update(tDataA) into tResult
end checkboxPick
