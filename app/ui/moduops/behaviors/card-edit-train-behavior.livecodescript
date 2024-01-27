script "card-edit-train-behavior"
local sActiveTrain, sYardA


function activeTrain
  return the cActiveTrain of this card
end activeTrain


on preOpenCard
  lock screen
  buildYardMenu
  
  set the visible of button id 2628160 to the cIsNew of card "Edit Train"
  
  if the cIsNew of card "Edit Train" is true then
    set the label of button "done" of card "Edit Train" to "Create"
  else
    set the label of button "done" of card "Edit Train" to "Done"
  end if
  
  // update the length unit
  put "(" & config.get("lengthUnit") & ")" into field "lengthUnit"
  put "(" & config.get("lengthUnit") & ")" into field "minLengthUnit"
  
end preOpenCard


/*
* Creates the array of available yards from the Spots Table
*/
command buildYardMenu
  local tYardA, tYardNames
  
  put empty into sYardA
  put yard.findMany() into tYardA
  repeat for each key aKey in tYardA
    if tYardA[akey]["active"] then
      put tYardA[aKey]["id"] into sYardA[tYardA[aKey]["spot"]]
    end if
  end repeat
  
  get the keys of sYardA
  --sort lines of it by sYardA[each]
  sort lines of it
  put it into tYardNames
  set the text of button "origin" to tYardNames
  set the text of button "destination" to tYardNames
end buildYardMenu


on preOpenCard
  uiClear
end preOpenCard


on openCard
  local tTrainA
  
  ##lock screen
  
  put activeTrain() into sActiveTrain
  
  put train.findOne(sActiveTrain) into tTrainA
  
  uiUpdate tTrainA
  
  // update layout name field
  put config.get("name") into field "layoutName"
  
  unlock screen
end openCard


on uiUpdate pDataA
  put pDataA["id"] into field "id"
  put pDataA["symbol"] into field "symbol"
  put pDataA["length"] into field "trainLength"
  put pDataA["minLength"] into field "minLength"
  put pDataA["name"] into field "name"
  put pDataA["note"] into field "note"
  put pDataA["overview"] into field "overview"
  put pDataA["instructions"] into field "instructions"
  put pDataA["terminationInstructions"] into field "terminationInstructions"
  put pDataA["orders"] into field "orders"
  put pDataA["limitModules"] into field "limitModules"
  
  // set train origin and destinations
  set the label of button "origin" to yard.nameById(pDataA["origin"])
  set the label of button "destination" to yard.nameById(pDataA["destination"])
  
  // set the train type menu
  if (pDataA["type"] is empty) or (pDataA["type"] = "type") then
    put " " into pDataA["type"]
  end if
  set the label of button "type" to pDataA["type"]
end uiUpdate


on uiClear
  put "" into field "symbol"
  put "" into field "trainLength"
  put "" into field "minLength"
  put "" into field "name"
  put "" into field "note"
  put "" into field "overview"
  put "" into field "instructions"
  put "" into field "terminationInstructions"
  put "" into field "orders"
  put "" into field "limitModules"
  
  // set train origin and destinations
  set the label of button "origin" to " "
  set the label of button "destination" to " "
  
  set the label of button "type" to " "
end uiClear


on goTrainScreen
  dispatch "mouseUp" to button "Trains"
end goTrainScreen


on savePressed
  local tResult
  
  put saveTrainData() into tResult
  if tResult then
    goTrainScreen
  end if
end savePressed


function saveTrainData
  local tResult
  
  lock screen
  
  // Validate data entry. If failure, show error message and exit.
  validateData
  
  // Check validation result
  if the result is not empty then
    put the Result into tResult
    answer error tResult["errorText"][1]
    exit to top
  end if
  
  local tTemp, tOriginId, tDestinationId
  local tDataA, tCarTypeA, tLimitTypes
  
  put the label of button "origin" into tTemp
  put sYardA[tTemp] into tOriginId
  
  put the label of button "destination" into tTemp
  put sYardA[tTemp] into tDestinationId
  
  ## Move data entry fields into an array
  put field "id" into tDataA["id"]
  put line 1 field "symbol" into tDataA["symbol"] 
  
  // store Origin and Destination IDs
  put tOriginId into tDataA["origin"]
  put tDestinationId into tDataA["destination"]
  
  // store train type
  put the label of button "type" into tDataA["type"]
  
  put field "trainLength" into tDataA["length"]
  put field "minLength" into tDataA["minLength"]
  put line 1 of field "name" into tDataA["name"]
  put line 1 of field "note" into tDataA["note"]
  put field "overview" into tDataA["overview"]
  put field "instructions" into tDataA["instructions"]
  put field "terminationInstructions" into tDataA["terminationInstructions"] 
  put field "orders" into tDataA["orders"]
  put field "limitModules" into tDataA["limitModules"]
  
  put train.update(tDataA) into tResult
  
  unlock screen
  return tResult
end saveTrainData


command validateData
  local tErrorIndex, tErrorA
  
  // initialize the error index
  put 1 into tErrorIndex
  
  if field "symbol" is "" then
    put "Please enter a Symbol" into tErrorA["errorText"][tErrorIndex]
    add 1 to tErrorIndex
  end if
  
  if the label of button "origin" is " " then
    put "Please enter an Origin" into tErrorA["errorText"][tErrorIndex]
    add 1 to tErrorIndex
  end if
  
  if the label of button "destination" is " " then
    put "Please enter an Destination" into tErrorA["errorText"][tErrorIndex]
    add 1 to tErrorIndex
  end if
  
  if field "trainLength" is "" then
    put "Please enter a Length" into tErrorA["errorText"][tErrorIndex]
    add 1 to tErrorIndex
  end if
  
  if field "trainLength" is not a number then
    put "Length must be a number" into tErrorA["errorText"][tErrorIndex]
    add 1 to tErrorIndex
  end if
  
  if tErrorIndex > 1 then
    return tErrorA for error
  end if
end validateData


on closeCard
  local tId
  
  // if this is a new train, we need to delete it
  if the cIsNew of card "Edit Train" is true then
    put field "id" into tId
    get train.delete(tId)
    exit closeCard
  end if
  
  if not isValid(the short name of this card) then
    exit closeCard
  end if
  
  if not saveTrainData() then
    go to this card
    exit closeCard
  end if
end closeCard


command uiTrainScreen
  local tResult
  
  put saveTrainData() into tResult
  go to card "Trains"
end uiTrainScreen

