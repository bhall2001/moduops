script "modDBLib"

local sDatabaseID -- the Database ID

--
-- Updates a single record in a table
--
function updateRecord pUUID, pTable, pData
   local tResult
   
   dbResetQuery
   dbWhere "UUID", pUUID
   put dbUpdate(pTable, pData) into tResult
   
   if tResult is not a number then
      answer  tResult
      return false
   else
      return true
   end if
end updateRecord

function getUUIDRecord pUUID, pTable
   put "getUUIDRecord" && the short name of the target
   return mdbQueryByUUID(pUUID, pTable)
end getUUIDRecord

function mdbUpdateRecord pUUID, pTable, pDataA
   local tResult
   
   dbResetQuery
   dbWhere "UUID", pUUID
   put dbUpdate(pTable, pDataA) into tResult
   
   return tResult
   
end mdbUpdateRecord

function mopUpdateRecord pUUID, pTable, pDataA
   put "mopUpdateRecord: " & the short name of the target
   
   return mdbUpdateRecord(pUUID, pTable, pDataA)
end mopUpdateRecord

function mdbInsertRecord pTable, pDataA
   local tResult
   
   dbResetQuery
   put dbInsert(pTable, pDataA) into tResult
   
   return tResult
end mdbInsertRecord

function mopInsertRecord pTable, pDataA
   put "mopInsertRecord: " & the short name of the target
   return mdbInsertRecord(pTable, pDataA)
end mopInsertRecord

function mdbDeleteManifestByTrainID pTrainID
   local tDataA, tSQL
   
   put the cDeleteManifestByTrainID of stack "mopDBLib" into tSQL
   
   replace ":1" with pTrainID in tSQL
   get mdbExecuteSQL(tSQL)
   
   return the result   
end mdbDeleteManifestByTrainID

function mdbTableToArray pTable
   local tDataA, tSQL
   
   put the cGetTableSQL of stack "mopDBLib" into tSQL
   
   replace ":1" with pTable in tSQL
   put mdbQuerytoArray(tSQL) into tDataA
   return tDataA
end mdbTableToArray

function mopGetTable pTable
   answer "mopGetTable: " & the short name of the target
end mopGetTable

--
-- function returns module information for a given spot UUID
--
function getSpotModule pUUID
   local tSQL, tDataA
   
   put "SELECT   module.name, spot.UUID, module.owner, module.size," & return into tSQL
   put "                module.city, module.state, module.description, " & return after tSQL
   put "                module.remarks, module.short_name" & return after tSQL
   put "FROM      spot" & return after tSQL
   put "INNER JOIN module ON spot.ModuleID = module.UUID" & return after tSQL
   put "WHERE    ( spot.UUID = " & quote & pUUID & quote & " )" after tSQL
   
   dbResetQuery
   dbSetSQL(tSQL)
   put dbGet() into tDataA
   
   return tDataA[1]
end getSpotModule

--
-- Returns all the spots for a given Module UUID
--
function mdbGetSpots pUUID
   local tSQL, tDataA
   
   /*
   put "SELECT   *" & return into tSQL
   put "FROM      spot" & return after tSQL
   put "INNER JOIN module  ON spot.moduleID = module.UUID" & return after tSQL
   put "WHERE       module.UUID = " & quote & pUUID & quote after tSQL
   */
   
   put the cGetSpotsSQL of stack "mopDBLib" into tSQL
   replace ":1" with pUUID in tSQL
   put mdbQueryToArray(tSQL) into tDataA
   
   return tDataA
end mdbGetSpots

function mopGetSpots
   answer "mopGetSpots: " & the short name of the target
end mopGetSpots

function getModuleSpots pUUID
   put "getModulesSpots" && the short name of the target
   return mdbGetSpots(pUUID)
end getModuleSpots

function getConsigneesModule pModuleUUID
   put "getConsigneesModule:" && the short name of the target
   return mopGetConsignees(pModuleUUID)
end getConsigneesModule

##
## Function used on Modules/Towns screen
## returns a list of the Consignees for a given Module UUID
## 
function mdbListConsignees pModuleUUID
   local tSQL, tDataA
   
   put the cListConsigneesSQL of stack "mopDBLib" into tSQL
   replace ":1" with pModuleUUID in tSQL
      
   put "ORDER BY " & quote & "consignee" & quote & "." & quote & "name" & quote after tSQL
   
   put mdbQuerytoArray(tSQL) into tDataA
   
   return tDataA
end mdbListConsignees

function mdbGetConsignees pModuleUUID, pDirection
   local tSQL, tDataA
   
   put the cGetConsigneesSQL of stack "mopDBLib" into tSQL
   replace ":1" with pModuleUUID in tSQL
   
   if pDirection is not empty then
      put " AND " & quote & "spot" & quote & "." & quote & "direction" & quote & \
            " = " & quote & pDirection & quote after tSQL
   end if
   
   put " ORDER BY " & quote & "consignee" & quote & "." & quote & "name" & quote after tSQL

   put mdbQuerytoArray(tSQL) into tDataA
   
   return tDataA
