script "card-equipment-report-behavior"
on preOpenCard
  lock screen
end preOpenCard


on openCard
  lock screen
  // load Car Type data to UI
  loadCarTypeData
  
  // update layout name field
  put config.get("name") into field "layoutName"
  
  unlock screen
end openCard


on closeCard
  set the dgText of group "dgEquipmentRegister" to ""
end closeCard


/**
* Load Car Type data from DB to UI
*/
on loadCarTypeData
  local tDataA
  
  // Reset Active DB Record and Get carType Table
  put carType.findMany() into tDataA
  
  if tDataA is an array then
    // update the UI with the results of the query
    set the dgData of group "dgEquipmentRegister" to tDataA
    
    // set the intial sort by length then class
    set the dgProps["sort by column"] of group "dgEquipmentRegister" to "length"
    set the dgProps["sort by column"] of group "dgEquipmentRegister" to "class"
  end if
end loadCarTypeData
