script "ModelModule"
/**
create a new module

Example:
put module.create(tModuleA) into tResult

Parameters:
tModuleA array of the new module data items

Returns:
number | string record count created or error string

**/
function module.create @pDataA
  local tDataA, tResult
  
  put pDataA into tDataA
  
  if tDataA["id"] is empty then
    put uuid() into tDataA["id"]
  end if
  
  put datalayer.create("module", tDataA) into tResult
  
  return tResult
end module.create


/**
Summary
Updates data with an given array
*/
function module.update pDataA
  local tResult
  
  if pDataA["id"] is empty then
    uiDisplayError "Module id is not valid.", param(0)
    exit to top
  end if
  
  datalayer.where "id", pDataA["id"]
  put datalayer.update("module", pDataA) into tResult
  
  if the result is not a number then
    uiDisplayError tResult, param(0)
  end if
  
  return tResult
end module.update


/*
return a single item by id in database
*/
function module.findOne pId
  local tDataA
  
  if pId is empty then
    throw "ERROR: id required to to find module"
  end if
  
  datalayer.where "id", pId
  
  put datalayer.select("module") into tDataA
  
  // when no array, return the entire result
  if tDataA is not an array then
    return tDataA
  end if
  
  // return first item of result array
  return tDataA[1]
end module.findOne


/**
select records from database based on parameters provided

Example:
put module.findMany(tCriteriaA) into tModuleA

Description:
using an array of criteria, selects records from the database

Parameters:
pCriteriaA array of fields/values to select on

Returns:
array of module records found in database
**/
function module.findMany pCriteriaA, pOrderBy
  local tTeamA
  
  repeat for each key aCriteria in pCriteriaA
    datalayer.where aCriteria, pCriteriaA[aCriteria]
  end repeat
  
  if pOrderBy is not empty then
    datalayer.orderBy pOrderBy
  end if
  
  return datalayer.select("module", pCriteriaA)
end module.findMany


/**
detele module

Example:
get module.delete(tId)

Description:
deletes a module record from the database.
NOTICE: if no id is given nothing is deleted

Parameters:
pId string module id

Returns:
integer number of records deleted

Tags: tags
**/
function module.delete pId
  local tResult
  
  if pId is empty then
    return 0
  end if
  
  return datalayer.deleteById("module", pId)
end module.delete


/*
delete all modules
*/
function module.deleteAll
  get datalayer.deleteAll("module")
end module.deleteAll


/*
count number of records
*/
function module.count
  return datalayer.count("module")
end module.count


function module.equipmentReport pModuleId, pOwner
  local tReportA
  local tModuleDetailReportSQL
  local tWhere
  
  if pModuleId is not empty then
    put pModuleId into tWhere["moduleId"]
  end if
  
  if pOwner is not empty then
    put pOwner into tWhere["owner"]
  end if
  
  put moduleDetailReportSQL(tWhere) into tModuleDetailReportSQL
  
  dbSetSQL tModuleDetailReportSQL
  put dbGet() into tReportA
  
  return tReportA
  
end module.equipmentReport
