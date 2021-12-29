script "ModelModule"
/*
*  get all the modules associated with the active layout
*
* returns array
*/
function module.getAll
  local tDataA
  
  put datalayer.fetchAll("module") into tDataA
  
  return tDataA
end module.getAll


/*
count number of records
*/
function module.count
  return datalayer.count("module")
end module.count
