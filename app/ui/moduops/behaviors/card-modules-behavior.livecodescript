script "card-modules-behavior"
on preOpenCard
  lock screen
end preOpenCard


on openCard
  local tModuleId, tSelectedIndex
  local tMenuItemNumber
  
  set the dgData of group "dgModules" to module.findMany()
  
  ## Update buttons
  uiButtonState
  
  put the cModuleUUID of this card into tModuleId
  if tModuleId is not empty then
    dispatch "FindIndex" to group "dgModules" with "id", tModuleId
    put the result into tSelectedIndex
    set the dgHilitedindex of group "dgModules" to tSelectedIndex
    send "selectionChanged" to group "dgModules" in 1 milliseconds
  end if
  
  // enable the import menu
  put getMenuItemNumber("File", "Import Module...") into tMenuItemNumber
  enable menuitem tMenuItemNumber of menu "File"
  
  // update card title
  put the short name of this card into field "cardName"
  
  unlock screen
end openCard


command editPressed
  local tSelectedLine, theSelectedID
  
  put the dghilitedline of group "dgModules" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Module to edit."
    exit editPressed
  end if
  
  put the uSelectedID of group "dgModules" into theSelectedID
  
  
  // set flag indicating this is not a new record
  set the cIsNew of card "Edit Module/Town" to false
  
  editRecord theSelectedID
end editPressed


command editConsigneePressed
  local tSelectedLine, theSelectedID
  
  put the dghilitedline of group "dgConsignees" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Consignee to edit."
  else
    put the uSelectedID of group "dgConsignees" into theSelectedID
    
    // set flag that this is not a new record
    set the cIsNew of card "Edit Consignee" to false
    
    editConsignee theSelectedID
  end if
end editConsigneePressed


command newConsigneePressed
  local tDataA, tResult
  local tSelectedLine, moduleId
  
  put the dghilitedline of group "dgModules" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Module to edit."
  else
    put the uSelectedID of group "dgModules" into moduleId
    
    put uuid() into tDataA["id"]
    put "**New Consignee**" into tDataA["name"]
    put moduleId into tDataA["moduleID"]
    
    put consignee.create(tDataA) into tResult
    
    // set flag that this is a new record
    set the cIsNew of card "Edit Consignee" to true
    
    editConsignee tDataA["id"]
  end if
end newConsigneePressed


command editConsignee pSelectedID
  set the cActiveModule of card "Edit Consignee" to the uSelectedID of group "dgModules"
  set the cActiveConsignee of card "Edit Consignee" to pSelectedID
  go to card "Edit Consignee"
end editConsignee


command newSpotPressed
  local tDataA, tId, tResult
  local tSelectedLine, moduleId
  
  put the dghilitedline of group "dgModules" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Module first."
  else
    put the uSelectedID of group "dgModules" into moduleId
    
    put uuid() into tDataA["id"]
    put "**New Spot**" into tDataA["spot"]
    put "0" into tDataA["length"]
    put "A" into tDataA["direction"]
    put true into tDataA["active"]
    put moduleId into tDataA["moduleId"]
    
    put spot.create(tDataA) into tResult
    
    // set flag to indicate this is a new spot
    set the cIsNew of card "Edit Drop Zone" to true
    
    editSpot tDataA["id"]
  end if
end newSpotPressed


command editSpot pSelectedID
  set the cActiveModule of card "Edit Drop Zone" to the uSelectedID of group "dgModules"
  set the cActiveSpot of card "Edit Drop Zone" to pSelectedID
  go to card "Edit Drop Zone"
end editSpot


command editSpotPressed
  local tSelectedLine, theSelectedID
  
  put the dghilitedline of group "dgSpots" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Spot to edit."
  else
    put the uSelectedID of group "dgSpots" into theSelectedID
    
    // set flag to indicate this is NOT a new spot
    set the cIsNew of card "Edit Drop Zone" to false
    
    editSpot theSelectedID
  end if
end editSpotPressed


on editRecord pSelectedID
  set the cActiveModule of card "Edit Module/Town" to pSelectedID
  go to card "Edit Module/Town"
end editRecord


command newModulePressed
  local tDataArray, tUUID, tResult
  
  put uuid() into tUUID
  
  put tUUID into tDataArray["id"]
  put "**New Module/Town**" into tDataArray["name"]
  put "**New**" into tDataArray["short_name"]
  
  put module.create(tDataArray) into tResult
  
  // set flag indicating this is a new record for edit page
  set the cIsNew of card "Edit Module/Town" to true
  
  editRecord tUUID
end newModulePressed


on closeCard
  local tMenuItemNumber
  
  uiClearData
  
  // disable the import menu
  put getMenuItemNumber("File", "Import Module...") into tMenuItemNumber
  disable menuitem tMenuItemNumber of menu "File"
end closeCard


command uiButtonState
  set the disabled of button "Module Edit" to true
  set the fourgroundColor of button "Module Edit" to ""
  set the disabled of button "Module Delete" to true
  set the fourgroundColor of button "Module Delete" to ""
  set the disabled of button "Consignee Edit" to true
  set the fourgroundColor of button "Consignee Edit" to ""
  set the disabled of button "Spot Edit" to true
  set the fourgroundColor of button "Spot Edit" to ""
  set the disabled of button "Spot New" to true
  set the fourgroundColor of button "Spot Edit" to ""
  set the disabled of button "Spot Delete" to true
  set the fourgroundColor of button "Spot Edit" to ""
  set the disabled of button "Consignee New" to true
  set the fourgroundColor of button "Consignee New" to ""
  set the disabled of button "Consignee Delete" to true
  set the fourgroundColor of button "Consignee Delete" to ""