end mdbGetConsignees

function mdbExecuteSQL pSQL
   if sDatabaseID is not a number then
      mdbOpenDB
   end if
   
   revExecuteSQL sDatabaseID, pSQL
   return the result
end mdbExecuteSQL

function mdbDeleteTable pTable
   local tSQL
   
   put the cDeleteTable of stack "mopDBLib" into tSQL
   replace ":1" with pTable in tSQL
   get mdbExecuteSQL(tSQL)
end mdbDeleteTable

function mdbDeleteAll
   local tResult
   
   -- Delete all existing data
   put mdbExecuteSQL("DELETE FROM manifest") into tResult
   put mdbExecuteSQL("DELETE FROM workorder") into tResult
   get mdbExecuteSQL("DELETE FROM carType")
   get mdbExecuteSQL("DELETE FROM spot")
   get mdbExecuteSQL("DELETE FROM consignee")
   get mdbExecuteSQL("DELETE FROM module")
   get mdbExecuteSQL("DELETE FROM route")
   get mdbExecuteSQL("DELETE FROM train")
   get mdbExecuteSQL("DELETE FROM config_data")

   return true
end mdbDeleteAll

function mdbArrayToTable pTableName, @pDataA
   local tDataA, tKeys, tResult, tCount=0
   
   if pDataA is not an array then
      return "error load db data is not an array"
   end if
   
   if sDatabaseID is not a number then databaseConnect
   
   repeat for each element aItem in pDataA
      if aItem is an array then
         --put the keys of aItem into tKeys
         
         /*repeat for each line aKey in tKeys
            put aItem[aKey] into tDataA[aKey]
         end repeat
         */
         
         --put dbInsert(pTableName, tDataA) into tResult
         put mdbInsertRecord(pTableName, aItem) into tResult
         
         if tResult is not a number then
            return tResult
         else
            add 1 to tCount
         end if
      end if
   end repeat
   return tCount
end mdbArrayToTable

command mdbCloseDB
   revCloseDatabase sDatabaseID
end mdbCloseDB

command mdbOpenDB
   local tDatabasePath, tDatabaseID, tDelimiter
   
   if getDatabaseID() is not a number then
      ## The database must be in a writeable location
      put the cAppPath of stack "Module Operations" into tDatabasePath
      --put specialFolderPath("Resources") into tDatabasePath
      ###put the itemDelimiter into tDelimiter
      ###set the itemDelimiter to "/"
      ###delete the last item of tDatabasePath
      put "/moduops.db" after tDatabasePath
      set the itemDelimiter to tDelimiter
      
      ## Open a connection to the database
      ## If the database does not already exist it will be created
      put revOpenDatabase("sqlite", tDatabasePath, , , , ) into tDatabaseID
      if tDatabaseID is not a number then
         answer tDatabaseID
         exit to top
      else
         ## Store the database id so other handlers can access it
         setDatabaseID tDatabaseID
         revExecuteSQL tDatabaseID, "PRAGMA foreign_keys = true"
         dbSetDefaultConnectionID tDatabaseID
      end if
   end if
end mdbOpenDB

on databaseConnect
   put "got a databaseConnect message"
   mopDBConnect
end databaseConnect

command setDatabaseID pDatabaseID
   put pDatabaseID into sDatabaseID
end setDatabaseID

function getDatabaseID
   return sDatabaseID
end getDatabaseID

function mdbNumRecords pTable
   local tSQL, tResult
   
   if sDatabaseID = "" then
      mdbOpenDB
   end if
   put "SELECT COUNT(*) FROM " & pTable into tSQL
   put revDataFromQuery(tab, cr, sDatabaseID, tSQL) into tResult
   return tResult
end mdbNumRecords

/*
Returns all records in an array from a table wih a given UUID.
Since UUIDs are unique, there should only be 1 record returned.
*/
function mdbQueryByUUID pTable, pUUID
   local tSQL, tResult
   
   put the cQueryByUUID of stack "mopDBLib" into tSQL
   
   replace ":1" with pTable in tSQL
   replace ":2" with pUUID in tSQL
   
   put mdbQueryToArray(tSQL) into tResult
   return tResult
end mdbQueryByUUID

/*
* Returns a records from a database. If pOnlyFirst is true, then function
* returns the first record of the result set as an array. If pOnlyFirst is
* false, then a numerical index array is returned of the result set.
* 
* @created 18-JAN=2017
* @author Bob Hall
*
* @parameter string pTable
* @parameter string pField
* @parameter string pID
* @parameter boolean pOnlyFirst
*
* @returns array
*/
function mdbQueryByValue pTable, pField, pID, pOnlyFirst
   local tResultA
   
   dbResetQuery
   dbWhere pField, pID
   put dbGet(pTable) into tResultA
   
   if pOnlyFirst then
      return tResultA[1]
   else
      return tResultA
   end if
