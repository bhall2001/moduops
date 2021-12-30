script "ModelWorkorder"
/**
create a new workorder

Example:
put workorder.create(tWorkorderA) into tResult

Parameters:
tWorkorderA array of the new workorder data items

Returns:
number | string record count created or error string

**/
function workorder.create @pDataA
  local tDataA, tResult
  
  put pDataA into tDataA
  
  if tDataA["id"] is empty then
    put uuid() into tDataA["id"]
  end if
  
  put datalayer.create("workorder", tDataA) into tResult
  
  return tResult
end workorder.create


/**
Summary
Updates data with an given array
*/
function workorder.update pDataA
  local tResult
  
  if pDataA["id"] is empty then
    uiDisplayError "Workorder id is not valid.", param(0)
    exit to top
  end if
  
  datalayer.where "id", pDataA["id"]
  put datalayer.update("workorder", pDataA) into tResult
  
  if the result is not a number then
    uiDisplayError tResult, param(0)
  end if
  
  return tResult
end workorder.update


/*
return a single item by id in database
*/
function workorder.findOne pId
  local tDataA
  
  if pId is empty then
    throw "ERROR: id required to to find workorder"
  end if
  
  datalayer.where "id", pId
  
  put datalayer.select("workorder") into tDataA
  
  // when no array, return the entire result
  if tDataA is not an array then
    return tDataA
  end if
  
  // return first item of result array
  return tDataA[1]
end workorder.findOne


/**
select records from database based on parameters provided

Example:
put workorder.findMany(tCriteriaA) into tWorkorderA

Description:
using an array of criteria, selects records from the database

Parameters:
pCriteriaA array of fields/values to select on

Returns:
array of workorder records found in database
**/
function workorder.findMany pCriteriaA
  local tTeamA
  
  repeat for each key aCriteria in pCriteriaA
    datalayer.where aCriteria, pCriteriaA[aCriteria]
  end repeat
  
  return datalayer.select("workorder", pCriteriaA)
end workorder.findMany


/**
detele workorder

Example:
get workorder.delete(tId)

Description:
deletes a workorder record from the database.
NOTICE: if no id is given nothing is deleted

Parameters:
pId string workorder id

Returns:
integer number of records deleted

Tags: tags
**/
function workorder.delete pId
  local tResult
  
  if pId is empty then
    return 0
  end if
  
  return datalayer.deleteById("workorder", pId)
end workorder.delete


/*
count number of records
*/
function workorder.count
  return datalayer.count("workorder")
end workorder.count


/*
sql to find by consignee id
*/
private function __sql.findByConsigneeId
  return "SELECT workorder.cpw, spot.track, spot.spot, workorder.id,workorder.carId,workorder.spotId," & \
        "carType.class, carType.description, carType.length" & return & \
        "FROM spot" & return & \
        "INNER JOIN workorder ON spot.id = workorder.spotId" & return & \
        "INNER JOIN carType ON carType.id = workorder.carId" & return & \
        "WHERE workorder.consigneeId = :1"
end __sql.findByConsigneeId


/*
find work orders by consignee id
*/
function workorder.findByConsigneeId pConsigneeId
  local tSql
  local tBindingsA, tDataA
  
  // no consignee id provided? return nothing
  if pConsigneeId is empty then
    return empty
  end if
  
  put __sql.findByConsigneeId() into tSql
  put pConsigneeId into tBindingsA[1]
  put datalayer.QueryAsArray(tSql, tBindingsA) into tDataA
  
  return tDataA
end workorder.findByConsigneeId
