script "libUI"
/**
Summary
Display a generic error dialog to user.

Parameters
pError string error message to display
pHandler string optional Handler name for display
*/
command uiDisplayError pError, pHandler
  local pErrorMsg = "Error: "
  
  if pError is not empty then
    put pError after pErrorMsg
  else
    put "Oops! Something has gone terribly wrong..." after pErrorMsg
  end if
  
  if pHandler is not empty then
    put " (" &pHandler & ") " after pErrorMsg
  end if
  
  put pErrorMsg
  answer error pErrorMsg
end uiDisplayError


/**
Update ModuOps window title

Example:
updateWindowTitle tFilepath

Description:
Set the ModuOps window title to the filepath passed and Module Operations

Parameters:
pFilePath string path to a file

**/
command updateWindowTitle pFilepath
  local tWindowTitle
  
  if pFilePath is not empty then
    set the itemDelimiter to "/"
    put the last item of pFilePath && "- " into tWindowTitle
  end if
  
  put "Module Operations" after tWindowTitle 
  
  set the label of stack "Module Operations" to tWindowTitle
end updateWindowTitle



/*
return the menu item number from a menu name and string

parameters
pMenuName string the menu name
pMenuItemName string menu item name

returns integer the menu item number
*/
function getMenuItemNumber pMenuName, pMenuItemName
  local tMenu
  local tResult
  
  put the text of button pMenuName into tMenu
  
  repeat with i = 1 to number of lines of tMenu
    if line i of tMenu contains pMenuItemName then
      put i into tResult
      exit repeat
    end if
  end repeat
  
  return tResult
end getMenuItemNumber