end uiButtonState


command uiModuleClicked
  
  ## Update Button status
  set the disabled of button "Module Edit" to false
  set the fourgroundColor of button "Module Edit" to "white"
  
  set the disabled of button "Module Delete" to false
  set the fourgroundColor of button "Module Delete" to "white"
  
  set the disabled of button "Consignee Edit" to true
  set the fourgroundColor of button "Consignee Edit" to ""
  
  set the disabled of button "Consignee Delete" to true
  set the fourgroundColor of button "Consignee Delete" to ""
  
  set the disabled of button "Spot Edit" to true
  set the fourgroundColor of button "Spot Edit" to ""
  
  set the disabled of button "Spot Clone" to true
  set the fourgroundColor of button "Spot Clone" to ""
  
  set the disabled of button "Spot Delete" to true
  set the fourgroundColor of button "Spot Delete" to ""
  
  set the disabled of button "Consignee New" to false
  set the fourgroundColor of button "Consignee New" to "white"
  
  set the disabled of button "Spot New" to false
  set the fourgroundColor of button "Spot New" to "white"
end uiModuleClicked


command uiImportModule
  local tModuleA, tConsigneeA, tSpotA, tWorkorderA, tCarTypeA, tResultA
  local tPath, tDataA, tTemp, tTempA, i
  local tCriteriaA
  local tWorkorderDTO
  
  // get the path to the modules last accessed
  put getLastFilePath("lastModulePath") into tPath
  
  answer file "Import Module:" with tPath with type "TEXT|json"
  
  if it is empty then exit uiImportModule
  
  put it into tPath
  
  // save the path to start from same location if import reselected
  setLastFilePath tPath, "lastModulePath" 
  
  updateStatus "Reading File..."
  put  URL ("binfile:" & tPath) into tTemp
  
  updateStatus "Decoding Data..."
  put JSONToArray(tTemp) into tDataA
  
  if tDataA is not an array then exit uiImportModule
  
  if module.findOne(tDataA["module"]["id"]) is not empty then
    answer error "Import Failed. Module already exists."
    exit uiImportModule
  end if
  
  // add module
  get module.create(tDataA["module"])
  
  // load consignees
  repeat for each element aConsignee in tDataA["consignee"]
    if consignee.findOne(aConsignee["id"]) is not empty then
      // skip if a duplicate
      next repeat
    end if
    get consignee.create(aConsignee)
  end repeat
  
  // remove duplicate spots
  repeat for each element aSpot in tDataA["spot"]
    if spot.findOne(aSpot["id"]) is not empty then
      // skip if a duplicate
      next repeat
    end if
    get spot.create(aSpot)
  end repeat
  
  // update car types
  // NOTE: this must happen before workorders in the event
  // that an existing car type can be reused for work orders
  repeat for each element aCar in tDataA["carType"]
    ## Online insert car types if they do not already exist in the DB
    if carType.findOne(aCar["id"]) is empty then
      
      ## now let's check if there's a "match" already in the carType table
      ## We assume if Class, Description and Length match then
      ## there's a duplicate car type and we should change the imported
      ## type to the car type that exists.
      put aCar["class"] into tCriteriaA["class"]
      put aCar["description"] into tCriteriaA["description"]
      put aCar["length"] into tCriteriaA["length"]
      put carType.findMany(tCriteriaA) into tTempA
      
      if tTempA is empty then
        get carType.create(aCar)
      else
        repeat with i = 1 to number of elements in tDataA["workorder"]
          if tDataA["workorder"][i]["carId"] = aCar["id"] then
            put tTempA[1]["id"] into tDataA["workorder"][i]["carId"]
          end if
        end repeat
      end if
    end if
  end repeat
  
  // add workorders
  repeat for each element aWorkorder in tDataA["workorder"]
    if workorder.findOne(aWorkorder["id"]) is not empty then
      // delete duplicate work order
      get workorder.delete(aWorkorder["id"])
    end if
    put aWorkorder["id"] into tWorkorderDTO["id"]
    put aWorkorder["carId"] into tWorkorderDTO["carId"]
    put aWorkorder["spotId"] into tWorkorderDTO["spotId"]
    put aWorkorder["consigneeId"] into tWorkorderDTO["consigneeId"]
    put aWorkorder["cpw"] into tWorkorderDTO["cpw"]
    put aWorkorder["remarks"] into tWorkorderDTO["remarks"]
    
    get workorder.create(tWorkorderDTO)
  end repeat
  
  dispatch "openCard" to card "Modules/Towns"
end uiImportModule


command uiClearData
  set the dgText of group "dgModules" to ""
  set the dgText of group "dgConsignees" to ""
  set the dgText of group "dgSpots" to ""
  --  set the cModuleUUID of this card to empty
end uiClearData


-- Duplicate a Spot
command clonePressed
  local tSelectedLine, theSelectedID, tDataA, tResult
  
  put the dghilitedline of group "dgSpots" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select Spot to Copy."
  else
    put the uSelectedID of group "dgSpots" into theSelectedID
    put spot.findOne(theSelectedID) into tDataA
    
    put uuid() into tDataA["id"]
    put spot.create(tDataA) into tResult
    
    if tResult is a number then
      editSpot  tDataA["id"]
    else
      answer error tResult
    end if
  end if
end clonePressed

