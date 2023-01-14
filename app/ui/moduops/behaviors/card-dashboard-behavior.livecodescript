script "card-dashboard-behavior"
on openCard
  local tTemp, tStatsA
  lock screen
    
  put "module,Modules/Towns:" & return & \
        "carType,Rollingstock:" & return & \
        "consignee,Consignees:" & return & \
        "spot,Drop Zones:" & return & \
        "workorder,Car Requests:" & return & \
        "train,Trains:" into tStatsA
  
  set the itemDelimiter to comma
  
  if the cDataFile of stack "Module Operations" is not empty then
    
    // gather counts
    put module.count() into tTemp["module"]
    put carType.count() into tTemp["carType"]
    put consignee.count() into tTemp["consignee"]
    put spot.count() into tTemp["spot"]
    put workorder.count() into tTemp["workorder"]
    put train.count() into tTemp["train"]
  else
    put 0 into tTemp["module"]
    put 0 into tTemp["carType"]
    put 0 into tTemp["consignee"]
    put 0 into tTemp["spot"]
    put 0 into tTemp["workorder"]
    put 0 into tTemp["train"]
  end if
  
  
  repeat for each line aStat in tStatsA
    put item 2 of aStat && tTemp[item 1 of aStat] into field (item 1 of aStat) of card "Dashboard" of stack "Module Operations"
  end repeat
  
  _uiEnableNavigation
  
  unlock screen
  pass openCard
end openCard


on preOpenCard    
  put myVersion() into field "myVersion" of card "Dashboard" of stack "Module Operations"
  
_uiEnableNavigation
end preOpenCard


on openStack
  set the dgProp[ "dim on focusOut" ] of group "dgTrains" of card "Trains" to false
  set the dgProp[ "dim on focusOut" ] of group "dgCarTypes" of card "Equipment Register" to false
  set the dgProp[ "dim on focusOut" ] of group "dgConsignees" of card "Modules/Towns" to false
  set the dgProp[ "dim on focusOut" ] of group "dgSpots" of card "Modules/Towns" to false
  set the dgProp[ "dim on focusOut" ] of group "dgModules" of card "Modules/Towns" to false
  set the dgProp[ "dim on focusOut" ] of group "dgSpots" of card "Equipment Request" to false
  set the dgProp[ "dim on focusOut" ] of group "dgCarTypes" of card "Equipment Request" to false
  set the dgProp[ "dim on focusOut" ] of group "dgTrains" of card "Train Sequence" to false
  set the dgProp[ "dim on focusOut" ] of group "dgSequence" of card "Train Sequence" to false
  set the dgProp[ "dim on focusOut" ] of group "dgRoute" of card "Route" to false
  
  dispatch "mouseUp" to button "Dashboard"
  
  pass openStack
end openStack


private command _uiEnableNavigation
  local tHasFile
  
  // disable/enable buttons if there is a file open
  put the cDataFile of stack "Module Operations" is not empty into tHasFile
  
  set the visible of graphic "navigationPreferences" to not tHasFile
  set the visible of graphic "navigationEquipmentRegister" to not tHasFile
  set the visible of graphic "navigationModules" to not tHasFile
  set the visible of graphic "navigationTrains" to not tHasFile
  set the visible of graphic "navigationTrainlists" to not tHasFile
  set the visible of graphic "dashboardModules" to not tHasFile
  set the visible of graphic "dashboardDropZones" to not tHasFile
  set the visible of graphic "dashboardRollingstock" to not tHasFile
  set the visible of graphic "dashboardCarRequests" to not tHasFile
  set the visible of graphic "dashboardConsignees" to not tHasFile
  set the visible of graphic "dashboardTrains" to not tHasFile
end _uiEnableNavigation


