script "card-edit-module-behavior"
constant kFIELD_NAMES = "id,name,short_name,owner,size,city,passing,description,remarks"

local sActiveModule

on openCard
  local tModuleA
  
  lock screen
  
  // get the active module
  put the cActiveModule of this card into sActiveModule
  
  // load from db
  put module.findOne(sActiveModule) into tModuleA
  
  // update ui
  uiUpdateData tModuleA
  enable menuitem 7 of menu "File"
  
  unlock screen
end openCard


on closeCard
  set the cModuleUUID of card "Modules/Towns" to the cActiveModule of this card
  uiClearFields
  disable menuitem 7 of menu "File"
end closeCard


on goModulesScreen
  set the cModuleUUID of card "Modules/Towns" to the cActiveModule of this card
  go to card "Modules/Towns"
end goModulesScreen


command uiUpdateData pDataA
  lock screen
  put pDataA["id"] into field "id"
  put pDataA["name"] into field "name"
  put pDataA["short_name"] into field "short_name"
  put pDataA["owner"] into field "owner"
  put pDataA["size"] into field "size"
  put pDataA["city"] into field "city"
  //put pDataA["state"] into field "state"
  if pDataA["state"] is empty then
    put " " into pDataA["state"]
  end if
  set the label of button "state" to pDataA["state"]
  put pDataA["description"] into field "description"
  put pDataA["remarks"] into field "remarks"
  
  unlock screen
end uiUpdateData


on uiClearFields
  lock screen
  
  put "" into field "name"
  put "" into field "short_name" 
  put "" into field "owner"
  put "" into field "size"
  put "" into field "city"
  //put "" into field "state"
  set the label of button "state" to " "
  put "" into field "description"
  put "" into field "remarks"
  
  set the disabled of button "Save" to true
  unlock screen
end uiClearFields


/*
Save Form data to DB
*/
function saveData
  return true
end saveData


/*
Validate Form data
*/
on validateData
  local tErrorIndex=0
  local tErrorA
  
  -- Confirm there is a module name
  if field "name" = "" then
    add 1 to tErrorIndex
    put "Please enter a Module Name" into tErrorA["errorText"][tErrorIndex]
  end if
  
  -- Confirm there is a module short name
  if field "short_name" = "" then
    add 1 to tErrorIndex
    put "Please enter a Module Short Name" into tErrorA["errorText"][tErrorIndex]
  end if
  
  if tErrorIndex > 0 then
    return tErrorA for error
  end if
end validateData


on uiExportModule
  local tModuleA, tConsigneeA, tSpotA, tWorkorderA, tCarTypeA, tResultA, tPath, tDataA
  
  updateStatus "Gathering Data..."
  put mdbQueryByUUID("module", sActiveModule) into tModuleA
  put mdbQueryByModuleID("consignee", tModuleA[1]["UUID"]) into tConsigneeA
  put mdbQueryByModuleID("spot", tModuleA[1]["UUID"]) into tSpotA
  put mdbQueryWOByModuleID(sActiveModule) into tWorkorderA
  put mdbQueryCarTypeByModuleID(sActiveModule) into tCarTypeA
  
  put tModuleA into tResultA["module"]
  put tConsigneeA into tResultA["consignee"]
  put tSpotA into tResultA["spot"]
  put tWorkorderA into tResultA["workorder"]
  put tCarTypeA into tResultA["carType"]
  
  updateStatus "Creating Export Data..."
  put arrayEncode(tResultA) into tDataA
  
  put specialFolderPath("Documents") into tPath
  put "/" & tModuleA[1]["name"] & ".dat" after tPath
  replace " " with "_" in tPath
  
  updateStatus "Waiting on export file selection..."
  ask file "Export Module as" with tPath
  if it is not empty then
    updateStatus "Writing File..."
    put it into tPath
    put tDataA into URL ("binfile:" & tPath)
    updateStatus "File Save!"
    wait 1 seconds
  end if
  updateStatus ""
end uiExportModule


/*
update classification from menu pick
*/
command stateMenuPick pItemName
  local tResult, tDataA
  
  put field "id" into tDataA["id"]
  put pItemName into tDataA["state"]
  put module.update(tDataA) into tResult
end stateMenuPick


/*
update db when characters are typed in field
*/
private command __updateModuleField pFieldname
  local tDataA, tResult
  
  if pFieldName is not among the items of kFIELD_NAMES then
    exit __updateModuleField
  end if
  
  put field pFieldname into tDataA[pFieldname]
  put field "id" into tDataA["id"]
  
  put module.update(tDataA) into tResult
end __updateModuleField


on textChanged
  __updateModuleField the short name of the target
end textChanged


