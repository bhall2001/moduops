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
  
  if the short name of this card is not "Equipment Request Report" then pass openCard
  
  // clear module filter menu
  set the label of button "ModuleFilterMenu" to " "
  
  // clear owner filter menu
  set the label of button "OwnerFilterMenu" to " "
  
  displayFilteredModule
  
  // build module filter menu
  get buildModuleFilterItems()
  
  // build owner filter menu
  get buildOwnerFilterItems()
  
  // setup columns menu
  __setupColumnMenu
  
  // hide or show fields in the ui  
  hideShowPgColumns
  
end openCard


on closeCard
  if the short name of this card is not "Equipment Request Report" then pass closeCard
  hideMenus
end closeCard



function loadModuleEquipmentData pModuleId, pOwner
  local tModuleDetailA
  
  put module.equipmentReport(pModuleId, pOwner) into tModuleDetailA
  
  return tModuleDetailA
  
end loadModuleEquipmentData



command displayFilteredModule pFilterMenuIndex
  local tModuleDetailA
  local tModuleId
  
  lock screen
  
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
    set the scroll of widget "pgModuleDetail" of group id 3097118 of me to 0
  end if
  unlock screen
end displayFilteredModule


command displayFilteredOwner pFilterOwner
  local tModuleDetailA
  local tModuleIdList
  local tWhere
  
  lock screen
  
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
    set the scroll of widget "pgModuleDetail" of group id 3097118 of me to 0
  end if
  unlock screen
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


command exportToCsv
  local tModuleReport, tPgDataA
  local tFileName, tFileContents
  local tName
  
  put __getFilename() into tName
  put ".csv" after tName
  
  ask file "Please choose a where you want to save the file" with getLastFilePath() & "/" & tName with type "Comma Separated Values|csv|TEXT"
  
  if the result is "cancel" then exit exportToCsv
  
  put it into tFileName
  ## Ensure the file extension is csv      
  set the itemDel to "."      
  if item 2 of tFileName is not "csv" then
    put "csv" into item 2 of tFileName
  end if
  
  put __getTsvData() into tModuleReport  
  
  replace tab with comma in tModuleReport
  put "module,consignee,reference,zone,code,equipment,length,cpw" & return before tModuleReport
  
  ## Save the data out to file
  put tModuleReport into URL ("file:" & tFileName)
end exportToCsv


command exportToTsv
  local tModuleReport
  local tFileName, tFileContents
  local tName
  
  put __getFilename() into tName  
  put ".tsv" after tName
  
  ask file "Please choose a where you want to save the file" with getLastFilePath() & "/" & tName with type "Comma Separated Values|tsv|TEXT"
  
  if the result is "cancel" then exit exportToTsv
  
  put it into tFileName
  ## Ensure the file extension is tsv      
  set the itemDel to "."      
  if item 2 of tFileName is not "tsv" then
    put "tsv" into item 2 of tFileName
  end if
  
  put __getTsvData() into tModuleReport
  
  put "module,consignee,reference,zone,code,equipment,length,cpw" & return before tModuleReport
  
  ## Save the data out to file
  put tModuleReport into URL ("file:" & tFileName)
end exportToTsv


private function __getTsvData
  local tPgDataA, tModuleReport
  
  put the pgData of widget "pgModuleDetail" into tPgDataA
  
  repeat for each element aRow in tPgDataA
    put quote & aRow["moduleName"] & quote & tab after tModuleReport
    put quote & aRow["consigneeName"] & quote & tab after tModuleReport
    put quote & aRow["dropZoneRef"] & quote & tab after tModuleReport
    put quote & aRow["dropZoneName"] & quote & tab after tModuleReport
    
    if config.get("EquipmentReportCode") = 1 then
      put quote & aRow["code"] & quote & tab after tModuleReport
    end if
    
    if config.get("EquipmentReportShort") = 1 then
      put quote & aRow["short"] & quote  & tab after tModuleReport
    end if
    
    put quote & aRow["equipment"] & quote & tab after tModuleReport
    put aRow["length"] & tab after tModuleReport
    put aRow["cpw"] after tModuleReport
    
    put return after tModuleReport
  end repeat
  
  return tModuleReport
end __getTsvData


private function __getFilename
  local tName
  
  put "equipment-requests" into tName
  
  if the label of button "ModuleFilterMenu" is not " " then
    put "-" & the label of button "ModuleFilterMenu" after tName
    replace " " with "-" in tName
    put toLower(tName) into tName
  end if
  
  if the label of button "OwnerFilterMenu" is not " " then
    put "-" & the label of button "OwnerFilterMenu" after tName
    replace " " with "-" in tName
    put toLower(tName) into tName
  end if
  
  return tName
end __getFilename



private command __setupColumnMenu
  if config.get("EquipmentReportCode") = 1 then
    set the iconPresetName of widget "codeCheck" of group "columnsMenuGroup" to "check"
  else
    set the iconPresetName of widget "codeCheck" of group "columnsMenuGroup" to "check empty"
  end if
  
  if config.get("EquipmentReportShort") = 1 then
    set the iconPresetName of widget "shortCheck" of group "columnsMenuGroup" to "check"
  else
    set the iconPresetName of widget "shortCheck" of group "columnsMenuGroup" to "check empty"
  end if
end __setupColumnMenu



command printReport
  local tDataA
  
  put the pgData of widget "pgModuleDetail" of me into tDataA
  set the uDataA of stack "Equipment Request Report" to tDataA
  
  if the label of button "ModuleFilterMenu" is not " " then
    set the uReportTitle of stack "Equipment Request Report" to the label of button "ModuleFilterMenu"
  end if
  
  if the label of button "OwnerFilterMenu" is not " " then
    set the uReportTitle of stack "Equipment Request Report" to the label of button "OwnerFilterMenu"
  end if
  
  send "printReport" to card 1 of stack "Equipment Request Report"
end printReport


command hideMenus pSource
  local tIgnoreEvent
  
  put "ExportMenu,ColumnMenu,shortCheck,codeCheck,columnRect,codeLabel,shortLabel,OutputButtonGroup,exportCsv,exportTsv,print" into tIgnoreEvent
  if pSource is among the items of tIgnoreEvent then exit hideMenus
    
  lock screen
  set the visible of group "OutputButtonGroup" of me to false
  set the visible of group "columnsMenuGroup" of me to false
  unlock screen
end hideMenus


command hideShowPgColumns
  local tColumns
  local tConfigA
  
  put the pgColumns of widget "pgModuleDetail" into tColumns
  
  put config.get("EquipmentReportCode") = 1 into tColumns[5]["visible"]
  put config.get("EquipmentReportShort") = 1 into tColumns[6]["visible"]
  
  set the pgColumns of widget "pgModuleDetail" to tColumns
end hideShowPgColumns



