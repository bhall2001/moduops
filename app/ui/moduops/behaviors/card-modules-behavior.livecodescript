script "card-modules-behavior"
on preOpenCard
  lock screen
end preOpenCard


on openCard
  local tModuleUUID, tSelectedIndex
  
  set the dgData of group "dgModules" to module.findMany()
  
  ## Update buttons
  uiButtonState
  
  put the cModuleUUID of this card into tModuleUUID
  if tModuleUUID is not empty then
    dispatch "FindIndex" to group "dgModules" with "UUID", tModuleUUID
    put the result into tSelectedIndex
    set the dgHilitedindex of group "dgModules" to tSelectedIndex
    send "selectionChanged" to group "dgModules" in 20 milliseconds
  end if
  
  enable menuitem 6 of menu "File"
  
  unlock screen
end openCard


on editPressed
  local tSelectedLine, theSelectedID
  
  put the dghilitedline of group "dgModules" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Module to edit."
  else
    put the uSelectedID of group "dgModules" into theSelectedID
    editRecord theSelectedID
  end if
end editPressed


on editConsigneePressed
  local tSelectedLine, theSelectedID
  
  put the dghilitedline of group "dgConsignees" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Consignee to edit."
  else
    put the uSelectedID of group "dgConsignees" into theSelectedID
    editConsignee theSelectedID
  end if
end editConsigneePressed


on newConsigneePressed
  local tDataA, tResult
  local tSelectedLine, moduleId
  
  put the dghilitedline of group "dgModules" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Module to edit."
  else
    put the uSelectedID of group "dgModules" into moduleId
    
    put uuid() into tDataA["id"]
    put "Consignee Name" into tDataA["name"]
    put moduleId into tDataA["moduleID"]
    
    put consignee.create(tDataA) into tResult
    editConsignee tDataA["id"]
  end if
end newConsigneePressed


on editConsignee pSelectedID
  set the cActiveModule of card "Edit Consignee" to the uSelectedID of group "dgModules"
  set the cActiveConsignee of card "Edit Consignee" to pSelectedID
  go to card "Edit Consignee"
end editConsignee


on newSpotPressed
  local tDataA, tUUID, tResult
  local tSelectedLine, moduleUUID
  
  put the dghilitedline of group "dgModules" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Module first."
  else
    put the uSelectedID of group "dgModules" into moduleUUID
    
    put uuid() into  tUUID
    
    put tUUID into tDataA["UUID"]
    put "Spot Name" into tDataA["spot"]
    put "0" into tDataA["length"]
    put "A" into tDataA["direction"]
    put true into tDataA["active"]
    put moduleUUID into tDataA["moduleID"]
    
    put dbInsert("spot", tDataA) into tResult
    editSpot tDataA["UUID"]
  end if
end newSpotPressed


on editSpot pSelectedID
  set the cActiveModule of card "Edit Drop Zone" to the uSelectedID of group "dgModules"
  set the cActiveSpot of card "Edit Drop Zone" to pSelectedID
  go to card "Edit Drop Zone"
end editSpot


on editSpotPressed
  local tSelectedLine, theSelectedID
  
  put the dghilitedline of group "dgSpots" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Spot to edit."
  else
    put the uSelectedID of group "dgSpots" into theSelectedID
    editSpot theSelectedID
  end if
end editSpotPressed


on editRecord pSelectedID
  set the cActiveModule of card "Edit Module/Town" to pSelectedID
  go to card "Edit Module/Town"
end editRecord


on newModulePressed
  local tDataArray, tUUID, tResult
  
  put uuid() into tUUID
  
  put tUUID into tDataArray["id"]
  put "Module Name" into tDataArray["name"]
  put "Module" into tDataArray["short_name"]
  
  put module.create(tDataArray) into tResult
  
  editRecord tUUID
end newModulePressed


on closeCard
  uiClearData
  disable menuitem 6 of menu "File"
