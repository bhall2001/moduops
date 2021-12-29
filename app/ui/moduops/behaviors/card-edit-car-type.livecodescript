script "card-edit-car-type"
constant kFIELD_NAMES = "id,description,short,code,length,remarks"

local sActiveID, sCarTypes


on openCard
  local tClass, tClassList, tCarType
  
  lock screen
  
  put getCarTypeID() into sActiveID
  
  put carType.findOne(sActiveId) into tCarType
  
  put tCarType["class"] into tClass
  
  put the text of button "class" into tClassList
  repeat for each line aLine in tClassList
    if char 1 of aLine = tClass then
      set the label of button "class" to aLine
      exit repeat
    end if
  end repeat
  
  put tCarType["id"] into field "id"
  set the label of button "era" to tCarType["era"]
  put tCarType["code"] into field "code"
  put tCarType["description"] into field "description"
  put tCarType["short"] into field "short"
  put tCarType["length"] into field "length"
  put tCarType["remarks"] into field "remarks"
  
  unlock screen
end openCard


on closeCard
  uiClearFields
end closeCard


on goCarTypeScreen
  go to card "Equipment Register"
end goCarTypeScreen

on cancelPressed
  if not the disabled of button "save" then
    answer  info "Would you like to save your changes?" with "No" or "Yes"
    if it is "Yes" then
      savePressed
      exit cancelPressed
    end if
  end if
  
  goCarTypeScreen
end cancelPressed


on savePressed
  local tResult
  
  put saveRecord() into tResult
  if tResult then
    goCarTypeScreen
  end if
end savePressed


on uiClearFields
  lock screen
  
  --  set the menuHistory of button "Class" to 1
  --  set the menuHistory of button "Era" to 1
  
  set the label of button "Class" to " "
  set the label of button "Era" to " "
  
  put "" into field "Code"
  put "" into field "Description" 
  put "" into field "Short"
  put "" into field "Length"
  put "" into field "Remarks"
  
  set the disabled of button "Save" to true
  unlock screen
end uiClearFields


function saveData
  local tCarType, tResult
  
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
  --  put char 1 of the label of button "Class" into tCarType["class"]
  --  put the label of button "Era" into tCarType["era"]
  --  put line 1 field "Code" into tCarType["code"] 
  --  put line 1 of field "Description" into tCarType["description"]
  --  put line 1 of field "Short" into tCarType["short"]
  --  put line 1 of field "Length" into tCarType["length"]
  --  put field "Remarks" into tCarType["remarks"]
  
  --set the cCarTypes of stack "Module Operations" to sCarTypes
  --  --  put updateRecord(sActiveID, "carType", tCarType) into tResult
  
  unlock screen
  return tResult
end saveData


command validateData
  return empty
  
  --  local tErrorIndex=0
  --  local tErrorA
  
  --  if field "Short" is "" then
  --    add 1 to tErrorIndex
  --    put "Please enter a Short Description" into tErrorA["errorText"][tErrorIndex]
  --  end if
  
  --  if field "Description" is "" then
  --    add 1 to tErrorIndex
  --    put  "Please enter a Description" into tErrorA["errorText"][tErrorIndex]
  --  end if
  
  --  if field "Length" is "" then
  --    add 1 to tErrorIndex
  --    put  "Please enter a Length" into tErrorA["errorText"][tErrorIndex]
  --  end if
  
  --  if tErrorIndex > 0 then
  --    return tErrorA for error
  --  end if
end validateData


private command __updateCarTypeField pFieldname
  local tDataA, tResult
  
  if pFieldName is not among the items of kFIELD_NAMES then
    exit __updateCarTypeField
  end if
  
  put field pFieldname into tDataA[pFieldname]
  put field "id" into tDataA["id"]
  
  put carType.update(tDataA) into tResult
  
end __updateCarTypeField


on textChanged
  __updateCarTypeField the short name of the target
end textChanged


on mainStackChanged
  
end mainStackChanged


/*
update classification from menu pick
*/
command classMenuPick pItemName
  local tResult, tDataA
  
  put field "id" into tDataA["id"]
  put char 1 of pItemName into tDataA["class"]
  put carType.update(tDataA) into tResult
end classMenuPick


/*
update era from menu pick
*/
command eraMenuPick pItemName
  local tResult, tDataA
  
  put field "id" into tDataA["id"]
  put pItemName into tDataA["era"]
  put carType.update(tDataA) into tResult
end eraMenuPick
