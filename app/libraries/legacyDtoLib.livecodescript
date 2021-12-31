script "legacyDtoLib"
/*
transpose legacy carType to new array
*/
function legacy.carTypeDto @pCarTypeA
  local tResultA
  
  put pCarTypeA into tResultA
  put tResultA["UUID"] into tResultA["id"]
  delete variable tResultA["UUID"]
  
  return tResultA
end legacy.carTypeDto


/*
transpose legacy spot to new array
*/
function legacy.spotDto @pSpotA
  local tResultA
  
  put pSpotA into tResultA
  put tResultA["UUID"] into tResultA["id"]
  delete variable tResultA["UUID"]
  
  put tResultA["ModuleID"] into tResultA["temp"]
  delete variable tResultA["ModuleID"]
  put tResultA["temp"] into tResultA["ModuleId"]
  delete variable tResultA["temp"]
  
  return tResultA
end legacy.spotDto


/*
transpose legacy module to new array
*/
function legacy.moduleDto @pModuleA
  local tResultA
  
  put pModuleA into tResultA
  put tResultA["UUID"] into tResultA["id"]
  delete variable tResultA["UUID"]
  
  put tResultA["organizationID"] into tResultA["temp"]
  delete variable tResultA["organizationID"]
  put tResultA["temp"] into tResultA["organizationId"]
  delete variable tResultA["temp"]
  
  put tResultA["ownerID"] into tResultA["temp"]
  delete variable tResultA["ownerID"]
  put tResultA["temp"] into tResultA["ownerId"]
  delete variable tResultA["temp"]
  
  return tResultA
end legacy.moduleDto


/*
transpose legacy consignee to new array
*/
function legacy.consigneeDto @pConsigneeA
  local tResultA
  
  put pConsigneeA into tResultA
  put tResultA["UUID"] into tResultA["id"]
  delete variable tResultA["UUID"]
  
  put tResultA["moduleID"] into tResultA["temp"]
  delete variable tResultA["moduleID"]
  put tResultA["temp"] into tResultA["moduleId"]
  delete variable tResultA["temp"]
  
  return tResultA
end legacy.consigneeDto


/*
transpose legacy workorder to new array
*/
function legacy.workorderDto @pWorkorderA
  local tResultA
  
  put pWorkorderA into tResultA
  put tResultA["UUID"] into tResultA["id"]
  delete variable tResultA["UUID"]
  
  put tResultA["carID"] into tResultA["temp"]
  delete variable tResultA["carID"]
  put tResultA["temp"] into tResultA["carId"]
  delete variable tResultA["temp"]
  
  put tResultA["spotID"] into tResultA["temp"]
  delete variable tResultA["spotID"]
  put tResultA["temp"] into tResultA["spotId"]
  delete variable tResultA["temp"]
  
  put tResultA["consigneeID"] into tResultA["temp"]
  delete variable tResultA["consigneeID"]
  put tResultA["temp"] into tResultA["consigneeId"]
  delete variable tResultA["temp"]
  
  put tResultA["CPW"] into tResultA["temp"]
  delete variable tResultA["CPW"]
  put tResultA["temp"] into tResultA["cpw"]
  delete variable tResultA["temp"]
  
  return tResultA
end legacy.workorderDto


/*
transpose legacy train to new array
*/
function legacy.trainDto @pTrainA
  local tResultA
  
  put pTrainA into tResultA
  put tResultA["UUID"] into tResultA["id"]
  delete variable tResultA["UUID"]
  
  return tResultA
end legacy.trainDto


/*
transpose legacy manifest to new array
*/
function legacy.manifestDto @pManifestA
  local tResultA
  
  put pManifestA into tResultA
  put tResultA["UUID"] into tResultA["id"]
  delete variable tResultA["UUID"]
  
  put tResultA["trainID"] into tResultA["temp"]
  delete variable tResultA["trainID"]
  put tResultA["temp"] into tResultA["trainId"]
  delete variable tResultA["temp"]
  
  put tResultA["workorderID"] into tResultA["temp"]
  delete variable tResultA["workorderID"]
  put tResultA["temp"] into tResultA["workorderId"]
  delete variable tResultA["temp"]
  
  return tResultA
end legacy.manifestDto
