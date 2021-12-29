script "card-equipment-register-behavior"
on preOpenCard
  lock screen
end preOpenCard


on openCard
  local tTemp
  
  set the dgData of group "dgCarTypes" to carType.findMany()
  
  dispatch "SortDataByKey" to group "dgCarTypes" with \
        "length", "international", "ascending", false
  dispatch "SortDataByKey" to group "dgCarTypes" with \
        "description", "international", "ascending", false
  dispatch "SortDataByKey" to group "dgCarTypes" with \
        "class", "international", "ascending", false
  
  
  ## Update buttons based on conditions of car types
  uiButtonState
  
  ## set the intial focus to the table of car types
  ##set the dgfocus of group "dgCarTypes" to true
  
  unlock screen
  
  ##pass openCard
end openCard


on uiViewRecordOfID theDataA
  put theDataA[2] into card field "Description"
end uiViewRecordOfID


on editPressed
  local tSelectedLine, theSelectedID
  
  put the dghilitedline of group "dgCarTypes" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Car Type to edit."
  else
    put the uSelectedID of group "dgCarTypes" into theSelectedID
    editRecord theSelectedID
  end if
end editPressed


on editRecord pSelectedID
  setCarTypeID(pSelectedID)
  go to card "Edit Car Type"
end editRecord


on uiButtonState
  lock screen
  if (the dghilitedline of group "dgCarTypes") is empty  then
    set the disabled of button "Delete" to true
    set the foregroundColor of button "Delete" to ""
    set the disabled of button "Clone" to true
    set the foregroundColor of button "Clone" to ""
    set the disabled of button "Edit" to true
    set the foregroundColor of button "Edit" to ""
  else
    set the disabled of button "Delete" to false
    set the foregroundColor of button "Delete" to "white"
    set the disabled of button "Clone" to false
    set the foregroundColor of button "Clone" to "white"
    set the disabled of button "Edit" to false
    set the foregroundColor of button "edit" to "white"
  end if
  unlock screen
end uiButtonState


on closeCard
  ## Update buttons based on conditions of car types
  uiButtonState
  
  set the dgText of group "dgCarTypes" to ""
end closeCard


on newPressed
  local tDataA, tCarTypes, tUUID, tTemp, tResult
  
  --
  -- setup a new record with dummy data for required elements
  put uuid() into tUUID
  put tUUID into tDataA["id"]
  put "New Car Type" into tDataA["description"]
  put "New" into tDataA["short"]
  put "0" into tDataA["length"]
  
  -- insert the dummy record into the carType table
  put carType.create(tDataA) into tResult
  
  -- now edit the record as if it is a real record
  editRecord tUUID
end newPressed


on deletePressed
  local theIndex, tId, tResult
  
  if (the dgHilitedIndex of group "dgCarTypes") is empty then 
    answer "Please select Equipment to Delete"
    exit deletePressed
  end if
  
  answer warning "Delete Current Equipment? (deletes all equipment requests as well. THIS CAN NOT BE UNDONE.)" with "Yes" or "No"
  if it is "no" then exit to top
  
  put the dgHilitedIndex of group "dgCarTypes" into theIndex
  put the uSelectedID of group "dgCarTypes" into tId
  
  put carType.delete(tId) into tResult
  
  dispatch "DeleteIndex" to group "dgCarTypes" with theIndex
  
  set the dgfocus  of group "dgCarTypes" to true
  
  ## enable/disable delete and update buttons
  uiButtonState
  
  dispatch "ResetList" to group "dgCarTypes"
end deletePressed


-- Duplicate a Car Type
on clonePressed
  local tSelectedLine, theSelectedID, tDataA, tResult
  
  put the dghilitedline of group "dgCarTypes" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select Equipment to Copy."
  else
    put the uSelectedID of group "dgCarTypes" into theSelectedID
    put carType.findOne(theSelectedID) into tDataA
    
    put uuid() into tDataA["id"]
    put carType.create(tDataA) into tResult
    
    if tResult is a number then
      editRecord tDataA["id"]
    else
      answer error tResult
    end if
  end if
end clonePressed
