script "ModelMrbt"
/*
get output data
*/
function mrbt.output pTrainId
  local tSql, tBindingsA, tResultA
  
  put __sql.mrbtOutput() into tSql
  put pTrainId into tBindingsA[1]
  
  put datalayer.QueryAsArray(tSql, tBindingsA) into tResultA
  return tResultA
end mrbt.output


private function __sql.mrbtOutput
  return "SELECT workorder.carId,workorder.spotId,workorder.consigneeId,workorder.Remarks AS workorderRemarks," & return & \
        "consignee.moduleId,consignee.name AS consigneeName,consignee.remarks AS consigneeRemarks," & return & \
        "module.name AS moduleName,module.short_name,module.remarks AS moduleRemarks," & return & \
        "spot.spot,carType.class,carType.description,carType.code,carType.short," & return & \
        "carType.length,carType.remarks AS carTypeRemarks,spot.track,manifest.workorderId," & return & \
        "manifest.trainId,manifest.stop" & return & \
        "FROM workorder" & return & \
        "INNER JOIN consignee ON workorder.consigneeId = consignee.id" & return & \
        "INNER JOIN spot ON workorder.spotId = spot.id" & return & \
        "INNER JOIN carType ON workorder.carId = carType.id" & return & \
        "INNER JOIN manifest ON manifest.workorderId = workorder.id" & return & \ 
        "INNER JOIN module ON consignee.moduleId = module.id" & return & \ 
        "WHERE manifest.trainId = :1" & return & \
        "ORDER BY manifest.stop,spot.track,spot.spot,consignee.name,carType.class,carType.description"
end __sql.mrbtOutput
