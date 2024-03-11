script "stack-script-behavior"

## Script Local Variables
#
local sCarTypeID -- active car type ID

// Version number
local sMajor = 5
local sMinor = 4
local sPatch = 1


##
#  Script Local Setters
#
command setCarTypeID pValue
  put pValue into sCarTypeID
end setCarTypeID


##
#  Script Local Getters
#
function getCarTypeID
  return sCarTypeID
end getCarTypeID


function arraySearch @pArray pItem
  local tIndex
  local tResult
  
  # return 0 if we cannot find an item in the array
  put 0 into tResult
  # get the keys of the array
  get the keys of pArray
  split it by return
  # visit every array element indexed by a key
  repeat for each element tIndex in it
    # test if the current array element is a match with the item we are looking for 
    if pArray[tIndex] = pItem
    then
      put tIndex into tResult
      exit repeat
    end if 
  end repeat
  return tResult
end arraySearch


on closeStackRequest
  local tResult
  
  set the cursor to watch
  set the destroyStack of this stack to true
  quit
  pass closeStackRequest
end closeStackRequest


command uiNewLayout  
  local tFileName
  
  set cursor to watch
  lock screen
  
  get datalayer.disconnect()
  put createNewDataFile() into tFileName
  
  // set the app window title
  updateWindowTitle tFileName  
  goDashboard
  
  unlock screen
  set cursor to arrow
  
  send "mouseUp" to button "Dashboard" of group "sidebarMenu" of group "groupBackground" of me
  
  answer info "Layout file created!"
end uiNewLayout


##
## By RDH 2/9/2016
##
## Resets the file name to the default "untitled.mop"
## and sets the main window title accordingly.
##
command _resetFileName
  local tPath, tDataFile
  put specialFolderPath("Documents") into tDataFile
  put "/untitled.mop" after tDataFile
  
  // set the app window title
  updateWindowTitle tDataFile
  
  ## set the default data file in the main stack
  set the cDataFile of stack "Module Operations" to tDataFile
  
end _resetFileName


command uiLoadLayout
  local tPath, tDataFile
  local tConnect
  
  // get the last file path for file dialog
  put getLastFilePath() into tPath
  
  set the visible of group "blocker" to true
  set the layer of group "blocker" to top
  
  answer file "Please select a layout file" with tPath with type "TEXT File|mop2|MOP2" titled "Open file"
  set the visible of group "blocker" to false
  wait 300 milliseconds
  
  if it is empty then exit uiLoadLayout
  
  put it into tDataFile
  
  // set the last file path
  setLastFilePath tDataFile
  
  openLayoutFile tDataFile
  
  send "mouseUp" to button "Dashboard" of group "sidebarMenu" of group "groupBackground" of me in 100 ticks
  
end uiLoadLayout


/*
load the provided data file

parameters:
pDataFile string full path to data file to open
pSkipUpdateRecent boolean true = skip updting the most recent file list

note: skiping updating of recent file list happens when the app
is first launced and the most recent file is opened. We do not
want to add this file to the most recent menu as it is already
the most recent layout file in the menu
*/
command openLayoutFile pDataFile, pSkipUpdateRecent
  local tConnect
  local tRecentFilesMenu
  
  if pDataFile is empty then exit to top
  
  lock screen
  
  // save selected path for next time
  set the uPrevFilePath of stack "Module Operations" to pDataFile
  
  set cursor to watch
  
  if not pSkipUpdateRecent then
    updateLayoutRecentMenu pDataFile
  end if
  
  updateStatus "Opening File " & pDataFile
  
  // set the app window title
  updateWindowTitle pDataFile
  
  set the cDataFile of stack "Module Operations" to pDataFile
  
  updateStatus "Reading Data..."
  
  put datalayer.connect(the cDataFile of stack "Module Operations") into tConnect
  
  // migrate older databases to include any new information...
  datalayer.migrate
  
  set itemdelimiter to slash
  updateStatus ""
  
  if the short name of this card is "Dashboard" then
    dispatch "openCard" to card "Dashboard"
  else
    dispatch "mouseUp" to button "Dashboard"
  end if
  
  goDashboard
  set the cursor to arrow
  unlock screen
  
  answer info "Layout file loaded!" titled "Open file..."
