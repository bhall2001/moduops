script "fileIo"
/**
creates a new data file
*/
function createNewDataFile
  local tFileName
  local tSQL
  local tResult
  
  local tItemDelim
  
  put saveFileName() into tFileName
  
  if tFileName is not empty then
    
    // ensure filename endds with .mop2
    put the itemDelimiter into tItemDelim
    set the itemDelimiter to "."
    if the last item of tFilename is not "mop2" then
      put ".mop2" after tFileName
    end if
    set the itemDelimiter to tItemDelim
    
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
  
  ask file "Create new file..." with tFileName with type "MOP2 File|mop2|MOP2"
  wait 50 milliseconds with messages
  
  if it is empty then 
    set cursor to arrow
    exit to top
  end if
  
  
  return it
end saveFileName
