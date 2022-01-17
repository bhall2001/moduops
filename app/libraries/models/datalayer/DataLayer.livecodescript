script "DataLayer"
/*
Fetch all records from a given table
*/
function datalayer.fetchAll pTable
  if pTable is empty then throw "datalayer.fetchAll Error: pTable is emtpy"
  
  local tQuery
  put "SELECT * FROM" && pTable into tQuery
  
  return libDBFetchAsArray(tQuery)
end datalayer.fetchAll


/*
execute sql with bindings

parameters
pSQL: text: the sql to execute
pBindingsA: array: (optional) of items to bind to
*/
function datalayer.execute pSQL, pBindingsA
  dbExecute pSQL, pBindingsA
  return the Result
end datalayer.execute



/**
add condition to the search criteria

Example:
get datalayer.where(tCondition, tValue)

get datalayer.where("clubId", "1009")
get datalayer.where("or name", "Triple 5")

Parameters:
columnName string name of database field for the condition
condition string condition on the field

it should be run to set the search criteria.Parameters:
pTableName string of the table name


Returns:
returns

Tags: tags
**/
command datalayer.where columnName, pValue
  dbWhere columnName, pValue
end datalayer.where


/*
order results by
*/
command datalayer.orderBy pOrderBy
  dbOrderBy pOrderBy
end datalayer.orderBy


/*
apply NOT IN paramter to where clause
*/
command datalayer.notIn pColumnName, pValues
  dbNotIn pColumnName, pValues
end datalayer.notIn


/*
Select data from datastore

Example:
put datalayer.select("club", tParamA) into tResultA

Description:
returns rows from database for the given table. to add criteria the datalayer.where
it should be run to set the search criteria.Parameters:
pTableName string of the table name
pParamA array of query parameters
pParamA["associative"] string or empty set to the field name used for the associative array key
pParamA["dictionary"] string set to anything to create a 1-d array of key/value pairs

Returns:
array of teams

Tags: tags
**/
function datalayer.select pTableName pParamA
  if not datalayer.isConnected() then return empty
  
  local tQueryA, tResultA
  
  if pTableName is empty then return "Error: Table Name attribute is required." && param(0)
  
  put dbGet(pTableName,,pParamA["associative"]) into tResultA
  
  # check if returning a dictionary
  if pParamA["dictionary"] is not empty then
    return _dsToDict(tResultA)
  end if
  
  # return numerically indexed array of results
  return tResultA
end datalayer.select


/*
get single record from the data store

param: pTableName: string: data store name
param: pDataA: array: field/values to search
param: pId: string: id of data store row
*/
function datalayer.get pTableName, pDataA
  local tResultA
  
  if not datalayer.isConnected() then return empty
  
  if pTableName is empty then
    return "Error: pName is required (DAL)" for error
  end if
  
  if pDataA is not an array then return "Error: dsGet pDataA is not an array"
  
  repeat for each key aKey in pDataA
    dbWhere aKey, pDataA[aKey]
  end repeat
  
  put dbGet(pTableName) into tResultA
  
  if tResultA is empty then
    return empty
  end if
  
  if tResultA is not an array then
    put tResultA & return after message
    return empty
  end if
  
  return tResultA[1]
end datalayer.get


/*
Update data in the data store. If record not in data store, new record is created.

param: pName: string: data store name
param: pId: string: id of data store row
param: pDataA: array: key/value pairs of data to save to data store

*/
function datalayer.update pTableName, @pDataA
  if not datalayer.isConnected() then return empty
  
  if pTableName is empty then throw "Error: Table Name is required in" && param(0)
  if pDataA is not an array then throw "Error: Data must be an array of fieldname:value"
  
  try
    return dbUpdate(pTableName, pDataA)
    
  catch tError
    answer error tError
  end try
end datalayer.update


/*
Creates a record in the Data Store

param pTable: string: database table name
param pDataA: array of fields/values
*/
function datalayer.create pTable, @pDataA
  local tResult
  if not datalayer.isConnected() then return empty
  
  if pTable is empty then return "Error: No table name given in" && param(0)
  
  try
    put dbInsert(pTable, pDataA) into tResult
    if tResult is not a number then
      put tResult & return after message
    end if
    return tResult
  catch errorVariable
    return "Error: Unable to create record." for error
    return empty
  end try
end datalayer.create


/*
Delete data in the data store

param pName: string: data store name
param pId: string: data store row id

*/
function datalayer.deleteById pTableName, pId
  if not datalayer.isConnected() then return empty
  
  if pTableName is empty then
    return "Error: No Table name given for delete." && param(0) for error
  end if
  
  local tRecordA
  
  # if no id given, deletes all records in the table
  if pId is empty then
    local tSql, tResult
    
    put "DELETE from " & pTableName into tSql
    dbExecuteSQL tSql
    put the result into tResult
    return tResult
  end if
  
  dbWhere "id", pId
  # delete the record for the given id
  return dbDelete(pTableName)