end openLayoutFile



/*
converts a legacy .mop file to a .mop2 format
*/
command uiConvertFile
  local tPath
  local tDataFile
  local tInputData
  local tSaveData
  local tFileName
  
  get datalayer.disconnect()
  put createNewDataFile() into tFileName
  
  // set the app window title
  updateWindowTitle tFileName
  
  // load old file
  put specialFolderPath("Documents") into tPath
  
  set the visible of group "blocker" to true
  set the layer of group "blocker" to top
  
  answer file "Select file to convert..." with tPath with type "MOP File|mop|MOP"
  set the visible of group "blocker" to false
  wait 300 milliseconds
  
  // process old file adding records to the database
  if it is not empty then
    put it into tDataFile
    set cursor to watch
    
    updateStatus "Opening File " & tDataFile
    updateStatus "Reading Data..."
    
    put URL ("binfile:" & tDataFile) into tInputData
    decrypt tInputData using "blowfish" with "moduops5"
    put it into tInputData
    
    put arrayDecode(tInputData) into tSaveData
    
    // convert carType
    updateStatus "Converting Equipment..."
    get carType.deleteAll()
    
    local tCarTypeA
    repeat for each element aCarType in tSaveData["carType"]
      put empty into tCarTypeA
      put legacy.carTypeDto(aCarType) into tCarTypeA
      get carType.create(tCarTypeA)
    end repeat
    
    // convert spots
    updateStatus "Converting Spots..."
    get spot.deleteAll()
    
    local tSpotA
    repeat for each element aSpot in tSaveData["spot"]
      put empty into tSpotA
      put legacy.spotDto(aSpot) into tSpotA
      get spot.create(tSpotA)
    end repeat
    
    // convert modules
    updateStatus "Converting Modules..."
    get module.deleteAll()
    
    local tModuleA
    repeat for each element aModule in tSaveData["module"]
      put empty into tModuleA
      put legacy.moduleDto(aModule) into tModuleA
      get module.create(tModuleA)
    end repeat
    
    // convert consignees
    updateStatus "Converting Consignees..."
    get consignee.deleteAll()
    
    local tConsigneeA
    repeat for each element aConsignee in tSaveData["consignee"]
      put empty into tConsigneeA
      put legacy.consigneeDto(aConsignee) into tConsigneeA
      get consignee.create(tConsigneeA)
    end repeat
    
    // convert workorders
    updateStatus "Converting Workorders..."
    get workorder.deleteAll()
    
    local tWorkorderA
    repeat for each element aWorkorder in tSaveData["workorder"]
      put empty into tWorkorderA
      put legacy.workorderDto(aWorkorder) into tWorkorderA
      get workorder.create(tWorkorderA)
    end repeat
    
    // convert trains
    updateStatus "Converting Trains..."
    get train.deleteAll()
    
    local tTrainA
    repeat for each element aTrain in tSaveData["train"]
      put empty into tTrainA
      put legacy.trainDto(aTrain) into tTrainA
      get train.create(tTrainA)
    end repeat
    
    // convert manifests
    updateStatus "Converting Manifests..."
    get manifest.deleteAll()
    
    local tManifestA
    repeat for each element aManifest in tSaveData["manifest"]
      put empty into tManifestA
      put legacy.manifestDto(aManifest) into tManifestA
      get manifest.create(tManifestA)
    end repeat
    
    // convert config
    updateStatus "Converting Configurations..."
    get config.deleteAll()
    
    repeat for each key aConfig in tSaveData["config_data"][1]      
      if aConfig = "UUID" then
        next repeat
      end if
      
      get config.set(aConfig, tSaveData["config_data"][1][aConfig])
    end repeat
  end if
  
  updateStatus ""
  
  goDashboard
