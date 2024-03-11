script "validation"
function isValid pCardName
  local tMessage
  
  switch pCardName
    case "Edit Module/Town"
      if not (field "name" is not empty and field "short_name" is not empty) then
        put  "Required data is missing." into tMessage
      end if
      break
    case "Edit Consignee"
      if not (field "name" is not empty) then
        put "Required data is missing." into tMessage
      end if
      break
    case "Equipment Request"
      if not (field "cpw" is not empty) then
        put "Required data is missing." into tMessage
      end if
      break
    case "Edit Drop Zone"
      if field "spot" is empty or field "length" is not a number then
        put "Required data is missing." into tMessage
      end if
      break
    case "Edit Train"
      if field "symbol" is empty or field "trainLength" is not a number \
            or the label of button "origin" is empty \
            or the label of button "origin" is " " \
            or the label of button "destination" is empty \
            or the label of button "destination" is " " then
        put "Required data is missing." into tMessage
      end if
      break
    case "Edit Car Type"
      switch true
        case field "description" is ""
          put "Description is required." into tMessage
          break
        case field "short" is ""
          put "Short description is required." into tMessage
          break
        case field "length" is ""
          put "Length is required." into tMessage
          break
        case field "length" < 1
          put "Length must be greater than 0." into tMessage
          break
      end switch
      break
    default
      return true
  end switch
  
  if tMessage is not empty then
    beep
    answer error return & tMessage titled "Validation Error"
    return false
  end if
  
  return true
end isValid
