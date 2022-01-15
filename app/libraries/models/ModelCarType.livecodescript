script "ModelCarType"
/**
create a new car type

Example:
put carType.create(tCarTypeA) into tCarTypeId

Parameters:
tCarTypeA array of the new car type

Returns:
string id of new car type

**/
function carType.create @pDataA
  local tDataA, tResult
  
  put pDataA into tDataA
  
  if tDataA["id"] is empty then
    put uuid() into tDataA["id"]
  end if
  
  put datalayer.create("carType", tDataA) into tResult
  
  return tResult
end carType.create


/**
Summary
Updates data with an given array
*/
function carType.update pDataA
  local tResult
  
  if pDataA["id"] is empty then
    uiDisplayError "Car type id is not valid.", param(0)
    exit to top
  end if
  
  datalayer.where "id", pDataA["id"]
  put datalayer.update("carType", pDataA) into tResult
  
  if the result is not a number then
    uiDisplayError tResult, param(0)
  end if
  
  return tResult
end carType.update


/*
return a single item by id in database
*/
function carType.findOne pId
  local tEquipmentA
  
  if pId is empty then
    throw "ERROR: id required to to find car type"
  end if
  
  datalayer.where "id", pId
  
  put datalayer.select("carType") into tEquipmentA
  
  // when no array, return the entire result
  if tEquipmentA is not an array then
    return tEquipmentA
  end if
  
  // return first item of result array
  return tEquipmentA[1]
end carType.findOne


/**
select records from database based on parameters provided

Example:
put carType.findMany(tCriteriaA) into tCarTypeA

Description:
using an array of criteria, selects records from the database

Parameters:
pCriteriaA array of fields/values to select on

Returns:
array of car type records found in database
**/
function carType.findMany pCriteriaA
  local tTeamA
  
  repeat for each key aCriteria in pCriteriaA
    datalayer.where aCriteria, pCriteriaA[aCriteria]
  end repeat
  
  return datalayer.select("carType", pCriteriaA)
end carType.findMany


/**
detele car type

Example:
get carType.delete(tId)

Description:
deletes a car type record from the database.
NOTICE: if no id is given nothing is deleted

Parameters:
pId string car type id

Returns:
integer number of records deleted

Tags: tags
**/
function carType.delete pId
  local tResult
  
  if pId is empty then
    return 0
  end if
  
  return datalayer.deleteById("carType", pId)
end carType.delete


/*
delete all car type records
*/
function carType.deleteAll
  return datalayer.deleteAll("carType")
end carType.deleteAll

/*
count number of records
*/
function carType.count
  return datalayer.count("carType")
end carType.count


/*
find car type by module id (aka. all car types used by a module)
*/
function carType.findByModuleId pModuleId
  local tSql, tResultA, tBindingsA
  
  put __sql.carTypeByModuleId() into tSql
  put pModuleId into tBindingsA[1]
  put datalayer.QueryAsArray(tSql, tBindingsA) into tResultA
  
  return tResultA
end carType.findByModuleId


private function __sql.carTypeByModuleId
  return "SELECT DISTINCT carType.class,carType.era,carType.code,carType.description," & return & \
        "carType.short,carType.length,carType.remarks,carType.id,carType.max" & return & \
        "FROM workorder" & return & \
        "INNER JOIN consignee ON workorder.consigneeId = consignee.id" & return & \
        "INNER JOIN module ON consignee.moduleId = module.id" & return & \
        "INNER JOIN carType ON workorder.carId = carType.id" & return & \
        "WHERE ( module.id = :1 )"
end __sql.carTypeByModuleId