end closeCard


on uiButtonState
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


on uiModuleClicked
  
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


on uiImportModule
  local tModuleA, tConsigneeA, tSpotA, tWorkorderA, tCarTypeA, tResultA
  local tPath, tDataA, tTemp, tTempA, i
  
  put specialFolderPath("Documents") into tPath
  answer file "Import Module:" with tPath with type "TEXT|dat"
  if it is not empty then
    put it into tPath
    
    updateStatus "Reading File..."
    put  URL ("binfile:" & tPath) into tTemp
    
    updateStatus "Decoding Data..."
    put arrayDecode(tTemp) into tDataA
    
    if tDataA is an array then
      if mdbQueryByUUID("module", tDataA["module"][1]["UUID"]) is not empty then
        answer error "Import Failed. Module already exists."
        exit uiImportModule
      end if
      
      if tDataA["consignee"]["UUID"] is not empty then
        if mdbQueryByUUID("consignee", tDataA["consignee"]["UUID"]) is not empty then
          answer error "Import Failed. Module already exists."
          exit uiImportModule
        end if
      end if
      
      if mdbQueryByUUID("spot", tDataA["spot"]["UUID"]) is not empty then
        answer error "Import Failed. Module already exists."
        exit uiImportModule
      end if
      
      if mdbQueryByUUID("workorder", tDataA["workorder"]["UUID"]) is not empty then
        answer error "Import Failed. Module already exists."
        exit uiImportModule
      end if        
      
      repeat for each element aCar in tDataA["carType"]
        ## Online insert car types if they do not already exist in the DB
        if mdbQueryByUUID("carType", aCar["UUID"]) is empty then
          
          ## now let's check if there's a "match" already in the carType table
          ## We assume if Class, Description and Length match then
          ## there's a duplicate car type and we should change the imported
          ## type to the car type that exists.
          dbResetQuery
          dbWhere "class", aCar["class"]
          dbWhere "description", aCar["description"]
          dbWhere "length", aCar["length"]
          put dbGet("carType") into tTempA
          
          if tTempA is empty then
            get mdbInsertRecord("carType", aCar)
          else
            put 1 into i
            repeat for each element aWorkorder in tDataA["workorder"]
              if tDataA["workorder"][i]["carID"] = aCar["UUID"] then
                put tTempA[1]["UUID"] into tDataA["workorder"][i]["carID"]
              end if
              add 1 to i
            end repeat
          end if
          
        end if
      end repeat
      
      -- Load Tables from data
      if tDataA["module"] is an array then
        get populateTable("module", tDataA["module"])
      end if
      
      if tDataA["consignee"] is an array then
        get populateTable("consignee", tDataA["consignee"])
      end if
      
      if tDataA["spot"] is an array then
        get populateTable("spot", tDataA["spot"])
      end if
      
      if tDataA["workorder"] is an array then
        get populateTable("workorder", tDataA["workorder"])
      end if
    end if
  end if
  
  dispatch "openCard" to card "Modules/Towns"
end uiImportModule


on uiClearData
  set the dgText of group "dgModules" to ""
  set the dgText of group "dgConsignees" to ""
  set the dgText of group "dgSpots" to ""
  set the cModuleUUID of this card to empty
end uiClearData


-- Duplicate a Spot
on clonePressed
  local tSelectedLine, theSelectedID, tDataA, tResult
  
  put the dghilitedline of group "dgSpots" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select Spot to Copy."
  else
    put the uSelectedID of group "dgSpots" into theSelectedID
    put mdbQueryByUUID("spot", theSelectedID) into tDataA
    put tDataA[1] into tDataA
    
    put uuid() into tDataA["UUID"]
    put mdbInsertRecord("spot", tDataA) into tResult
    if tResult is a number then
      editSpot  tDataA["UUID"]
    else
      answer error tResult
    end if
  end if
end clonePressed