end datalayer.deleteById


/*
Delete data in the data store using an array of parameters.
The parameters are added to the where for a sql delete

param pName: string: data store name
param pParamA: array of parameters for WHERE

*/
function datalayer.delete pTableName, @pParamA
  if not datalayer.isConnected() then return empty
  
  if pTableName is empty then
    return "Error: No Table name given #32" for error
  end if
  
  if pParamA is not an array then return "Error: No parameters given #32" for error
  
  repeat for each key aKey in pParamA
    dbWhere aKey, pParamA[aKey]
  end repeat
  
  # delete the record for the given id
  return dbDelete(pTableName)
end datalayer.delete


/**
performs a database delete

Parameters:
pTableName string the table

Returns:
integer number of effected rows

**/
function datalayer.deleteAll pTableName
  if not datalayer.isConnected() then return empty
  
  if pTableName is empty then
    return "Error: No Table name given for delete." && param(0) for error
  end if
  
  local tSql, tResult
  
  put "DELETE from " & pTableName into tSql
  dbExecuteSQL tSql
  put the result into tResult
  return tResult
end datalayer.deleteAll


/*
query using SQL returning an array for the resulting records
*/
function datalayer.QueryAsArray pSQL, pBindingsA
   local tResultA

   dbSetSQL pSQL, pBindingsA
   put dbGet() into tResultA

   return tResultA
end datalayer.QueryAsArray


function datalayer.disconnect
   local tId

   put dbGetDefaultConnectionID() into tId

   // if there is no open database connection just return
   if tId is empty then
      return empty
   end if

   return dbClose(tId)
end datalayer.disconnect


/*
opens a connection to a sqlite database

parameters:
pFilePath: string: full path and name of sqlite db to open

returns:
database id
*/
function datalayer.connect pFilePath
   return dbOpenSqlite(pFilePath)
end datalayer.connect


/*
Close an open database connection

parameters:
pId: number: required database connection ID
*/
function datalayer.close pId
   return dbClose(pId)
end datalayer.close


/*
create a new database

parameters
pFile: string: file to create including path
*/
function datalayer.create_db pFile
   local tDB

   // create new db and initialize it
   dbCreateNewSQLiteFile pfile,,true
   return dbOpenSqlite(pFile)

end datalayer.create_db


function datalayer.isConnected pConnection
   return (dbGetDefaultConnectionID() is a number)
end datalayer.isConnected


/*
returns the count of records in a given tabel
*/
function datalayer.count pTableName
   local tResult
   if not datalayer.isConnected() then return empty

   if pTableName is empty then return 0

   dbColumns "count(*)"
   put dbGet(pTableName) into tResult

   return tResult[1]["count(*)"]
end datalayer.count


/*
generate the primary id needed for sql-yoga

param pName: string: table name
param pDataA: array: of fieldnames and values

Complex primary index format required to be name:value,name2:value2 where multiple fields
make up the primary index
*/
private function _primaryId pName, @pDataA
   local tId

   switch pName
      case "clubTeam"
         return "club:" & pDataA["clubId"] & ",id:" & pDataA["id"]
         break
      default
         if pDataA["id"] is empty then throw "Error: ID is required." && param(0)
         return pDataA["id"]
   end switch
end _primaryId


private function _toAssociative @pDataA, pIndex
   local tIndex, tResultA

   repeat for each element aRow in pDataA

      # get the index
      put aRow[pIndex] into tIndex

      # store the row in the associative array
      put aRow into tResultA[tIndex]
   end repeat

   # return associative array of results
   return tResultA

end _toAssociative


/**
convert an array to a dictionary

Parameters:
pKeyField string: name of field to use as the key of dictionary. Default is "id"
pValueField string: nam of field to use as value of dictionary. Default is "value"

Description:
converts an array into a dictionary (hash table). A dictionary is a 1 deminsion array
where the keys are string value. The resulting array keys are de-duped by the nature of
a dictionary.

The incoming array must be in the form of:
pDataA[1]["id"]
pDataA[1]["value"]

pDataA[2]["id"]
pDataA[2]["value"]

Parameters:
pDataA The array to convert

Returns:
array that is a dictionary

Tags: tags
**/
private function _dsToDict @pDataA, pKeyField, pValueField
  local tResultA
  
  if pKeyField is empty then put "id" into pKeyField
  if pValueField is empty then put "value" into pValueField
  
  repeat for each element aRow in pDataA
    # create dictionary
    put aRow[pValueField] into tResultA[aRow[pKeyField]]
  end repeat
  
  # return the dictionary
  return tResultA
  
end _dsToDict
