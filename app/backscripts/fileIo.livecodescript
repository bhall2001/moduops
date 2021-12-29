script "fileIo"
/**
creates a new data file
*/
function createNewDataFile
  local tFileName
  local tSQL
  local tResult
  
  put saveFileName() into tFileName
  
  if tFileName is not empty then
    
    set the cDataFile of stack "Module Operations" to tFileName
        
    // check if there's an open default db
    if dbGetDefaultConnectionID() is a number then
      // close the current open default database
      revCloseDatabase dbGetDefaultConnectionID()
    end if
    
    get datalayer.create_db(the cDataFile of stack "Module Operations")
    
    // build db schema
    // sql to initialize new database
    put the sql_create_db of stack "Module Operations" into tSQL
    
    put datalayer.execute(tSQL) into tResult
    wait 1 sec with messages
  end if
  
  return tFileName
end createNewDataFile


/**
asks user for a new filename

returns selected filename or empty
*/
function saveFileName
  local tFileName
  
  put specialFolderPath("Documents") & "/untitled.mop2" into tFileName
  
  set the itemDelimiter to slash

  ask file "Input:" with tFileName with type "Text|sqlite|mop2"
  wait 50 milliseconds with messages
  
  return it
end saveFileName
