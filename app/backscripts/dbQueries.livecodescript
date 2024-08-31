script "dbQueries"

function moduleDetailReportSQL pWhere
  local tResultSQL
  put "SELECT" & return & \
        "    module.id as moduleId," & return & \
        "    consignee.id as consigneeId," & return & \
        "    workorder.carId," & return & \
        "    workorder.spotId," & return & \
        "    module.name as moduleName," & return & \
        "    consignee.name as consigneeName," & return & \
        "    spot.track as dropZoneRef," & return & \
        "    spot.spot as dropZoneName," & return & \
        "    carType.code," & return & \
        "    carType.description as equipment," & return & \
        "    carType.length," & return & \
        "   workorder.cpw" & return & \
        "from module" & return & \
        "INNER JOIN consignee ON module.id = consignee.moduleId" & return & \
        "INNER JOIN workorder ON consignee.id = workorder.consigneeId" & return & \
        "INNER JOIN carType ON workorder.carId = carType.id" & return & \
        "INNER JOIN spot ON workorder.spotId = spot.id" & return into tResultSQL
  
  if pWhere["moduleId"] is not empty then
    put "WHERE module.id = " & quote & dbEscapeSqlite(pWhere["moduleId"]) & quote & return after tResultSQL
  end if
  
  if pWhere["owner"] is not empty then
    put "WHERE owner = " & quote & dbEscapeSqlite(pWhere["owner"]) & quote & return after tResultSQL
  end if
  
  put "ORDER BY module.name ASC, consignee.name ASC, spot.track ASC, carType.code ASC, carType.length ASC, carType.description ASC" after tResultSQL
  
  return tResultSQL
end moduleDetailReportSQL
