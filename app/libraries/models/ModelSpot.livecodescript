script "ModelSpot"
/**
create a new spot

Example:
put spot.create(tSpotA) into tResult

Parameters:
tSpotA array of the new spot data items

Returns:
number | string record count created or error string

**/
function spot.create @pDataA
  local tDataA, tResult
  
  put pDataA into tDataA
  
  if tDataA["id"] is empty then
    put uuid() into tDataA["id"]
  end if
  
  put datalayer.create("spot", tDataA) into tResult
  
  return tResult
end spot.create


/**
Summary
Updates data with an given array
*/
function spot.update pDataA
  local tResult
  
  if pDataA["id"] is empty then
    uiDisplayError "Spot id is not valid.", param(0)
    exit to top
  end if
  
  datalayer.where "id", pDataA["id"]
  put datalayer.update("spot", pDataA) into tResult
  
  if the result is not a number then
    uiDisplayError tResult, param(0)
  end if
  
  return tResult
end spot.update


/*
return a single item by id in database
*/
function spot.findOne pId
  local tDataA
  
  if pId is empty then
    throw "ERROR: id required to to find spot"
  end if
  
  datalayer.where "id", pId
  
  put datalayer.select("spot") into tDataA
  
  // when no array, return the entire result
  if tDataA is not an array then
    return tDataA
  end if
  
  // return first item of result array
  return tDataA[1]
end spot.findOne


/**
select records from database based on parameters provided

Example:
put spot.findMany(tCriteriaA) into tSpotA

Description:
using an array of criteria, selects records from the database

Parameters:
pCriteriaA array of fields/values to select on

Returns:
array of spot records found in database
**/
function spot.findMany pCriteriaA
  local tTeamA
  
  repeat for each key aCriteria in pCriteriaA
    datalayer.where aCriteria, pCriteriaA[aCriteria]
  end repeat
  
  return datalayer.select("spot", pCriteriaA)
end spot.findMany


/**
detele spot

Example:
get spot.delete(tId)

Description:
deletes a spot record from the database.
NOTICE: if no id is given nothing is deleted

Parameters:
pId string spot id

Returns:
integer number of records deleted

Tags: tags
**/
function spot.delete pId
  local tResult
  
  if pId is empty then
    return 0
  end if
  
  return datalayer.deleteById("spot", pId)
end spot.delete


/*
find spots by module id
*/
function spot.findByModuleId pModuleId
  local tCriteriaA
  local tResultA
  
  if pModuleId is empty then
    return empty
  end if
  
  // sort results by module name
  datalayer.orderBy "spot"
  
  // set up search criteria
  put pModuleId into tCriteriaA["moduleId"]
  
  // get spots for this module
  put spot.findMany(tCriteriaA) into tResultA
  
  // return the results
  return tResultA
end spot.findByModuleId


/*
count number of records
*/
function spot.count
  return datalayer.count("spot")
end spot.count


/*
sql for spots by module id
*/
private function __sql.spotByModuleId
  return "SELECT * FROM spot INNER JOIN module ON spot.moduleId = module.id" \
        && "WHERE module.id = :1"
end __sql.spotByModuleId


/*
get spots from module Id
*/

