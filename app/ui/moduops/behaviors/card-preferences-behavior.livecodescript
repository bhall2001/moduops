script "card-preferences-behavior"
constant kFIELD_NAMES = "setup_name,day,year,header,footer"


on openCard
  local tConfigA
  
  lock screen
  
  put config.get("setup_name") into field "setup_name"
  set the label of button "month" to config.get("month")
  put config.get("day") into field "day"
  put config.get("year") into field "year"
  put config.get("header") into field "header"
  put config.get("footer") into field "footer"
  
  unlock screen
end openCard


on monthSelected pMenuItem
  local tResult
  
  put config.set("month", pMenuItem) into tResult
end monthSelected


/*
update db when characters are typed in field
*/
private command __updateConfigField pFieldname
  local tResult
  
  if pFieldName is not among the items of kFIELD_NAMES then
    exit __updateConfigField
  end if
  
  put config.set(pFieldname, field pFieldname) into tResult
  
end __updateConfigField


on textChanged
  __updateConfigField the short name of the target
end textChanged
