script "commonLib"
function rand25
  return random(4) = 1
end rand25


function rand50  
  return random(2) = 1
end rand50


function rand75
  return random(100) <= 75
end rand75

/*
Shoud the Consignee be scheduled again to favor current selected

Parameters:
pCPW integer for Cars per week
Returns:
boolean
*/
function reuseConsignee pCPW
  local tFavor
  
  put config.get("favorSlider") into tFavor
  
  // of favor scale not visible don't use it
  if tFavor is not a number then return false
  
  switch tFavor
    case 1
      return false
      break
    case 2
      return rand25()
      break
    case 3
      return rand50()
      break
    case 4
      return rand75()
      break
    case 5
      return true
      break
    default
      return false
  end switch
end reuseConsignee
