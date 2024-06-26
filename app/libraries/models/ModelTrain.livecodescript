﻿script "ModelTrain"
/**
select records from database based on parameters provided

Example:
put train.findMany(tCriteriaA) into tTrainA

Description:
using an array of criteria, selects records from the database

Parameters:
pCriteriaA array of fields/values to select on

Returns:
array of train records found in database
**/
function train.findMany pCriteriaA  
  repeat for each key aCriteria in pCriteriaA
    datalayer.where aCriteria, pCriteriaA[aCriteria]
  end repeat
  
  return datalayer.select("train", pCriteriaA)
end train.findMany


/*
return a single item by id in database
*/
function train.findOne pId
  local tDataA
  
  if pId is empty then
    throw "ERROR: id required to to find train"
  end if
  
  datalayer.where "id", pId
  put datalayer.select("train") into tDataA
  
  // when no array, return the entire result
  if tDataA is not an array then
    return tDataA
  end if
  
  // return first item of result array
  return tDataA[1]
end train.findOne



/**
get all records from the train table

Example:
put train.getAll() into tTrainA

Description:
get all the records of the train table

Returns:
array of train records

Tags: tags
**/
function train.getAll
  local tTrainA
  
  try
    return datalayer.fetchAll("train") into tTrainA
  catch error
    throw error
  end try
  
end train.getAll





/**
create a new train

Example:
put train.create(tTrainA) into tResult

Parameters:
tTrainA array of the new train data items

Returns:
number | string record count created or error string

**/
function train.create @pDataA
  local tDataA, tResult
  
  put pDataA into tDataA
  
  if tDataA["id"] is empty then
    put uuid() into tDataA["id"]
  end if
  
  put datalayer.create("train", tDataA) into tResult
  
  return tResult
end train.create


/**
Summary
Updates data with an given array
*/
function train.update pDataA
  local tResult
  
  if pDataA["id"] is empty then
    uiDisplayError "Train id is not valid.", param(0)
    exit to top
  end if
  
  datalayer.where "id", pDataA["id"]
  put datalayer.update("train", pDataA) into tResult
  
  if the result is not a number then
    uiDisplayError tResult, param(0)
  end if
  
  return tResult
end train.update


/**
detele train

Example:
get train.delete(tId)

Description:
deletes a train record from the database.
NOTICE: if no id is given nothing is deleted

Parameters:
pId string train id

Returns:
integer number of records deleted

Tags: tags
**/
function train.delete pId
  local tResult
  
  if pId is empty then
    return 0
  end if
  
  return datalayer.deleteById("train", pId)
end train.delete


/*
delete all trains
*/
function train.deleteAll
  get datalayer.deleteAll("train")
end train.deleteAll


/*
get train by Symbol

parameter pSymbol Symbol of train to retrieve

returns array of train data
*/
function train.findBySymbol pSymbol
  local tDataA
  
  if pSymbol is empty then
    return empty
  end if
  
  put mdbQueryByValue("train", "symbol", pSymbol, true) into tDataA
  datalayer.where "symbol", pSymbol
  put datalayer.select("train") into tDataA
  
  return tDataA[1]
end train.findBySymbol


/*
Get all trains of a given type

returns array
*/
function train.findByType pType
  local tDataA
  
  if pType is empty then return empty
  
  datalayer.where "type", pType
  put datalayer.select("train") into tDataA
  
  return tDataA
end train.findByType


/*
generate train symbol, train name CSV data
*/
function trainSymbolNameAsCSV
  local tText, tTrainA, tIndex
  
  put train.findMany() into tTrainA
  
  repeat for each element aTrain in tTrainA
    put aTrain["symbol"] after tText
    
    if aTrain["name"] is not empty then
      put "," && aTrain["name"] after tText
    end if
    
    put return after tText
  end repeat
  //delete char -1 of tText
  
  return tText
end trainSymbolNameAsCSV


/*
count number of records
*/
function train.count
  return datalayer.count("train")
end train.count


/*
transform train array
*/
function train.dto @pTrainA
  local tTrainA
  
  put pTrainA into tTrainA
  
  // add origin name
  if tTrainA["origin"] is not empty then
    put yard.nameById(tTrainA["origin"]) into tTrainA["originName"]
  end if
  
  // add destination name
  if tTrainA["destination"] is not empty then
    put yard.nameById(tTrainA["destination"]) into tTrainA["destinationName"]
  end if
  
  return tTrainA
end train.dto


/*
add origin/destination name to train records
*/
function train.addNames pTrainA
  local tResultA
  
  repeat with i = 1 to number of elements of pTrainA
    put train.dto(pTrainA[i]) into tResultA[i]
  end repeat
  
  return tResultA
end train.addNames



/*
delete module from train route.

It is intentional that this code does not have a commit block. That is handled by
logic that is deleting a module and related items when a module is removed from
a layout.

paramerters
pModuleId string id of the module to delete
*/
command train.deleteModulefromRoute pModuleId
  local tTrainA
  local tNewTrainA
  local tRouteA
  local tNewRouteA
  local tNewRouteIndex
  local tSpotA
  
  // get all the trains in the layout
  put train.getAll() into tTrainA
  
  // loop over each of the trains
  repeat with tTrainIndex = 1 to number of elements of tTrainA
    
    // first up we need to check if module is train origin/destination
    put spot.findOne(tTrainA[tTrainIndex]["origin"]) into tSpotA
    if tSpotA["moduleId"] = pModuleId then
      // delete this train when train origin is on module being deleted
      get train.delete(tTrainA[tTrainIndex]["id"])
      next repeat
    end if
    
    put spot.findOne(tTrainA[tTrainIndex]["destination"]) into tSpotA
    if tSpotA["moduleId"] = pModuleId then
      // delete this train when train destination is on module being deleted
      get train.delete(tTrainA[tTrainIndex]["id"])
      next repeat
    end if
    
    // initialize the new train record
    put tTrainA[tTrainIndex] into tNewTrainA
    
    // convert the train's route from json to an array
    put JSONToArray(tTrainA[tTrainIndex]["route"])  into tRouteA
    
    // initialize new route variables
    put empty into tNewRouteA
    put 0 into tNewRouteIndex
    
    // loop over the train route array
    repeat with tRouteIndex = 1 to number of elements of tRouteA
      // when a route contains the module to delete, skip adding it to the new route
      if tRouteA[tRouteIndex]["moduleId"] = pModuleId then next repeat
      
      // we have a stop that needs to be added to the new route
      // increment the index
      add 1 to tNewRouteIndex
      
      // add this stop to the route
      put tRouteA[tRouteIndex] into tNewRouteA[tNewRouteIndex]
      
      // update the stop number in the new route
      put tNewRouteIndex into tNewRouteA[tNewRouteIndex]["stop"]
    end repeat
    
    // add the new route to the new train
    if tNewRouteA is an array then
      put ArrayToJSON(tNewRouteA,"object") into tNewTrainA["route"]
    else
      put empty into tNewTrainA["route"]
    end if
    
    // update the train in the database
    get train.update(tNewTrainA)        
  end repeat
end train.deleteModulefromRoute
