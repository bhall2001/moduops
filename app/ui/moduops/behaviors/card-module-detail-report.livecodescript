script "card-module-detail-report"
local sModuleFilterItems
local sOwnerFilterItems

on preOpenCard
  lock screen
end preOpenCard

/**
This function is called when a card is opened.
It prepares the necessary data for the card and updates the user interface.

Parameters:
None

Return:
None
*/
on openCard
  local tModuleDetailA
  
  // clear module filter menu
  set the label of button "ModuleFilterMenu" to " "
  
  // clear owner filter menu
  set the label of button "OwnerFilterMenu" to " "
  
  displayFilteredModule
  
  -- build module filter menu
  get buildModuleFilterItems()
  
  -- build owner filter menu
  get buildOwnerFilterItems()
  
end openCard



function loadModuleEquipmentData pModuleId, pOwner
  local tModuleDetailA
  
  put module.equipmentReport(pModuleId, pOwner) into tModuleDetailA
  
  return tModuleDetailA
  
end loadModuleEquipmentData



command displayFilteredModule pFilterMenuIndex
  local tModuleDetailA
  local tModuleId
  
  if pFilterMenuIndex is a number then
    put sModuleFilterItems[pFilterMenuIndex]["moduleId"] into tModuleId
  end if
  
  -- Calls the loadModuleEquipmentData function to retrieve the module detail report data.
  put loadModuleEquipmentData(tModuleId) into tModuleDetailA
  
  if tModuleDetailA is not an array then
    put sModuleFilterItems[pFilterMenuIndex]["moduleName"] into tModuleDetailA[1]["moduleName"]
    put "No equipment requests" into tModuleDetailA[1]["consigneeName"]
  end if
  
  -- Check if the retrieved data is an array.
  if tModuleDetailA is an array then
    -- If the data is an array, update the pgData property of the "pgModuleDetail" widget with the retrieved data.
    set the pgData of widget "pgModuleDetail" to tModuleDetailA
  end if
end displayFilteredModule


command displayFilteredOwner pFilterOwner
  local tModuleDetailA
  local tModuleIdList
  local tWhere
  
  -- Calls the loadModuleEquipmentData function to retrieve the module detail report data.
  put loadModuleEquipmentData(,pFilterOwner) into tModuleDetailA
  
  if tModuleDetailA is not an array then
    put pFilterOwner into tModuleDetailA[1]["moduleName"]
    put "No equipment requests" into tModuleDetailA[1]["consigneeName"]
  end if
  
  -- Check if the retrieved data is an array.
  if tModuleDetailA is an array then
    -- If the data is an array, update the pgData property of the "pgModuleDetail" widget with the retrieved data.
    set the pgData of widget "pgModuleDetail" to tModuleDetailA
  end if
end displayFilteredOwner



function buildModuleFilterItems
  local tModuleA
  local tModuleFilterMenuItems
  
  put module.findMany(,"name") into tModuleA
  
  put empty into sModuleFilterItems
  put " " into sModuleFilterItems[1]["moduleName"]
  put "" into sModuleFilterItems[1]["moduleId"]
  put " " & return after tModuleFilterMenuItems
  
  repeat with i = 1 to number of elements of tModuleA
    put tModuleA[i]["name"] into sModuleFilterItems[i+1]["moduleName"]
    put tModuleA[i]["id"] into sModuleFilterItems[i+1]["moduleId"]
    put tModuleA[i]["name"] & return after tModuleFilterMenuItems
  end repeat
  
  set the label of button "ModuleFilterMenu" to " "
  set the menuHistory of button "ModuleFilterMenu" to 1
  set the text of button "ModuleFilterMenu" to tModuleFilterMenuItems
  
end buildModuleFilterItems


function buildOwnerFilterItems
  local tModuleA
  local tOwnerFilterMenuItems
  local tPrevOwner
  
  put module.findMany(,"owner") into tModuleA
  
  put " " & return after tOwnerFilterMenuItems
  
  repeat with i = 1 to number of elements of tModuleA
    if tModuleA[i]["owner"] is empty then next repeat
    if tModuleA[i]["owner"] <> tPrevOwner then
      put tModuleA[i]["owner"] & return after tOwnerFilterMenuItems
      put tModuleA[i]["owner"] into tPrevOwner
    end if
    
  end repeat
  
  set the label of button "OwnerFilterMenu" to " "
  set the menuHistory of button "OwnerFilterMenu" to 1
  set the text of button "OwnerFilterMenu" to tOwnerFilterMenuItems
  
end buildOwnerFilterItems


