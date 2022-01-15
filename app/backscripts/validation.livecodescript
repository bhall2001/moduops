script "validation"
function isValid pCardName
  
  switch pCardName
    case "Edit Module/Town"
      if not (field "name" is not empty and field "short_name" is not empty) then
        beep
        answer error "Required data is missing."
        return false
      end if
      break
    case "Edit Consignee"
      if not (field "name" is not empty) then
        beep
        answer error "Required data is missing."
        return false
      end if
      break
    case "Equipment Request"
      if not (field "cpw" is not empty) then
        beep
        answer error "Required data is missing."
        return false
      end if
      break
    case "Edit Drop Zone"
      if field "spot" is empty or field "length" is not a number then
        beep
        answer error "Required data is missing."
        return false
      end if
      break
    case "Edit Train"
      if field "symbol" is empty or field "trainLength" is not a number \
            or the label of button "origin" is empty \
            or the label of button "origin" is " " \
            or the label of button "destination" is empty \
            or the label of button "destination" is " " then
        beep
        answer error "Required data is missing."
        return false
      end if
      break
    default
      return true
  end switch
  return true
end isValid
