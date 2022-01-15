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
