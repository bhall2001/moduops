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
    
    // set the most recent file path
    setLastFilePath tFileName
    
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
    
    // update the recent menu with this new file
    updateLayoutRecentMenu tFileName
    
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
  
  put getLastFilePath() & "/untitled.mop2" into tFileName
  
  set the itemDelimiter to slash
  
  ask file "Create new file..." with tFileName with type "MOP2 File|mop2|MOP2"
  wait 50 milliseconds with messages
  
  put it into tFileName
  
  if tFileName is empty then 
    set cursor to arrow
    exit to top
  end if
  
  setLastFilePath tFileName
  
  return tFileName
end saveFileName



/*
returns the most recent data file path or the path to the documents
directory if there is not a previous file location. If the path is not
set returns the path to the users Document directory

parameters:
pKey string options key to get, defaults to "lastFilePath"
*/
function getLastFilePath pKey
  local tKey
    
  if pKey is empty then
    put "lastFilePath" into tKey
  else
    put pKey into tKey
  end if
  
  if prefsIsPrefSet(tKey) = true then
    return URLDecode(prefsGetPref(tKey))
  else
    return specialFolderPath("Documents")
  end if
end getLastFilePath



/*
set the last file path given a path to a file

parameters:
pFilename string full path to a file INCLUDING file name
pKey options filepath key used to store pref. Defaults to "lastFilePath"
*/
command setLastFilePath pFileName, pKey
  local tFileName
  local tKey
  
  if pFileName is empty then exit setLastFilePath
  
  put pKey into tKey
  
  if tKey is empty then
    put "lastFilePath" into tKey
  end if
  
  set the itemDelimiter to "/"
  put pFileName into tFileName
  delete the last item of tFileName
  
  prefsSetPref tKey, URLEncode(tFileName)
end setLastFilePath