end mdbQueryByValue

/*
Returns all records in an array from a table wih a given moduleID.
*/
function mdbQueryByModuleID pTable, pModuleID
   local tSQL, tResult
   
   put the cQueryByModuleID of stack "mopDBLib" into tSQL
   
   replace ":1" with pTable in tSQL
   replace ":2" with pModuleID in tSQL
   
   put mdbQuerytoArray(tSQL) into tResult
   return tResult
end mdbQueryByModuleID

/*
Returns all records in an array from a table wih a given consigneeID.
*/
function mdbQueryByConsigneeID pTable, pConsigneeD
   local tSQL, tResult
   
   put the cQueryByConsigneeID of stack "mopDBLib" into tSQL
   
   replace ":1" with pTable in tSQL
   replace ":2" with pConsigneeD in tSQL
   
   put mdbQuerytoArray(tSQL) into tResult
   return tResult
end mdbQueryByConsigneeID

function mdbStopModuleWO pModuleUUID
   local tSQL, tResult
   
   put the cStopModuleWOQuery of stack "mopDBLib" into tSQL
   replace ":1" with pModuleUUID in tSQL
   
   put mdbQuerytoArray(tSQL) into tResult
   return tResult
end mdbStopModuleWO

function mdbQueryWOByModuleID pModuleID
   local tSQL, tResult
   
   put the cQueryWObyModuleID of stack "mopDBLib" into tSQL
   replace ":1" with pModuleID in tSQL
   
   put mdbQuerytoArray(tSQL) into tResult
   return tResult
end mdbQueryWOByModuleID

function mdbQueryCarTypeByModuleID pModuleID
   local tSQL, tResult
   
   put the cQueryCarTypeByModuleID of stack "mopDBLib" into tSQL
   replace ":1" with pModuleID in tSQL
   
   put mdbQuerytoArray(tSQL) into tResult
   return tResult
   
end mdbQueryCarTypeByModuleID

function mdbStopConsigneeWO pConsigneeID
   local tSQL, tResult
   
   put the cStopConsigneeWOQuery of stack "mopDBLib" into tSQL
   replace ":1" with pConsigneeID in tSQL
   
   put mdbQuerytoArray(tSQL) into tResult
   return tResult
end mdbStopConsigneeWO

function mdbQueryToArray pSQL
   local tDataA, theCursor, theError
   
   if sDatabaseID = "" then
      mdbOpenDB
   end if
   
   put revQueryDatabase( sDatabaseID, pSQL) into theCursor
   
   if theCursor is an integer then
      ConvertSQLCursorToArray theCursor, tDataA
      put the result into theError
      			
      if theError is not empty then
         ## The cursor was successfully converted to an array.
         ## Assign it to the data grid. The 'firstname' and 'lastname' columns
         ## from the database cursor will appear in the matching columns
         ## in the data grid.
         return theError
      end if
      			
      ## Close the database cursor 
      revCloseCursor theCursor
   end if
   return tDataA  
end mdbQueryToArray

command ConvertSQLCursorToArray pCursor, @pOutArrayA
	local i
	local theFields
	local theError
	
	## Get the names of all the columns in the database cursor
	put revDatabaseColumnNames(pCursor) into theFields
	if theFields begins with "revdberr," then
		put item 2 to -1 of theFields into theError
	end if
	
	if theError is empty then
		put 0 into i
		## Loop through all rows in cursor
		repeat until revQueryIsAtEnd(pCursor)
			add 1 to i
			
			## Move all fields in row into next dimension of the array
			repeat for each item theField in theFields
				put revDatabaseColumnNamed(pCursor, theField) into pOutArrayA[i][ theField ]
			end repeat
			
			revMoveToNextRecord pCursor
		end repeat
	end if
	
	return theError
end ConvertSQLCursorToArray


function mdbSmartyOutput pTrainID
   local tSQL, tResult
   
   put the cSmartyOutputSQL of stack "mopDBLib" into tSQL
   
   replace ":1" with pTrainID in tSQL
   
   put mdbQuerytoArray(tSQL) into tResult
   return tResult
   
end mdbSmartyOutput

function mdbMRBTOutput pTrainID
   local tSQL, tResult
   
   put the cMRBTOutputSQL of stack "mopDBLib" into tSQL
   
   replace ":1" with pTrainID in tSQL
   
   put mdbQuerytoArray(tSQL) into tResult
   return tResult
   
end mdbMRBTOutput

on openstack
   
end openstack
   
function mdbDeleteByUUID pTable, pUUID
   local tSQL, tResult
   
   put the cDeleteByUUID of stack "mopDBLib" into tSQL
   replace ":1" with pTable in tSQL
   replace ":2" with pUUID in tSQL
   
   put mdbExecuteSQL(tSQL) into tResult
   
   if tResult is not a number then
      answer error "There was a problem deleting: " & tResult as sheet
   end if
   return tResult
end mdbDeleteByUUID
