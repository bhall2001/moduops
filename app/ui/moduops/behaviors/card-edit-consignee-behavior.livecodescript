script "card-edit-consignee-behavior"
constant kFIELD_NAMES = "id,name,remarks"

local sActiveModule
local sActiveConsignee


on preOpenCard
  local tDataA, t2DataA
  
  lock screen
  uiDisableButtons
  
  // move card property to script variable.
  put the cActiveModule of this card into sActiveModule
  
  set the label of button "Done" of me to "Done"
  
  if __isNewRequestAllowed() then
    enable button "New Request"
    set the foregroundColor of button "New Request" to "white"
    hide button "cancel"
    hide field "errorText"
  else  
    disable button "New Request"
    show button "cancel"
    
    if the cIsNew of card "Edit Consignee" is false then
      
      // TODO: delete
      put the cIsNew of card "Edit Consignee"
      
      
      if  carType.count() = 0 then
        put "Unable to create a new request until equipement is defined." into field "errorText"
      else
        put "Unable to create a new request until a drop zone is defined." into field "errorText"
      end if
      
      
      show field "errorText"
    else
      hide field "errorText"
      set the label of button "Done" of me to "Create"
    end if
  end if
  
  put the cActiveModule of this card into sActiveModule
  put the cActiveConsignee of this card into sActiveConsignee
  
  // get active consignee data
  put consignee.findOne(sActiveConsignee) into tDataA
  
  // find the active module
  put module.findOne(sActiveModule) into t2DataA
  
  // add name field to data for ui display
  put t2DataA["name"] into tDataA["module"]
  
  uiUpdateData tDataA
  
  pass preOpenCard
end preOpenCard


on closeCard
  local tId
  
  if the cIsNew of this card is true then
    put field "id" into tId
    get consignee.delete(tId)
    exit closeCard
  end if
  
  uiDisableButtons
  uiClearFields
  set the cModuleUUID of card "Modules/Towns" to the cActiveModule of this card
end closeCard


on goModulesScreen
  set the cModuleUUID of card "Modules/Towns" to the cActiveModule of this card
  dispatch "mouseUp" to button "Modules/Towns"
end goModulesScreen


command uiUpdateData pDataA
  lock screen
  
  put pDataA["id"] into field "id"
  put pDataA["name"] into field "name"
  put pDataA["module"] into field "module"
  put pDataA["remarks"] into field "remarks"
  
  loadWorkorders
  
  unlock screen
end uiUpdateData


on uiClearFields
  lock screen
  
  put "" into field "name"
  put "" into field "remarks"
  put "" into field "module"
  set the dgText of group "dgWorkorders" to ""
  
  set the disabled of button "Save" to true
  unlock screen
end uiClearFields


on uiDisableButtons
  set the disabled of button "Save" to true
  
  set the disabled of button "Edit Request" to true
  set the foregroundColor of button "Edit Request" to ""
  --set the blendLevel of button "Edit Request" to 60
  
  set the disabled of button "Clone Request" to true
  set the foregroundColor of button "Clone Request" to ""
  --set the blendLevel of button "Clone Request" to 60
  
  set the disabled of button "Delete" to true
  set the foregroundColor of button "Delete" to ""
  --set the blendLevel of button "Delete" to 60
  
  if the cIsNew of this card is true then
    set the disabled of button "New Request" to true
    set the foregroundColor of button "New Request" to ""
  end if
  
end uiDisableButtons


/*
Save Form data to DB
*/
function saveData
  local tDataA, tResult
  
  --  lock screen
  
  --  // Validate data entry. If failure, show error message and exit.
  --  validateData
  
  --  // Check validation result
  --  if the result is not empty then
  --    put the Result into tResult
  --    answer error tResult["errorText"][1]
  --    exit to top
  --  end if
  
  
  --  ## Move data entry fields into an array
  --  put sActiveModule into tDataA["moduleID"]
  --  put sActiveConsignee into tDataA["UUID"]
  --  put field "name" into tDataA["name"]
  --  put field "remarks" into tDataA["remarks"]
  
  --  put mdbUpdateRecord(sActiveConsignee, "consignee", tDataA) into tResult
  --  if tResult is not a number then
  --    answer error tResult
  --    return false
  --  end if
  
  --  unlock screen
  return true
  
end saveData


