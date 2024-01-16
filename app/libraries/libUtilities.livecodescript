script "libUtilities"
local sWorldRegionA

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
returns whether app is running in dev or production.

note: there are 2 modes for dev.
return local => use localhost nextjs project for api calls
return dev => use dev.www.ondeckmanager.com for api calls

to switch simply change the return value for isDev

*/
function getEnvironment
  if isDev() then return "local" // make this "dev" to use dev.www.ondeckmanager.com
  return "production"
end getEnvironment



/*
updates the recent menu with the given file (full path to file)
*/
command updateLayoutRecentMenu pDataFile
  local tRecentFilesMenu
  local tFileMenu, tNewFileMenu
  local tFoundMenuLine
  
  // if no data file provided, skip setting the recently opened preference
  if pDataFile is not empty then
    # fileSystemAddToRecentlyOpened pCategory, pFile, pTag, pSecurityBookmark
    fileSystemAddToRecentlyOpened "layouts", pDataFile, empty, empty
  end if
  
  // get all the recently opened files from storage
  put fileSystemRecentlyOpenedMenuText("layouts") into tRecentFilesMenu
  
  // get the current text of the File menu. Note: in Livecode Menus are just
  // a special kind of button. The text of the button contains the actual menu items.
  put the text of button "File" into tFileMenu
  
  // Rebuild the file menu to a new menu
  // first we add all the existing File menu items upto and including the recent file menu
  put the lineOffset("Open Recent Layout",tFileMenu) into tFoundMenuLine
  put line 1 to tFoundMenuLine of tFileMenu & return into tNewFileMenu
  
  // add in all the recent files to the recent menu item as a sub menu.
  // note: to make a sub menu you preceed the menuitem with a tab.
  if tRecentFilesMenu is not empty then
    put tRecentFilesMenu after tNewFileMenu
  else
    // handle case when there are no recent items
    put tab & "No recent layouts." after tNewFileMenu
  end if
  
  // now save the starting location of everything after the recent menu.
  // these items will be added to the end of the new file menu
  put the lineOffset("Convert...", tFileMenu) into tFoundMenuLine
  
  put return & line tFoundMenuLine to (the number of lines of tFileMenu) of tFileMenu after tNewFileMenu
  
  // new menu built, now we set the text which updates the File menu to include the most
  // recent recent items
  set the text of button "File" to tNewFileMenu
end updateLayoutRecentMenu


/*
opens the most recent layout file. this is used when the app first launches
to reload the prior layout file.
*/
command openMostRecentLayoutFile
  local tRecentFiles
  
  set the itemDelimiter to "|"
  
  // get all the recently opened files from storage
  put fileSystemRecentlyOpenedMenuText("layouts") into tRecentFiles
  
  if the number of lines of tRecentFiles = 0 then exit openMostRecentLayoutFile
  
  dispatch "openLayoutFile" to stack "Module Operations" with URLDecode(item 2 of line 1 of tRecentFiles), true
  
end openMostRecentLayoutFile



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



command initWorldRegionA
  local tSourceA
  local tWorldRegionA
  
  put  JSONToArray(the cWorldRegions of stack "Module Operations") into tSourceA
  
  repeat for each element aCountry in tSourceA
    if aCountry["region"] is "Antarctic" then
      put "Antarctic" into aCountry["subRegion"]
    end if
    put aCountry["name"] into tWorldRegionA[aCountry["region"]][aCountry["subRegion"]][aCountry["name"]["common"]]
  end repeat
  
  put tWorldRegionA into sWorldRegionA
end initWorldRegionA


function getWorldRegionA
  return sWorldRegionA
end getWorldRegionA
