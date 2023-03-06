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