command validateData
  local tErrorIndex = 0
  local tErrorA
  
  -- Confirm there is a Consignee name
  if field "name" = "" then
    add 1 to tErrorIndex
    put "Please enter a Consignee Name" into tErrorA["errorText"][tErrorIndex]
  end if
  
  if tErrorIndex > 0 then
    return tErrorA for error
  end if
end validateData


/*
comment
*/
on loadWorkOrders
  local tDataA
  
  --  put "SELECT  workorder.CPW, spot.track, spot.spot, workorder.UUID," && \
  --        "carType.class, carType.description, carType.length" & return & \
  --        "FROM     spot" & return & \
  --        "INNER JOIN workorder  ON spot.UUID = workorder.spotID" & return & \
  --        "INNER JOIN carType  ON carType.UUID = workorder.carID" & return & \
  --        "WHERE workorder.consigneeID = " & quote & sActiveConsignee & quote into tSQL
  
  --  dbResetQuery
  --  dbSetSQL tSQL
  --  put dbGet() into tDataA
  
  put workorder.findByConsigneeId(sActiveConsignee) into tDataA
  
  if the number of elements of tDataA > 0 then
    set the cIsNew of this card to false
    set the visible of button id 2590776 to false
  end if
  
  set the dgData of group "dgWorkorders" to tDataA
end loadWorkOrders


on editPressed
  local tSelectedLine, theSelectedID
  
  put the dghilitedline of group "dgWorkorders" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Line to edit."
  else
    put the uSelectedID of group "dgWorkorders" into theSelectedID
    
    set the cIsNew of card "Equipment Request" to false
    
    editRecord  theSelectedID
  end if
end editPressed


-- Duplicate a requested car request
on clonePressed
  local tSelectedLine, theSelectedID, tDataA, tResult
  
  put the dghilitedline of group "dgWorkorders" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Line to edit."
  else
    put the uSelectedID of group "dgWorkorders" into theSelectedID
    put workorder.findOne(theSelectedID) into tDataA
    
    put uuid() into tDataA["id"]
    put workorder.create(tDataA) into tResult
    if tResult is a number then
      editRecord  theSelectedID
    else
      answer error tResult
    end if
  end if
end clonePressed


on editRecord pSelectedID
  set the cWorkorderUUID of card "Equipment Request" to pSelectedID
  
  // indicate this is a new record
  set the cIsNew of card "Equipment Request" to false
  
  go to card "Equipment Request"
end editRecord


on newPressed
  set the cWorkorderUUID of card "Equipment Request" to ""
  
  // indicate this is a new record
  set the cIsNew of card "Equipment Request" to true
  
  go to card "Equipment Request"
end newPressed


on deletePressed
  local theIndex, tId, tResult
  
  if (the dgHilitedIndex of group "dgWorkorders") is empty then 
    answer "Please select Equipment Request to Delete"
    exit deletePressed
  end if
  
  answer warning "Delete Current Equipment Request? (THIS CAN NOT BE UNDONE.)" with "Yes" or "No"
  if it is "no" then exit to top
  
  put the dgHilitedIndex of group "dgWorkorders" into theIndex
  put the uSelectedID of group "dgWorkorders" into tId
  
  put workorder.delete(tId) into tResult
  
  dispatch "DeleteIndex" to group "dgWorkorders" with theIndex
  
  set the dgfocus  of group "dgWorkorders" to true
  
  ## enable/disable delete and update buttons
  uiDisableButtons
  
  dispatch "ResetList" to group "dgWorkorders"
end deletePressed


/*
update db when characters are typed in field
*/
private command __updateConsigneeField pFieldname
  local tDataA, tResult
  
  if pFieldName is not among the items of kFIELD_NAMES then
    exit __updateConsigneeField
  end if
  
  put field pFieldname into tDataA[pFieldname]
  put field "id" into tDataA["id"]
  
  put consignee.update(tDataA) into tResult
end __updateConsigneeField


on textChanged
  __updateConsigneeField the short name of the target
end textChanged


private function __isNewRequestAllowed
  local tCarTypeCount
  local tSpotCount
  
  if sActiveModule is empty then return false
  
  // get total car counts
  put carType.count() into tCarTypeCount
  
  // get all spots for this module
  put spot.moduleCount(sActiveModule) into tSpotCount
  
  return the cIsNew of card "Edit Consignee" <> true and tCarTypeCount > 0 and tSpotCount > 0
end __isNewRequestAllowed
