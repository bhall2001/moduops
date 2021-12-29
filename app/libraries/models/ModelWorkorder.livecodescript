script "ModelWorkorder"
/*
count number of records
*/
function workorder.count
  return datalayer.count("workorder")
end workorder.count

