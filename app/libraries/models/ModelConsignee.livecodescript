script "ModelConsignee"
/**
create a new consignee

Example:
put consignee.create(tConsigneeA) into tResult

Parameters:
tConsigneeA array of the new consignee data items

Returns:
number | string record count created or error string

**/
function consignee.create @pDataA
  local tDataA, tResult
  
  put pDataA into tDataA
  
  if tDataA["id"] is empty then
    put uuid() into tDataA["id"]
  end if
  
  put datalayer.create("consignee", tDataA) into tResult
  
  return tResult
end consignee.create


/**
Summary
Updates data with an given array
*/
function consignee.update pDataA
  local tResult
  
  if pDataA["id"] is empty then
    uiDisplayError "Consignee id is not valid.", param(0)
    exit to top
  end if
  
  datalayer.where "id", pDataA["id"]
  put datalayer.update("consignee", pDataA) into tResult
  
  if the result is not a number then
    uiDisplayError tResult, param(0)
  end if
  
  return tResult
end consignee.update


/*
return a single item by id in database
*/
function consignee.findOne pId
  local tDataA
  
  if pId is empty then
    throw "ERROR: id required to to find consignee"
  end if
  
  datalayer.where "id", pId
  
  put datalayer.select("consignee") into tDataA
  
  // when no array, return the entire result
  if tDataA is not an array then
    return tDataA
  end if
  
  // return first item of result array
  return tDataA[1]
end consignee.findOne


/**
select records from database based on parameters provided

Example:
put consignee.findMany(tCriteriaA) into tConsigneeA

Description:
using an array of criteria, selects records from the database

Parameters:
pCriteriaA array of fields/values to select on

Returns:
array of consignee records found in database
**/
function consignee.findMany pCriteriaA
  local tTeamA
  
  repeat for each key aCriteria in pCriteriaA
    datalayer.where aCriteria, pCriteriaA[aCriteria]
  end repeat
  
  return datalayer.select("consignee", pCriteriaA)
end consignee.findMany


/**
detele consignee

Example:
get consignee.delete(tId)

Description:
deletes a consignee record from the database.
NOTICE: if no id is given nothing is deleted

Parameters:
pId string consignee id

Returns:
integer number of records deleted

Tags: tags
**/
function consignee.delete pId
  local tResult
  
  if pId is empty then
    return 0
  end if
  
  return datalayer.deleteById("consignee", pId)
end consignee.delete


/*
count number of records
*/
function consignee.count
  return datalayer.count("consignee")
end consignee.count



/*
find consignees by module id
*/
function consignee.findByModuleId pModuleId
  local tCriteriaA
  local tResultA
  
  if pModuleId is empty then
    return empty
  end if
  
  // sort results by module name
  datalayer.orderBy "name"
  
  // set up search criteria
  put pModuleId into tCriteriaA["moduleId"]
  
  // get consignees for this module
  put consignee.findMany(tCriteriaA) into tResultA
  
  // return the results
  return tResultA
end consignee.findByModuleId
