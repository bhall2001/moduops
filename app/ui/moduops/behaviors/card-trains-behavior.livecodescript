script "card-trains-behavior"
on preOpenCard
  lock screen
end preOpenCard


on openCard
  local tTrainId, tSelectedIndex, tDataA
  local tTrainA
  
  put train.findMany() into tTrainA
  set the dgData of group "dgTrains" to train.addNames(tTrainA)
  
  ## Update buttons
  uiButtonState
  
  put the cTrainUUID of this card into tTrainId
  if tTrainId is not empty then
    dispatch "FindIndex" to group "dgTrains" with "id", tTrainId
    put the result into tSelectedIndex
    set the dgHilitedindex of group "dgTrains" to tSelectedIndex
  end if
  
  uiUpdateData
  
  unlock screen
  pass openCard
end openCard


on closeCard
  uiClearData
end closeCard


on setData theAction
  -----
  local theDataA,tRoute
  local tTrainLine,tTrainScroll,tActiveTrain
  -----
  
  local tTrains
  
  set the cursor to watch
  lock screen
  
  put the dgHilitedIndex of group "dgTrains" into tTrainLine
  put the dgVScroll of group "dgTrains" into tTrainScroll
  
  put the dgText of group "dgRoute" into tRoute
  put tRoute into theDataA["Route"]
  
  put theDataA into tTrains[tActiveTrain]
  set the cTrains of this stack to tTrains
  
  dispatch "uiUpdateData"
  
  set the dgHilitedIndex of group "dgTrains" to tTrainLine
  set the dgVScroll of group "dgTrains" to tTrainScroll
  
  unlock screen
  set the cursor to hand
end setData


on newPressed
  local tDataArray, tId, tResult
  
  // If there's at least 1 yard defined, then create a new train.
  if yard.exist() then      
    put uuid() into tId
    put tId into tDataArray["id"]
    put "**NEW**" into tDataArray["symbol"]
    put " " into tDataArray["origin"]
    put " " into tDataArray["destination"]
    put "350" into tDataArray["length"]
    
    put train.create(tDataArray) into tResult
    
    if tResult is not a number then
      answer tResult
      exit newPressed
    else
      editRecord tId
    end if
  else
    // No Yards defined. Display an error
    uiDisplayError "No Yards defined. Atleast 1 Yard must defined before creating a new train."
  end if
end newPressed


on routePressed
  local tSelectedLine, tSelectedID
  
  put the dghilitedline of group "dgTrains" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Train."
  else
    put the uSelectedID of group "dgTrains" into tSelectedID
    set the cTrainUUID of card "Route" to tSelectedID
    go to card "Route"
  end if
end routePressed


on editPressed
  local tSelectedLine, theSelectedID
  
  put the dghilitedline of group "dgTrains" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Train to edit."
  else
    put the uSelectedID of group "dgTrains" into theSelectedID
    editRecord theSelectedID
  end if
  
end editPressed


on editRecord pSelectedID
  set the cActiveTrain of card "Edit Train" to pSelectedID
  go to card "Edit Train"
end editRecord


on uiUpdateData
  
end uiUpdateData


on uiClearData
  set the dgText of group "dgTrains" to ""
end uiClearData


on deletePressed
  local theIndex, tId, tResult
  
  if (the dgHilitedIndex of group "dgTrains") is empty then 
    answer "Please select a Train to Delete"
    exit deletePressed
  end if
  
  answer warning "Delete Selected Train? (THIS CAN NOT BE UNDONE.)" with "Yes" or "No"
  if it is "no" then exit to top
  
  put the dgHilitedIndex of group "dgTrains" into theIndex
  put the uSelectedID of group "dgTrains" into tId
  
  put train.delete(tId) into tResult
  
  dispatch "DeleteIndex" to group "dgTrains" with theIndex
  
  set the dgfocus  of group "dgTrains" to true
  
  ## enable/disable delete and update buttons
  uiButtonState
  
  dispatch "ResetList" to group "dgTrains"
end deletePressed


-- Duplicate a requested car request
on clonePressed
  local tSelectedLine, theSelectedID, tDataA, tResult
  
  put the dghilitedline of group "dgTrains" into tSelectedLine
  if tSelectedLine is empty then
    answer info "Please select a Train to duplicate."
  else
    put the uSelectedID of group "dgTrains" into theSelectedID
    put train.findOne(theSelectedID) into tDataA
    
    put uuid() into tDataA["id"]
    put tDataA["symbol"] & "-" & random(1000) into tDataA["symbol"]
    put train.create(tDataA) into tResult
    if tResult is a number then
      editRecord  tDataA["id"]
    else
      answer error tResult
    end if
  end if
end clonePressed


on uiButtonState
  if ((the dghilitedline of group "dgTrains") is empty) and (not yard.exist()) then
    // disable train editting buttons
    set the disabled of card button "Edit" to true
    set the disabled of button "Route" to true
    set the disabled of button "Clone" to true
    set the disabled of button "Delete" to true
  else
    // enable train editting buttons
    set the disabled of button "Route" of card "Trains" to false
    set the disabled of card button "Edit" to false
    set the disabled of button "Clone" to false
    set the disabled of button "Delete" to false
  end if
end uiButtonState