end uiConvertFile


function populateTable pTable, tDataA
  local tResult
  
  updateStatus "Loading " & pTable & " data..."
  put mdbArrayToTable(pTable, tDataA) into tResult
  
  if tResult is not a number then
    updateStatus tResult
    answer "Error loading " & pTable & " table"
    exit to top
  end if
  
  updateStatus ""
end populateTable


function saveData
  return empty
end saveData


command goesInta
  ## Bug in LC 8 prevents this from working. Removed.
  ## set cursor to hand
  --  lock cursor
  
  // if there is no file loaded just exit
  if the cDataFile of stack "Module Operations" is empty then
    exit goesInta
  end if
  
  
  if the backgroundColor of the target is not "#008080" then
    set the backgroundColor of the target to "#4C4C4C"
    set the foregroundColor of the target to "#FFFFFF"
  end if
end goesInta


command goesOuta
  if the backgroundColor of the target is not "#008080" then
    set the backgroundColor of the target to "#2E2E2E"
    set the foregroundColor of the target to "#969696"
  end if
  ## Bug in LC 8 prevents this from working. Removed.
  ## unlock cursor
end goesOuta


on mouseLeave
  ## Bug in LC 8 prevents this from working. Removed.
  ## set cursor to arrow
  ## unlock cursor
end mouseLeave


command updateSidebarUI
  local lBtnCT, tButtonID
  
  put the number of buttons of group "sidebarMenu" into lBtnCT
  
  repeat with i = 1 to lBtnCT
    put the id of button i of group "sidebarMenu" into tButtonID
    set the backgroundColor of button ID tButtonID of group "sidebarMenu" to "#2E2E2E"
    set the foregroundColor of button ID tButtonID of group "sidebarMenu" to "#969696"
  end repeat
end updateSidebarUI


on openCard
  if there is a field "cardName" then
    put the short name of this card into field "cardName"
  end if
  pass openCard
end openCard


function linearArrayIndex @pArray
  local i, tArray
  put 1 into i
  repeat for each element aLine in pArray
    put aLine into tArray[i]
    add 1 to i      
  end repeat
  return tArray
end linearArrayIndex


command updateStatus pMsg
  set the text of field "Status" to pMsg
  wait 25 milliseconds
  unlock screen
  lock screen
end updateStatus


function wordWrappedHTML pText,pMaxLength
  local tWrappedText
  
  if pMaxLength is empty or pMaxLength is not a number then
    ## use a default value if maxLength is not provided
    put 75 into pMaxLength
  end if
  
  if pMaxLength is not an integer then
    ## truncate it
    put trunc(pMaxLength) into pMaxLength
  end if
  
  repeat for each line tLine in pText
    if length(tLine) <= pMaxLength then
      ## the line is shorter than the maximum
      ## so we can leave it as it is
      put tLine & return after tWrappedText
    else 
      ## tLine is longer than the maximum
      repeat until tLine is empty
        ## try to break the line at a space
        repeat with x = pMaxLength down to 1
          if char x of tLine is space or length(tLine) < pMaxLength then
            put (char 1 to x-1 of tLine) & "<br />" &  return after tWrappedText
            delete char 1 to x of tLine
            exit repeat
          end if
        end repeat
        
        if x = 1 then
          ## no spaces in the first pMaxLength chars
          ## so we break it at that number of characters
          put char 1 to pMaxLength of tLine & "<br />" &  return after tWrappedText
          delete char 1 to pMaxLength of tLine
        end if
      end repeat
    end if
  end repeat
  
  put replaceText(tWrappedText, "</p><br />", "</p>") into tWrappedText
  return tWrappedText
end wordWrappedHTML


