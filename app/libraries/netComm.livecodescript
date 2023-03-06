script "netComm"
constant HOST_NAME = "www.ondeckmanager.com"
constant DEV_PREFIX = "dev."
constant USE_LOCALHOST = "localhost:8888"


function requestHeaders
  local tHeaders
  
  ##put "Content-Type: application/lc.array" & return into tHeaders
  ##put "Accept: application/lc.array" & return after tHeaders
  put "Content-Type: application/json" & return into tHeaders
  put "Accept: application/json" & return after tHeaders
  put "Cache-Control: no-cache" & return after tHeaders
  
  return tHeaders
end requestHeaders


/*
Initialize
*/
/*
determine if we are able to access the server. call /ping endpoint. 
If there's a 200 response return true otherwise false
*/
function net.isConnected
  local tStatus
  local tUrl
  local tHeaders
  local tResult
  local tBytes
  
  put net.hostUrl() & "/ping" into tUrl
  put tsNetHeadSync(tURL, tHeaders, tStatus, tBytes ) into tResult
  
  return (tStatus is 200)
end net.isConnected


/*
returns host url
*/
function net.hostUrl
  local tUrl, tEnv
  
  put getEnvironment() into tEnv
  
  switch tEnv
    case "local"
      put "http://" & USE_LOCALHOST into tUrl
      break;
    case "production"
      put "https://" & HOST_NAME into tUrl
      break
    default
      put "https://" & DEV_PREFIX & HOST_NAME into tUrl
      break
  end switch
  
  return tUrl
end net.hostUrl


