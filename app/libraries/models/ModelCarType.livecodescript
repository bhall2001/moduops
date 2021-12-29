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
return equipment in database
*/
function carType.get pId
  local tEquipmentA
  
  if pId is not empty then
    datalayer.where "id", pId
  end if
  
  put datalayer.select("carType") into tEquipmentA
  
  // return first item when id is given
  if pId is not empty then
    return tEquipmentA[1]
  end if
  
  return tEquipmentA
end carType.get


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
count number of records
*/
function carType.count
  return datalayer.count("carType")
end carType.count
