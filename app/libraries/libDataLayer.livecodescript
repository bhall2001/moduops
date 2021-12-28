script "libDataLayer"
/*
Fetch all records from a given table
*/
function fetchAllRecords pTable
  if pTable is empty then throw "fetchAllRecords Error: pTable is emtpy"
   
   local tQuery
   put "SELECT * FROM" && pTable into tQuery
   
   return libDBFetchAsArray(tQuery)
end fetchAllRecords

