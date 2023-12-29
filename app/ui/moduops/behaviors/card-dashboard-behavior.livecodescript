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
  set cursor to watch
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
  
  
  // limit recent menu to last 10 items
  fileSystemSetMaxRecentFiles 10
  
  // build the recent file menu
  updateLayoutRecentMenu
  
  get net.isConnected()
  
  dispatch "mouseUp" to button "Dashboard"
  
  set cursor to arrow
  pass openStack
end openStack


private command _uiEnableNavigation
  local tHasFile
  
  // disable/enable buttons if there is a file open
  put the cDataFile of stack "Module Operations" is not empty into tHasFile
  
  set the visible of graphic "navigationPreferences" to not tHasFile
  set the visible of graphic "dashboardModules" to not tHasFile
  
  // there is a separate disable graphic over Operations Session menu on dashboard.
  // this feature is not live yet. In order to prevent a doubling of the 
  // grey out on the menu, this graphic needs to do the opposite of the other 
  // hiding graphics.
  set the visible of graphic "operationsSession" to tHasFile
  
end _uiEnableNavigation



/*
check if this version is valid
*/
command __checkVersion
  local tVersion
  local tHeaders
  local tUrl
  local tResponse
  local tExpired
  local tTemp
  
  if not net.isConnected() then
    exit __checkVersion
  end if
  
  // first check if this is expire version
  put myVersion() into tVersion
  
  put net.hostUrl() & "/api/versionCheck/moduops/" & tVersion into tUrl
  
  put htmlGetSync(tUrl) into tResponse
  
  // true response means this is the current version
  if tResponse contains "true" then
    exit __checkVersion
  end if
  
  // if we get here there's a newer version of moduops ready to download
  answer info "A new version of ModuOps is ready to download at www.moduops.com."
  
end __checkVersion


