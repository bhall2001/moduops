script "ModelConsignee"
/*
count number of records
*/
function consignee.count
  return datalayer.count("consignee")
end consignee.count
