script "card-layout-behavior"

constant kFIELDS = "name,location,organization,trainlistHeader,runChief,dccChief,opsChief,endDate,startDate"

on preOpenCard
  set the layerMode of group "layoutForm" to "scrolling"
  
  // clear ui data
  __uiClearData
  
  // load ui data
  __uiLoadData
  
end preOpenCard


/*
When a field closes, save the data to the database
*/
on closeField
  put return & the short name of the target & ": " & the text of the target after message
  get config.set(the short name of the target, the text of the target)
end closeField



private command __uiLoadData
  repeat for each item aField in kFields
    put config.get(aField) into field aField
  end repeat
end __uiLoadData


private command __uiClearData
  repeat for each item aField in kFields
    put "" into field aField
  end repeat
  
  set the visible of widget "startDatePicker" of group "startDate" of group "layoutForm" of me to false
  set the visible of widget "endDatePicker" of group "endDate" of group "layoutForm" of me to false
end __uiClearData

/*
handle scrolling of group when scroll wheel used on mouse
*/
on rawKeyDown pKey
  switch pKey
    // scrolling down
    case 65308
      set the vScroll of group "layoutForm" of me to the vScroll of group "layoutForm" of me + 20
      break
      // scrolling up
    case 65309
      set the vScroll of group "layoutForm" of me to the vScroll of group "layoutForm" of me - 20
      break
    default 
      pass rawKeyDown
  end switch
end rawKeyDown
