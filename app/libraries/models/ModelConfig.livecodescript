script "ModelConfig"
/*
data model for configuration parameters
*/

/*
returns the configuration value

param: pName: string: name of configuration parameter
returns: array | value:
*/
function config.get pName
  local tConfigA, tParamA
  
  if pName is empty then
    
    # get all the configurations
    put "id" into tParamA["dictionary"]
    put datalayer.select("config", tParamA) into tConfigA
    
    # return the result
    return tConfigA
  end if
  
  put pName into tParamA["id"]
  put datalayer.get("config", tParamA) into tConfigA
  return tConfigA["value"]
  
end config.get


/*
Sets the value of a configuration parameter
*/
function config.set pName, pValue
  local tDataA, tResult, tIt
  
  if pName is empty then return "No Configuration Name provide" for error
  
  put pName into tDataA["id"]
  put pValue into tDataA["value"]
  
  datalayer.where "id", tDataA["id"]
  put dataLayer.update("config", tDataA) into tResult
  
  # if no rows updated, we need to create the row
  if tResult = 0 or tResult is empty then
    put datalayer.create("config", tDataA) into tResult
  end if
  
  # return the result
  return tResult
  
end config.set


/*
delete config value

param: pName: string: configuration parameter to delete
*/
function config.delete pName
  if pName is empty then
    return "Error: config name required in config.delete"
  end if
  
  return datalayer.deleteById("config", pName)
end config.delete


/*
Reset config data store
*/
function config.deleteAll
  return datalayer.deleteAll("config")
end config.deleteAll
