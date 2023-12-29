script "libUtilities"
function htmlGetSync pUrl
  local htmlData
  local tHeaders, tResult, tBytes, tRecvHeaders
  
  // get headers
  put requestHeaders() into tHeaders
  
  put tsNetGetSync(pURL, tHeaders, tRecvHeaders, tResult, tBytes) into htmlData
  
  return htmlData
end htmlGetSync


/*
returns if we are in dev or not
*/
function isDev
  return the environment is "development"
  --  return false // use to access prod resources in ide
  --  return true // use to access online dev environment in standalone
end isDev


/*
returns wether running in dev or pproduction.

note: there are 2 modes for dev.
return local => use local nextjs project for api calls
return dev => use dev.www.ondeckmanager.com for api calls

to switch simply change the return value for isDev

*/
function getEnvironment
  if isDev() then return "local"
  return "production"
end getEnvironment



/*
updates the recent menu with the given file (full path to file)
*/
command updateLayoutRecentMenu pDataFile
  local tRecentFilesMenu
  local tFileMenu, tNewFileMenu
  local tFoundMenuLine
  
  if pDataFile is not empty then
    # fileSystemAddToRecentlyOpened pCategory, pFile, pTag, pSecurityBookmark
    fileSystemAddToRecentlyOpened "layouts", pDataFile, empty, empty
  end if
  
  put fileSystemRecentlyOpenedMenuText("layouts") into tRecentFilesMenu
  # Now add tRecentFilesMenu to your File menu...
  put the text of button "File" into tFileMenu
  
  put the lineOffset("Open Recent Layout",tFileMenu) into tFoundMenuLine
  put line 1 to tFoundMenuLine of tFileMenu & return into tNewFileMenu
  
  if tRecentFilesMenu is not empty then
    put tRecentFilesMenu after tNewFileMenu
  else
    put tab & "No recent layouts." after tNewFileMenu
  end if
  
  put the lineOffset("Convert...", tFileMenu) into tFoundMenuLine
  
  put return & line tFoundMenuLine to (the number of lines of tFileMenu) of tFileMenu after tNewFileMenu
  
  set the text of button "File" to tNewFileMenu
end updateLayoutRecentMenu



/*
delete all files in recent layouts
*/
command clearLayoutRecentMenu
  local tRecentLayoutFiles
  
  set the itemDelimiter to "|"
  put fileSystemRecentlyOpenedMenuText("layouts") into tRecentLayoutFiles
  
  repeat for each line aFile in tRecentLayoutFiles
    fileSystemRemoveFromRecentlyOpened "layouts", URLDecode(item 2 of aFile)
  end repeat
  
  put fileSystemRecentlyOpenedMenuText("layouts") into tRecentLayoutFiles
  
  updateLayoutRecentMenu
  
end clearLayoutRecentMenu
