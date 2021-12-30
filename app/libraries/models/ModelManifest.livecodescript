script "ModelManifest"
/**
create a new manifest

Example:
put manifest.create(tManifestA) into tResult

Parameters:
tManifestA array of the new manifest data items

Returns:
number | string record count created or error string

**/
function manifest.create @pDataA
  local tDataA, tResult
  
  put pDataA into tDataA
  
  if tDataA["id"] is empty then
    put uuid() into tDataA["id"]
  end if
  
  put datalayer.create("manifest", tDataA) into tResult
  
  return tResult
end manifest.create


/**
Summary
Updates data with an given array
*/
function manifest.update pDataA
  local tResult
  
  if pDataA["id"] is empty then
    uiDisplayError "Manifest id is not valid.", param(0)
    exit to top
  end if
  
  datalayer.where "id", pDataA["id"]
  put datalayer.update("manifest", pDataA) into tResult
  
  if the result is not a number then
    uiDisplayError tResult, param(0)
  end if
  
  return tResult
end manifest.update


/*
return a single item by id in database
*/
function manifest.findOne pId
  local tDataA
  
  if pId is empty then
    throw "ERROR: id required to to find manifest"
  end if
  
  datalayer.where "id", pId
  
  put datalayer.select("manifest") into tDataA
  
  // when no array, return the entire result
  if tDataA is not an array then
    return tDataA
  end if
  
  // return first item of result array
  return tDataA[1]
end manifest.findOne


/**
select records from database based on parameters provided

Example:
put manifest.findMany(tCriteriaA) into tManifestA

Description:
using an array of criteria, selects records from the database

Parameters:
pCriteriaA array of fields/values to select on

Returns:
array of manifest records found in database
**/
function manifest.findMany pCriteriaA
  local tTeamA
  
  repeat for each key aCriteria in pCriteriaA
    datalayer.where aCriteria, pCriteriaA[aCriteria]
  end repeat
  
  return datalayer.select("manifest", pCriteriaA)
end manifest.findMany


/**
detele manifest

Example:
get manifest.delete(tId)

Description:
deletes a manifest record from the database.
NOTICE: if no id is given nothing is deleted

Parameters:
pId string manifest id

Returns:
integer number of records deleted

Tags: tags
**/
function manifest.delete pId
  local tResult
  
  if pId is empty then
    return 0
  end if
  
  return datalayer.deleteById("manifest", pId)
end manifest.delete


/*
delete manifest by train id
*/
function manifest.deleteByTrainId pTrainId
  if pTrainID is empty then return empty
  
  local tParamA, tResult
  put pTrainId into tParamA["trainId"]
  
  put datalayer.delete("manifest", tParamA) into tResult
  
  if tResult is not a number then
    put "ERROR: " & tResult & return after message
  end if
end manifest.deleteByTrainId
