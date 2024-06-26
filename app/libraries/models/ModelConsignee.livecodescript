﻿script "ModelConsignee"
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
delete all consignees
*/
function consignee.deleteAll
  get datalayer.deleteAll("consignee")
end consignee.deleteAll


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


/*
find consignee for module by spot direction
*/
function consignee.findByDirection pModuleId, pDirection
  local tSql, tBindingsA
  local tResultA
  
  put __sql.consigneeSpots() into tSql
  // add direction to sql
  put "AND spot.direction = :2" after tSql
  
  put pModuleId into tBindingsA[1]
  put pDirection into tBindingsA[2]
  put datalayer.QueryAsArray(tSql, tBindingsA) into tResultA
  
  return tResultA
end consignee.findByDirection


private function __sql.consigneeSpots
  return "SELECT  DISTINCT consignee.name,spot.direction,consignee.id,consignee.moduleId,consignee.remarks" & return && \
        "FROM consignee" & return && \
        "INNER JOIN module ON consignee.moduleId = module.id" & return && \ 
        "INNER JOIN workorder ON workorder.consigneeId = consignee.id" & return && \
        "INNER JOIN spot ON workorder.spotId = spot.id" & return && \
        "WHERE consignee.moduleId = :1" & return
end __sql.consigneeSpots


/*
delete all consignees with a given moduele id

parameters
pModuleId string id of module to delete
*/
command consignee.deleteByModuleId pModuleId
  local tConsigneeA
  local tEquipmentA
  local tWorkOrderA
  local tCriteriaA
  local tCarTypeWorkorderA
  
  // get all the consignees for this module
  put consignee.findByModuleId(pModuleId) into tConsigneeA
  
  // for each consignee we need to delete all the workorders (equipment requests)
  repeat with consigneeIndex = 1 to number of elements of tConsigneeA
    put workorder.findByConsigneeId(tConsigneeA[consigneeIndex]["id"]) into tWorkOrderA
    
    // for each work order we have a little work
    repeat with workorderIndex = 1 to number of elements of tWorkOrderA
      // save the equipment id as an index in an array. This de-dups the cars for us
      put tWorkOrderA[workorderIndex]["carId"] into tEquipmentA[tWorkOrderA[workorderIndex]["carId"]]
      
      // now we need to delete the work order
      get workorder.delete(tWorkOrderA[workorderIndex]["id"])
    end repeat
    
    // now we need to detail any equipment that is no longer being used
    repeat for each key aCar in tEquipmentA
      put aCar into tCriteriaA["carId"]
      put workorder.findMany(tCriteriaA) into tCarTypeWorkorderA
      
      // if there are still work orders using this equipment go to the next equipment
      if the number of elements of tCarTypeWorkorderA > 0 then next repeat
      
      // nothing is using this equipment so we can delete it
      get carType.delete(aCar)
    end repeat
    
    // now we can delete the consignee record from the database
    get consignee.delete(tConsigneeA[consigneeIndex]["id"])
  end repeat
  
end consignee.deleteByModuleId