command sendJson
  local tJsonData, tSequence, oldDelimiter, ftpPath
  
  put the dgText of group "dgSequence" of card "Train Sequence" into tSequence
  
  put "{" & return & quote & "data" & quote & ": [" & return into tJsonData
  
  put the itemDelimiter into oldDelimiter
  set the itemDelimiter to tab
  repeat with i = 1 to number of lines of tSequence
    if item 2 of line i of tSequence <> "void" then
      put "[" & return after tJsonData
      put quote & item 2 of line i of tSequence & quote & comma & return after tJsonData
      put quote & item 3 of line i of tSequence & quote & comma & return after tJsonData
      put quote & item 4 of line i of tSequence & quote & comma & return after tJsonData
      put quote & item 5 of line i of tSequence & quote & return after tJsonData
      put "]" & comma & return after tJsonData
    end if
  end repeat
  set the itemDelimiter to oldDelimiter
  
  delete last char of tJsonData
  delete last char of tJsonData
  put return & "]" & return & "}" after tJsonData
  
  ## Set the path for the Json paths
  put getFTPPath() into  ftpPath
  
  ## Output JSON files to the server
  --   put tJsonData into URL (ftpPath & "/arrays.txt")
end sendJson


## 
## Return the ftp path for the current event
##
private function getFTPPath
  local ftpPath
  ## Set the ftp location
  
  return ftpPath
end getFTPPath


/**
* Returns a list of all trains as an array
*/
function trainsAsArray
  local tTrainsA
  local tTempA
  
  // get all trains from the DB
  put train.findMany() into tTrainsA
  
  // add Yard origin and destination names to the array
  repeat for each key aKey in tTrainsA
    put yard.nameById(tTrainsA[aKey]["origin"]) into tTempA
    put tTempA["spot"] into  tTrainsA[aKey]["originName"]
    
    put empty into tTempA
    
    put yard.nameById(tTrainsA[aKey]["destination"]) into tTempA
    put tTempA["spot"] into tTrainsA[aKey]["destinationName"]
  end repeat
  
  return tTrainsA
end trainsAsArray

/**
* Displays an error dialog
*
* @paramter pError string
*/
on uiDisplayError pError
  answer error pError
end uiDisplayError


/**
* Converts an Associative array to an Index Array.
* Order is not guarenteed and infact, expect to be different
* even when calling with an identical data set
*
* @parameter pAssociativeA
* @returns pIndexA | ""
*/
function indexArray @pAssociativeA
  local tIndexA, i
  
  if pAssociativeA is not an array then
    return ""
  end if
  
  put 1 into i
  repeat for each key aRecord in pAssociativeA
    put pAssociativeA[aRecord] into tIndexA[i]
    add 1 to i
  end repeat
  
  return tIndexA
end indexArray


function myVersion
  return (sMajor & "." & sMinor & "." & sPatch)
end myVersion


on preOpenStack
  local tPath, tDataFile
  
  put the effective filename of this stack into tPath
  set the itemDelimiter to "/"
  delete the last item of tPath
  set the cAppPath of stack "Module Operations" to tPath
  
  set the cDataFile of stack "Module Operations" to empty
  
  // set the app window title
  updateWindowTitle  
  
  // start at the Dashboard screen
  send "mouseUp" to button "Dashboard" of stack "Module Operations"
  
  ## Set default filename and set the Window Name
  
  if environment() is "development" then
    loggerOpenLogMonitor
  end if
  --  _resetFileName
end preOpenStack



on appleEvent pClass, pEventID, pSender
  local tFileName
  
  if pClass is "aevt" and pEventID is "odoc" then         
    request appleEvent data
    put it into tFileName
    
    // load the file ddatalayer.get(pTableName, pDataA)
    openLayoutFile tFileName
  end if
  pass appleEvent   
end appleEvent



on suspendStack
  if "Answer Dialog" is among the lines of the openStacks then
    set the loc of stack "answer dialog" to the loc of stack "Module Operations"
  end if
  
  pass suspendStack
end suspendStack
