script "stack-script-behavior"

## Script Local Variables
#
local sCarTypeID -- active car type ID

// Version number
local sMajor = 2022
local sMinor = 0
local sPatch = 0


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


on closeStack
  local tResult
  set the cursor to watch
  save this stack
  pass closeStack
end closeStack


on uiSaveData
  --   local tPath, tSaveData, theEncodedArray, tDataFile
  
  --   put the cDataFile of stack "Module Operations" into tDataFile
  
  --   ## Check if the user as created a file or is using the default empty file
  --   if (tDataFile is empty) or ("/untitled.mop" is in tDataFile) then
  
  --      ## We'll reset the filename and reload tData
  --      _resetFileName
  --      put the cDataFile of stack "Module Operations" into tDataFile
  
  --      ## Get the user to save the file somewhere
  --      ask file "Save data as" with tDataFile
  --      if it is not empty then
  --         put it into tDataFile
  
  --         set the itemdelimiter to "."
  --         if the last item of tDataFile is not "mop" then
  --            put ".mop" after tDataFile
  --         end if
  --      else
  --         --answer "No File Selected"
  --         _resetFileName
  --         exit uiSaveData
  --      end if
  --   end if
  
  --   set the label of stack "Module Operations" to tDataFile & " - Module Operations"
  
  --   set the cDataFile of stack "Module Operations" to tDataFile
  
  --   updateStatus("")
  --   put mdbTableToArray("config_data") into tSaveData["config_data"]
  
  --   updateStatus("Processing Data...")
  --   put mdbTableToArray("carType") into tSaveData["carType"]
  
  --   updateStatus("")
  --   put mdbTableToArray("manifest") into tSaveData["manifest"]
  
  --   updateStatus("Processing Data...")
  --   put mdbTableToArray("train") into tSaveData["train"]
  
  --   updateStatus("")
  --   put mdbTableToArray("workorder") into tSaveData["workorder"]
  
  --   updateStatus("Processing Data...")
  --   put mdbTableToArray("consignee") into tSaveData["consignee"]
  
  --   updateStatus("")
  --   put mdbTableToArray("spot") into tSaveData["spot"]
  
  --   updateStatus("Processing Data...")
  --   put mdbTableToArray("module") into tSaveData["module"]
  --   updateStatus("")
  
  --   updateStatus("Saving File...")
  --   put arrayEncode(tSaveData) into theEncodedArray
  --   encrypt theEncodedArray using "blowfish" with "moduops5"
  --   put it into theEncodedArray
  --       
  --   put theEncodedArray into URL ("binfile:" & tDataFile)
  --   updateStatus("")
  
  --   set cursor to arrow
  
  --   set the itemdelimiter to "/"
  --   //answer "File" && last item of tDataFile && "saved." with "OK"
end uiSaveData


on uiSaveAs
  --   local tDataFile, trslt
  --   put the cDataFile of stack "Module Operations" into tDataFile
  
  --   ask file "Save data as" with tDataFile
  --   put it into tDataFile
  --   set the itemdelimiter to "."
  --   if the last item of tDataFile is not "mop2" then
  --      put ".mop2" after tDataFile
  --   end if
  
  --   set the cDataFile of stack "Module Operations" to tDataFile
  --   uiSaveData
end uiSaveAs


on uiNewData   
  local tFileName
  
  get datalayer.disconnect()
  put createNewDataFile() into tFileName
end uiNewData


##
## By RDH 2/9/2016
##
## Resets the file name to the default "untitled.mop"
## and sets the main window title accordingly.
##
on _resetFileName
  local tPath, tDataFile
  put specialFolderPath("Documents") into tDataFile
  put "/untitled.mop" after tDataFile
  
  ## set the main window title bar indicating filename
  set the label of stack "Module Operations" to tDataFile & " - Module Operations"
  
  ## set the default data file in the main stack
  set the cDataFile of stack "Module Operations" to tDataFile
  
end _resetFileName


on uiLoadData
  local tPath, tDataFile
  local tConnect
  
  put specialFolderPath("Documents") into tPath
  
  set the visible of graphic "blocker"  to true
  --answer file "Input:" with tPath with type "*.mop,*.MOP"
  answer file "Input:" with tPath with type "mop2"
  set the visible of graphic "blocker"  to false
  wait 300 milliseconds
  
  if it is not empty then
    put it into tDataFile
    
    set cursor to watch
    
    updateStatus "Opening File " & tDataFile
    set the label of stack "Module Operations" to tDataFile & " - Module Operations"
    
    set the cDataFile of stack "Module Operations" to tDataFile
    
    updateStatus "Reading Data..."
    
    put datalayer.connect(the cDataFile of stack "Module Operations") into tConnect
    
    set itemdelimiter to slash
    updateStatus ""
    
    if the short name of this card is "Dashboard" then
      dispatch "openCard" to card "Dashboard"
    else
      dispatch "mouseUp" to button "Dashboard"
    end if
    
    set the cursor to arrow
  end if
end uiLoadData


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


on goesInta
  ## Bug in LC 8 prevents this from working. Removed.
  ## set cursor to hand
  lock cursor
  if the backgroundColor of the target is not "#008080" then
    set the backgroundColor of the target to "#4C4C4C"
    set the foregroundColor of the target to "#FFFFFF"
  end if
end goesInta


on goesOuta
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


on updateSidebarUI
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

on sendJson
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
  
  ## Set default filename and set the Window Name
  _resetFileName
end preOpenStack
