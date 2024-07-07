script "card-trainlists-behavior"
local sPageWidth, sManifestStyle
local sTrainUUID
local sTrainsA // all trains
local sTrainA // the selected train
local sTrainRouteA
local sModuleA
local sConsigneeA
local sSpotA
local sManifestA
local sCarTypeA
local sPrevModule, sPrevConsignee, sPrevSpot
local sSchedPrevModule
local sFieldList = "Column1,Header1,Footer1,Column2,Header2,Footer2"



on buildManifest
  local tManifest, tTempA
  local tSwitchListA
  
  put the cWidth of this card into sPageWidth
  put the cPageStyle of this card into sManifestStyle
  put the cTrainUUID of card "Trainlists" into sTrainUUID
  put train.findOne(sTrainUUID) into sTrainA
  put sTrainA["route"] into tTempA
  put jsonToArray(tTempA) into sTrainRouteA
  
  -----
  local manifest,tActiveTrain,tTrains
  local tCarID,theCarName,tWOID
  local tConsigneeID,theConsigneeName,theSpotName
  local tCarTypes,tModules
  local tModuleID,manifestRemarks,tSpotID
  local trainManifest,moduleName,theModule
  local tSpots,tWorkorders,tConsignees
  local tOutput
  local tSwitchListColumn2
  local tSortedList
  local tSortedModuleList
  -----
  
  // clear variables
  
  
  lock screen
  
  put "" into tManifest
  put "" into field "trainlist"
  
  if sManifestStyle = "SwitchList" then
    -- Train Manifest
    put __generateSwitchListManifest() into tSwitchListA
    put tSwitchListA["switchListTowns"] into field "switchListTowns" of card 1 of stack "switchlist"
    put tSwitchListA["switchList"] into field "switchList" of card 1 of stack "switchlist"
    put tSwitchListA["switchListTowns"] into field "switchListTowns" of card 1 of stack "switchlist2"
    put tSwitchListA["switchList"] into field "switchList" of card 1 of stack "switchlist2"
    put config.get("name") into field "Header1" of card 1 of stack "switchlist"
    put config.get("name") into field "Header1" of card 1 of stack "switchlist2"
    put "" into tOutput
    
    -- Manifest Header
    put outputHeader(sTrainA) after tSwitchListColumn2
    
    -- Train Origin, Car Count & Length
    put outputTrainOrigin(sTrainA, sPageWidth) after tSwitchListColumn2
    
    -- Crew Instruction
    put outputCrewInstructions(sTrainA) after tSwitchListColumn2
    
    -- Train Manifest
    put addManifest(sManifestStyle, sPageWidth) after tSwitchListColumn2
    
    put "<br /><br />" after tSwitchListColumn2
    
    // output a key of car types
    // sort the car types
    get the keys of tSwitchListA["carTypes"]
    sort lines of it ascending
    put it into tSortedList
    
    // loop over sorted list of car types outputing what is needed
    put "<b>Equipment Reference</b><br />"& return after tSwitchListColumn2
    repeat for each line aCarType in tSortedList
      put ""& aCarType & " - " after tSwitchListColumn2
      repeat for each item aCar in tSwitchListA["carTypes"][aCarType]
        put aCar & ", " after tSwitchListColumn2
      end repeat
      delete last char of tSwitchListColumn2
      delete last char of tSwitchListColumn2
      put "<br />" & return after tSwitchListColumn2
    end repeat
    
    put tOutput & "<br />"after tSwitchListColumn2
    
    put empty into tSortedList
    
    // output track reference
    // sort the module list
    get the keys of tSwitchListA["tracks"]
    sort lines of it ascending
    put it into tSortedModuleList
    
    repeat for each line aModule in tSortedModuleList
      put "<b>" & aModule & "</b><br />" & return after tSwitchListColumn2
      
      // sort the track keys
      get the keys of tSwitchListA["tracks"][aModule]
      sort lines of it ascending
      put it into tSortedList
      
      repeat for each line aTrack in tSortedList
        put aTrack && "-" && tSwitchListA["tracks"][aModule][aTrack] &"<br />" & return  after tSwitchListColumn2
      end repeat
      put "<br />" after tSwitchListColumn2
    end repeat
    
    delete last line of tSwitchListColumn2
    --    exit buildManifest
    
  else
    
    -- Manifest Header
    put outputHeader(sTrainA) after tManifest
    
    -- Train Origin, Car Count & Length
    put outputTrainOrigin(sTrainA, sPageWidth) after tManifest
    
    -- Crew Instruction
    put outputCrewInstructions(sTrainA) after tManifest
    
    -- Train Manifest
    put addManifest(sManifestStyle, sPageWidth) after tManifest
    
  end if
  
  -- Termination Instructions
  put outputTerminationInstructions(sTrainA) after tManifest
  
  -- Footer
  put outputFooter(sTrainA, sPageWidth) after tManifest
  
  set the htmlText of field "trainlist" to tManifest
  if sPageWidth = "Half" then
    put the htmlText of field "trainlist" into tManifest
    
    --dispatch "outputTwoColumns" with tManifest
    put outputTwoColumns(tManifest) into tManifest
    
  end if
  
  set the htmlText of field "trainlist" to tManifest
  
  switch sManifestStyle
    case "MRBT"
      set the textfont of cd fld "trainlist" to "Courier New"
      set the visible of image "stack thumbnail" of me to false
      break
    case "Modern"
      set the textfont of cd fld "trainlist" to "Arial"
      set the visible of image "stack thumbnail" of me to false
      break
    case "SwitchList"
      set the HTMLText of field "Column2" of card 1 of stack "switchlist" to tSwitchListColumn2 & tManifest
      set the HTMLText of field "Column2" of card 1 of stack "switchlist2" to tSwitchListColumn2
      set the HTMLText of field "Column3" of card 1 of stack "switchlist2" to tManifest
      put sTrainA["symbol"] into field "trainSymbol" of card 1 of stack "switchlist"
      put sTrainA["symbol"] into field "trainSymbol" of card 1 of stack "switchlist2"
      
      CreateThumbnail "switchlist"
      set the visible of image "stack thumbnail" of me to true
      set the htmltext of field "trainlist" to empty
      
      break
  end switch
  
  --  if sManifestStyle = "MRBT" then
  --    set the textfont of cd fld "trainlist" to "Courier New"
  --  else if sManifestStyle = "Modern" then
  --    set the textfont of cd fld "trainlist" to "Arial"
  --  end if
  
  
  
  unlock screen
end buildManifest






function addManifest pManifestStyle pPageWidth
  local tOutput, tIndex, tManifestA, tFlag
  
  put empty into sManifestA
  
  ## load in all cars for a train into the Manifest
  if the cSchedulingEngine of stack "Module Operations" = "Random" then
    put mrbt.output(sTrainUUID) into sManifestA
  else
    put smarty.output(sTrainUUID) into sManifestA
  end if
  
  ## add in all train orders of a route into the Manifest
  put 1 into tIndex
  put "" into tManifestA
  
  repeat for each element aStop in sTrainRouteA
    if aStop["moduleId"] is empty then -- we have a Train Order
      
      ## Insert Train Order into the correct order of the Train's Manifest
      put "" into tManifestA
      put 1 into tIndex
      put false into tFlag
      repeat with i = 1 to the number of elements of sManifestA
        if not tFlag and (sManifestA[i]["stop"] > aStop["stop"]) then -- We found the point Train Order belongs
          put aStop["stop"] into tManifestA[tIndex]["stop"]
          put aStop["consignee"] into tManifestA[tIndex]["description"]
          add 1 to tIndex
          put true into tFlag
        end if
        put sManifestA[i] into tManifestA[tIndex]
        add 1 to tIndex
      end repeat
      if not tFlag then -- hit the end of the list so add in the Train Order
        put aStop["stop"] into tManifestA[tIndex]["stop"]
        put aStop["consignee"] into tManifestA[tIndex]["description"]
      end if
      put tManifestA into sManifestA
    end if
  end repeat
  
  if tManifestA is not empty then
    put tManifestA into sManifestA
  end if
  
  -- Format each line of work scheduled for a train
  ##put "<p><font size=8>" after manifest
  put "" into sPrevModule
  
  switch pManifestStyle
    case "SwitchList"
      return __generateSwitchlistInstructions("half")
      break
    default
      return __generateTextManifest(pManifestStyle, pPageWidth)
  end switch
end addManifest




function __generateSwitchlistInstructions pPageWidth
  local tOutput
  local tResultA
  
  repeat for each element aWorkorder in sManifestA
    if aWorkorder["moduleRemarks"] is not empty then
      put aWorkorder["moduleRemarks"] into tResultA[aWorkOrder["moduleId"]]["moduleRemarks"]
      put aWorkorder["moduleName"] into tResultA[aWorkOrder["moduleId"]]["moduleName"]
    end if
    
    if aWorkorder["consigneeRemarks"] is not empty then
      put aWorkorder["consigneeRemarks"] into tResultA[aWorkOrder["moduleId"]]["consignee"]["consigneeId"]["consigneeRemarks"]
      put aWorkorder["consigneeName"] into tResultA[aWorkOrder["moduleId"]]["consignee"]["consigneeId"]["consigneeName"]
      put aWorkorder["moduleName"] into tResultA[aWorkOrder["moduleId"]]["moduleName"]
    end if
  end repeat
  
  repeat for each key moduleId in tResultA
    put "<br /><p><b>" & tResultA[moduleId]["moduleName"] & "</b></p>" & return after tOutput
    if tResultA[moduleId]["moduleRemarks"] is not empty then
      put "<p>" & tResultA[moduleId]["moduleRemarks"] & "</p>" & return after tOutput
    end if
    repeat for each key consigneeId in tResultA[moduleId]["consignee"]
      put "<p>" & tResultA[moduleId]["consignee"][consigneeId]["consigneeName"] & "</p>" & return after tOutput
      put formatRemarks( tResultA[moduleId]["consignee"][consigneeId]["consigneeRemarks"] ) after tOutput
    end repeat
  end repeat
  
  --  ## Check if this is a Train Order and add to output
  --  if aWorkorder["workorderId"] = "" then
  --    put "<p>" & aWorkorder["description"] & "</p>" after tOutput
  --    next repeat
  --  end if
  
  --  -- Module Name only when there's a new module in Manifest
  --  if aWorkorder["moduleName"] <> sPrevModule then      
  --    put  "<p><b>" & aWorkorder["moduleName"] & "</b></p>" & return after tOutput
  
  --    -- Add module remarks
  --    if aWorkOrder["moduleRemarks"] is not empty then
  --      put formatRemarks(aWorkOrder["moduleRemarks"]) after tOutput
  --    end if
  
  --    put aWorkorder["moduleName"] into sPrevModule
  --  end if
  
  --  -- output work order remarks on next line
  --  if aWorkorder["workOrderRemarks"] <> empty then
  --    put "<p>" & aWorkorder["workOrderRemarks"] & "</p>" & return after tOutput
  --  end if
  
  --    put outputSpot(pManifestStyle, pPageWidth, aWorkorder) after tOutput
  
  -- output car remarks on next line
  --    if aWorkorder["carTypeRemarks"] <> empty then
  --      put "<p>" & aWorkorder["carTypeRemarks"] & "</p>" & return after tOutput
  --    end if
  return tOutput
end __generateSwitchlistInstructions



/*
generates the text version of the manifest. This is the "long" form
of the manifest used originally for the modern version of the trainlist
*/
function __generateTextManifest pManifestStyle, pPageWidth
  local tOutput
  
  repeat for each element aWorkorder in sManifestA
    
    ## Check if this is a Train Order and add to output
    if aWorkorder["workorderId"] = "" then
      put "<p>" & aWorkorder["description"] & "</p>" after tOutput
      next repeat
    end if
    
    -- Module Name only when there's a new module in Manifest
    if aWorkorder["moduleName"] <> sPrevModule then      
      put outputModuleName(pManifestStyle, aWorkorder["moduleName"], aWorkorder["stop"]) after tOutput
      
      -- Add module remarks
      if aWorkOrder["moduleRemarks"] is not empty then
        put formatRemarks(aWorkOrder["moduleRemarks"]) after tOutput
      end if
      
      put aWorkorder["moduleName"] into sPrevModule
    end if
    
    -- output work order remarks on next line
    if aWorkorder["workOrderRemarks"] <> empty then
      put "<p>" & aWorkorder["workOrderRemarks"] & "</p>" & return after tOutput
    end if
    
    put outputSpot(pManifestStyle, pPageWidth, aWorkorder) after tOutput
    
    -- output car remarks on next line
    if aWorkorder["carTypeRemarks"] <> empty then
      put "<p>" & aWorkorder["carTypeRemarks"] & "</p>" & return after tOutput
    end if
  end repeat
  return tOutput
end __generateTextManifest



constant STARS = "******************************"
--constant STARS = ""

function __generateSwitchListManifest
  local tOutputA
  local tCarTypeA
  local i
  local tOrigin
  local tPrevOrigin
  local tTrackA
  
  put 0 into i
  
  put "" into sSchedPrevModule
  
  put smarty.output(sTrainUUID) into sManifestA
  
  put yard.findOne(sTrainA["origin"]) into tOrigin
  
  repeat for each element aWorkorder in sManifestA
    add 1 to i
    // see if we are over the limit for output currently 27 lines
    if i > 27 then next repeat
    
    if aWorkorder["moduleName"] <> sSchedPrevModule then
      put STARS && toUpper(aWorkorder["moduleName"]) && STARS & return after tOutputA["switchListTowns"]
      put return after tOutputA["switchList"]
      put aWorkorder["moduleName"] into sSchedPrevModule
    end if
    
    put return after tOutputA["switchListTowns"]
    
    put tab & aWorkorder["code"] & "-" & aWorkorder["length"] & tab after tOutputA["switchList"]
    if tOrigin["track"] <> tPrevOrigin then
      put tOrigin["track"] & tab after tOutputA["switchlist"]
      put tOrigin["track"] into tPrevOrigin
    else
      put "  ''" & tab after tOutputA["switchlist"]
    end if
    put aWorkorder["track"] & return after tOutputA["switchList"]
    
    // add a car type description if it does not already exist
    if aWorkorder["description"] is not among the items of tCarTypeA[aWorkorder["code"]] then
      put aWorkorder["description"] & "," after tCarTypeA[aWorkorder["code"]]
    end if
    
    // add track references
    if tTrackA[aWorkorder["moduleName"]][aWorkorder["track"]] is empty then
      put aWorkorder["spot"] into tTrackA[aWorkorder["moduleName"]][aWorkorder["track"]]
    end if
    
  end repeat
  
  put tCarTypeA into tOutputA["carTypes"]
  put tTrackA into tOutputA["tracks"]
  
  return tOutputA
end __generateSwitchListManifest



on openCard
  local tFavor
  
  lock screen
  
  put train.findMany() into sTrainsA
  set the dgData of group "dgTrains" to train.addNames(sTrainsA)
  
  put "" into cd fld "trainlist"
  
  put config.get("favorSlider") into tFavor
  set the hilite of button "useCode" to config.get("useCode") is 1
  
  if tFavor is a number then
    set the thumbPosition of scrollbar "favorScale" of card "Trainlists" to tFavor
  else
    set the thumbPosition of scrollbar "favorScale" of card "Trainlists" to 1
  end if
  
  // update layout name field
  put config.get("name") into field "layoutName"
  
  unlock screen
  
  pass openCard
end openCard


on closeCard
  put "" into cd fld "trainlist"
end closeCard


/*
Output the car type description/class/short/code and Consignee. Information is on
one line of the train's Manifest
*/
function outputSpot pManifestStyle pPageWidth pDataA
  local tTemp, tCharCount
  local tResult, tConsignee, tCarDesc
  local tCarCode
  
  // Determine the format of the Car Short Description or Code. This is based
  // on the checkbox to use Car Type Code in UI
  if (the hilite of button "useCode") and (pDataA["code"] is not "") then
    put pDataA["code"] into tCarCode
  else
    if pPageWidth = "Half" then
      if pDataA["class"] is not " " \
            and pDataA["class"] is not empty \
            and sManifestStyle is not "MRBT" then
        put pDataA["class"] & "-" & char 1 to 12 of pDataA["short"] into tCarCode
      else
        put char 1 to 12 of pDataA["short"] into tCarCode
      end if
    else
      put pDataA["description"] into tCarCode
    end if
  end if
  
  // output selected equipment
  put tCarCode && pDataA["Length"] into tCarDesc
  if pPageWidth is "full" or (pPageWidth is "half" and pManifestStyle is not "MRBT") then
    put "'" after tCarDesc
  end if
  
  
  put "" into tResult
  
  if pDataA["consigneeName"] <> sPrevConsignee then
    if pDataA["consigneeRemarks"] is not empty then
      put formatRemarks( pDataA["consigneeRemarks"] ) after tResult
    end if
  end if
  
  put pDataA["consigneeName"] into sPrevConsignee
  
  switch pManifestStyle
    case "Modern"
      -- start with a place for a check mark and the reporting marks of rollingstock
      put "<p>[ ] Set Out ________________ " after tResult
      
      -- now put in either the car code or description based on radio button in UI
      ##if the hilite of button "1/2 Page Width" then
      ##put tCarTypes[tCarID]["Short"] & " (" & tCarTypes[tCarID]["Length"] &  ")" after manifest
      ##else
      --put tTemp after tResult
      ##end if
      put tCarDesc after tResult
      
      if pPageWidth="Half" then
        put "</p><p>      " after tResult
      end if
      
      put " to " & pDataA["spot"] after tResult
      /*
      put " to " & pDataA["consigneeName"] after tResult
      
      // RDH THIS IS LIKELY NEEDING SOME FIXING
      if pDataA["consigneeName"] <> pDataA["spot"] then
        put " " & pDataA["spot"] after tResult
      end if
      */
      break
    case "MRBT"
      /*
      put "  " & pDataA["consigneeName"] into tTemp
      if pDataA["consigneeName"] <> pDataA["spot"] then
        put " " & pDataA["spot"] after tTemp
      end if
      */
      
      put " " & pDataA["spot"] after tTemp
      
      put number of characters of tTemp into tCharCount
      
      if pPageWidth = "Half" then
        if number of chars of tTemp > 15 and last word of tTemp is a number then
          put character 1 to 13 of tTemp & character -2 to -1 of tTemp into tTemp
          --          put character 1 to 15 of tTemp into tTemp
          
        else
          put "                                " after tTemp
          put character 1 to 15 of tTemp into tTemp
        end if
      else
        if tCharCount > 31 then
          put character 1 to 16 of tTemp & "-" & character (tCharCount-14) to tCharCount of tTemp into tTemp
        else
          put "                                " after tTemp
          put character 1 to 34 of tTemp into tTemp
        end if
      end if
      
      put "  " after tTemp
      
      put tCarDesc after tTemp
      
      local tRowChars
      
      if sManifestStyle = "MRBT" then
        put 31 into tRowChars
      else 
        put 34 into tRowChars
      end if
      
      if pPageWidth = "half" then
        put "                                                     " after tTemp
        put char 1 to tRowChars of tTemp into tTemp
        put " ___________________" after tTemp
      else
        put "                                                  " after tTemp
        put character 1 to 56 of tTemp into tTemp
        
        put " ___________________ " after tTemp
      end if
      
      if pPageWidth="Half" then
        put character 1 to 46 of tTemp & "<br />" & return after tResult
      else
        put tTemp & "<br />" & return after tResult
      end if
  end switch
  
  return tResult
end outputSpot


function outputHeader pTrainA
  local tTrains, tActiveTrain, tHeader
  
  put "" into tHeader
  
  -- Event Title
  if config.get("name") is not empty then
    put "<b>" & config.get("name") & "</b>" & return after tHeader
  end if
  
  -- Manifest Train details
  put "<p><b>TRAIN:</b>" && pTrainA["name"] && "<b>[" & pTrainA["symbol"] & "]</b>" & "</p>" & return after tHeader
  
  ## Output train name if there is one listed
  --  if pTrainA["name"] is not empty then
  --    put "<p>Train -  " & pTrainA["name"] & "</p>" & return after tHeader
  --  end if
  
  return tHeader
end outputHeader

/*
returns the termination instructions as html
*/
function outputTerminationInstructions pTrainA
  local tOutput
  
  if pTrainA["terminationInstructions"] is not empty then
    put "<br />" into tOutput
    repeat for each line aLine in pTrainA["terminationInstructions"]
      put aline & "<br />" after tOutput
    end repeat
    // delete the last <br /> tag in output
    delete char -6 to -1 of tOutput
  end if
  
  return tOutput
end outputTerminationInstructions

/*
returns crew instructions as html
*/
function outputCrewInstructions pTrainA
  local tTrains, tActiveTrain, tInstructions
  
  if pTrainA["instructions"] <> empty then
    
    put "<p><b>CREW INSTRUCTIONS</b></p>" & return after tInstructions
    
    // output crew instructions from the train data
    repeat for each line aLine in pTrainA["instructions"]
      put aLine & "<br />" after tInstructions
    end repeat
    
    delete char -6 to -1 of tInstructions
    
    ###put pTrainA["instructions"] into field "convert"
    ###put the htmltext of fld "convert" after tInstructions
    
  end if  
  
  return tInstructions
end outputCrewInstructions


function outputModuleName pStyle, pModule, pStopNum
  local tResult
  
  switch pStyle
    case "Modern"
      put "<p><b>Scheduled work at " & pModule after tResult
      break
    case "MRBT"
      put "<p><b>" & pModule after tResult
  end switch
  
  if the cSchedulingEngine of stack "Module Operations" is not "Random" then
    if sTrainRouteA[pStopNum]["dir"] <> "" then
      put " (" after tResult
      switch sTrainRouteA[pStopNum]["dir"]
        case "O"
          put "Outbound" after tResult
          break
        case "R"
          put "Return" after tResult
          break
        case "N"
          put "North" after tResult
          break
        case "S"
          put "South" after tResult
          break
        case "E"
          put "East" after tResult
          break
        case "W"
          put "West" after tResult
          break
      end switch
      put ")" after tResult
    end if
  end if
  
  put "</b></p>" & return after tResult
  return tResult     
end outputModuleName


function outputConsignee theStyle, theConsignee, theSpot
  -----
  local manifest,tConsignee,tConsignees
  local trainManifest,tSpotID,tConsigneeID
  -----
  
  
  /*
  -- add the consignee to the output     
  put item 5 of line i of trainManifest into tSpotID
  put tSpots[tSpotID]["ConsigneeID"] into tConsigneeID
  if the hilite of button "1/2 Page Width" then
    put "</p><p>      " after manifest
  end if
  put "  " & tConsignees[tConsigneeID]["Name"] & "                       " into tConsignee
  if tConsignees[tConsigneeID]["Name"] <> tSpots[tSpotID]["Spot"] then
    put " " & tSpots[tSpotID]["Spot"] after tConsignee
  end if
  
  put character 1 to 22 of tConsignee into tConsignee
  put tConsignee after manifest
  
  put "  " after manifest
  */
end outputConsignee


function outputTrainOrigin  pTrainA, pPageWidth
  local tTrainOut
  put "<p><b>Departs:</b>" && yard.nameById(pTrainA["origin"]) after tTrainOut
  
  --  if pPageWidth="Half" then
  --    put "</p><p>" after tTrainOut
  --  end if
  
  if the cCarCount of this card is empty then
    set the cCarCount of this card to 0
  end if
  
  put "<p><b>Length:</b>" && the cCarCount of this card after tTrainOut
  put " cars (" & the cTrainLength of this card & " feet)</p>" after tTrainOut
  
  return tTrainOut
end outputTrainOrigin


function outputFooter pTrainA, pPageWidth
  local tTrains, tActiveTrain, tFooter
  
  -- Footer of manifest starts here
  if pPageWidth = "Half" then
    ##put "<p> </p>" & return after tFooter
  end if
  put "<p><b>Terminate:</b> " & yard.nameById(pTrainA["destination"]) & "</p>" after tFooter
  if pPageWidth = "Half" then
    ##put "<p> </p>" & return after tFooter
  end if
  put "<p><b>Complete at:</b> ______________________</p>" & return after tFooter
  put "<p>Comments: </p>" & return after tFooter
  
  return tFooter
end outputFooter


function outputTwoColumns pManifest
  local tStartLine
  local tTemp, tReturn
  
  put wordWrappedHTML(pManifest, 54) into pManifest
  
  put "" into tTemp
  repeat with i = 1 to 39
    if (i = 39) and char 4 of line i of pManifest = "[" then
      put 39 into tStartLine
      exit repeat
    else        
      put line i of pManifest & return after tTemp
      put 40 into tStartLine
    end if
  end repeat
  
  // add OVER when more than 40 lines
  if the number of lines of pManifest > 40 then
    put return & "<p></p>                            -- OVER --" after tTemp
  end if
  
  set the htmlText of cd fld "Column1" of cd 1 of stack "2 Columns" to tTemp
  
  // set header/footer fields for column 1
  set the htmlText of cd fld "Header1" of cd 1 of stack "2 Columns" to config.get("trainlistHeader")
  set the htmlText of cd fld "Footer1" of cd 1 of stack "2 Columns" to config.get("trainlistFooter")
  
  put tTemp & return into tReturn
  put "" into tTemp
  repeat with i = tStartLine to number of lines of pManifest
    put line i of pManifest & return after tTemp
  end repeat
  
  set the htmlText of cd fld "Column2" of cd 1 of stack "2 Columns" to tTemp
  
  if number of lines of pManifest > 39 then
    // set header/footer fields for column 1
    set the htmlText of cd fld "Header2" of cd 1 of stack "2 Columns" to config.get("trainlistHeader")
    set the htmlText of cd fld "Footer2" of cd 1 of stack "2 Columns" to config.get("trainlistFooter")
  else
    // set header/footer fields for column 1
    set the htmlText of cd fld "Header2" of cd 1 of stack "2 Columns" to ""
    set the htmlText of cd fld "Footer2" of cd 1 of stack "2 Columns" to ""
  end if
  
  // set the font based on format selected
  repeat for each item aField in sFieldList
    if sManifestStyle = "MRBT" then
      set the textfont of field aField of cd 1 of stack "2 Columns" to "Courier New"
    else if sManifestStyle = "Modern" then
      set the textfont of of field aField of cd 1 of stack "2 Columns" to "Arial"
    end if
  end repeat
  
  // set font size and height
  if sManifestStyle = "MRBT" then
    set the textSize of field "Column1" of cd 1 of stack "2 Columns" to 11
    set the textSize of field "Column2" of cd 1 of stack "2 Columns" to 11
    set the textHeight of field "Column1" of cd 1 of stack "2 Columns" to 17
    set the textHeight of field "Column2" of cd 1 of stack "2 Columns" to 17
  else
    set the textSize of field "Column1" of cd 1 of stack "2 Columns" to 11
    set the textSize of field "Column2" of cd 1 of stack "2 Columns" to 11
    set the textHeight of field "Column1" of cd 1 of stack "2 Columns" to 18
    set the textHeight of field "Column2" of cd 1 of stack "2 Columns" to 18
  end if
  
  put tTemp after tReturn
  
  return pManifest   
end outputTwoColumns

on uiAdjustSpacing pSpacing
  set the textheight of cd fld "trainlist" to pSpacing
end uiAdjustSpacing


on scheduleMRBT
  --  -----
  --  local tArrayKey,tSpotID,tCarID
  --  local tManifest,tTrainRoute,tConsignees
  --  local tModuleID,tTrainOrders,tRandomWO
  --  local tModules,tCarTypes,tWOIndex
  --  local tTrainLength,tCarCount,randomNumber
  --  local tWillItFit
  --  local tWorkFactor,woCount
  --  -----
  
  --  set cursor to watch
  
  --  local tStopNum, tModule, tDirection, tRoute, tRouteIndustries
  --  local tTrains, freqTotal, tConsignee, tWorkorders, tSpots, tActiveTrain
  
  --  put "" into tManifest
  --  put the cTrains of stack "Module Operations" into tTrains
  --  put the cActiveTrain of stack "Module Operations" into tActiveTrain
  --  put tTrains[tActiveTrain]["Route"] into tTrainRoute
  
  --  if tTrainRoute = "" then
  --    answer warning "This train does not have a Route defined." with "OK"
  --    set the cManifest of stack "Module Operations" to tManifest
  --    break
  --  end if
  
  --  put the cConsignees of stack "Module Operations" into tConsignees
  --  put the cWorkorders of stack "Module Operations" into tWorkorders
  --  put the cModules of stack "Module Operations" into tModules
  --  put the cCarTypes of stack "Module Operations" into tCarTypes
  --  put the cSpots of stack "Module Operations" into tSpots
  
  --  put "" into tRouteIndustries
  --  put 0 into freqTotal
  --  put 1 into tWOIndex
  --  put 0 into cd fld "Train Length" of cd 1 of stack "MRBT"
  --  put 0 into cd fld "Car Count" of cd 1 of stack "MRBT"
  
  --  set the itemDelimiter to tab
  
  --  -- with each stop on the train route, list the consignees that are potentially serviced
  --  repeat with tStopNum = 1 to number of lines of tTrainRoute
  
  --    -- get the Module name for this stop
  --    put item 3 of line tStopNum of tTrainRoute into tModule
  
  --    -- get the Module ID
  --    put item 2 of line tStopNum of tTrainRoute into tModuleID
  
  --    -- check if this is a Special Train Order
  --    if tModuleID > 99999 then
  
  --      put tStopNum*1000 into tManifest[tModuleID]["index"]
  --      put tModuleID into tManifest[tModuleID]["ModuleID"]
  --      put tModule into tManifest[tModuleID]["Module"]
  
  --    else
  
  --      -- get the direction of the current module
  --      ##put item 2 of line tStopNum of tRoute into tDirection
  
  --      -- for the current module, get each consignee
  --      repeat for each element aWorkorder in tWorkorders
  --        if aWorkorder["ModuleID"] = tModuleID then
  --          put tWOIndex into tTrainOrders[tWOIndex]["ID"]
  --          put tStopNum into tTrainOrders[tWOIndex]["Stop"]
  --          put tModuleID into tTrainOrders[tWOIndex]["ModuleID"]
  --          put aWorkorder["ID"] into tTrainOrders[tWOIndex]["WOID"]
  --          put aWorkorder["ConsigneeID"] into tTrainOrders[tWOIndex]["ConsigneeID"]
  --          put tModules[tModuleID]["Name"] into tTrainOrders[tWOIndex]["Module"]
  --          put aWorkorder["SpotID"] into tTrainOrders[tWOIndex]["SpotID"]
  --          put aWorkorder["CarID"] into tTrainOrders[tWOIndex]["CarID"]
  --          put aWorkorder["CPW"] into tTrainOrders[tWOIndex]["CPW"]
  --          put freqTotal + aWorkorder["CPW"] into freqTotal
  --          put freqTotal into tTrainOrders[tWOIndex]["Total"]
  
  --          add 1 to tWOIndex
  --        end if
  --      end repeat
  
  --    end if
  --  end repeat
  
  --  -- with the industries listed, generate a random list of consingees to perform work at.
  --  ##put tRouteIndustries into field "routeIndustries"   
  --  set the dgData of group "dgTrainOrders" of cd 1 of stack "MRBT" to tTrainOrders
  --  put freqTotal into field "freqTotal" of cd 1 of stack "MRBT"
  
  --  -- Need to zero out each spots used length
  --  ##repeat for each element aSpot in tSpots
  --  ##put 0 into tSpots[aSpot["ID"]]["Used"]
  --  ##end repeat
  
  
  --  -- for lack of a better method right now, I've arbitraily picked a maximum of 100 workorders
  --  -- to attempt to schedule. Once I've got this software working better I'll come back and figure
  --  -- a better way to determine how many workorders to schedule.
  --  put "" into tRandomWO
  
  --  put (the cEconomy of stack "Module Operations")/1.5 into tWorkFactor
  
  --  -- not sure why this happens just yet but just encase cEcomomy is 0
  --  if tWorkFactor = 0 then put 2 into tWorkFactor
  
  --  put the number of elements of tTrainOrders into woCount
  --  put tTrains[tActiveTrain]["Length"] into tTrainLength
  --  put 1 into tCarCount
  
  --  repeat with i = 1 to (woCount*tWorkFactor)
  --    put random(freqTotal) into randomNumber
  --    ##put randomNumber & tab after tRandomIndustries
  
  --    put logarithmicSearch (tTrainOrders, randomNumber, 1, woCount) into tArrayKey
  --    if tArrayKey = 0 then 
  --      break
  --    end if
  
  --    put tTrainOrders[tArrayKey]["SpotID"] into tSpotID
  --    put tTrainOrders[tArrayKey]["CarID"] into tCarID
  
  --    if (tTrainLength-tCarTypes[tCarID]["Length"]) > 0 then
  --      put tSpots[tSpotID]["Length"] - tSpots[tSpotID]["Used"] - tCarTypes[tCarID]["Length"] into tWillItFit
  --      if  tWillItFit >= 0 then 
  --        put tTrainOrders[tArrayKey]["Stop"]*1000+tSpots[tSpotID]["Track"] into tManifest[tCarCount]["index"]
  --        put tTrainOrders[tArrayKey]["ConsigneeID"] into tManifest[tCarCount]["ConsigneeID"]
  --        put tTrainOrders[tArrayKey]["WOID"] into tManifest[tCarCount]["WOID"]
  --        put tTrainOrders[tArrayKey]["ModuleID"] into tManifest[tCarCount]["ModuleID"]
  --        put tTrainOrders[tArrayKey]["SpotID"] into tManifest[tCarCount]["SpotID"]
  --        put tSpots[tSpotID]["Spot"] into tManifest[tCarCount]["Spot"]
  --        put tSpots[tSpotID]["Track"] into tManifest[tCarCount]["Track"]
  --        put tTrainOrders[tArrayKey]["CarID"] into tCarID
  --        put tCarID into tManifest[tCarCount]["CarID"]
  --        put tTrainOrders[tArrayKey]["Module"] into tManifest[tCarCount]["Module"]
  --        put tCarTypes[tCarID]["Description"] into tManifest[tCarCount]["Description"]
  --        put tCarTypes[tCarID]["Length"] into tManifest[tCarCount]["Length"]
  --        subtract tCarTypes[tCarID]["Length"] from tTrainLength
  --        add tCarTypes[tCarID]["Length"] to tSpots[tSpotID]["Used"]
  --        add tCarTypes[tCarID]["Length"] to cd fld "Train Length" of cd 1 of stack "MRBT"
  --        add 1 to tCarCount
  --      end if
  --    else
  --      exit repeat
  --    end if
  
  --    put tCarCount-1 into cd fld "Car Count" of cd 1 of stack "MRBT"
  --    set the dgData of group "dgManifest" of cd 1 of stack "MRBT" to tManifest
  --    set the cManifest of stack "Module Operations" to tManifest
  --  end repeat
end scheduleMRBT


function spurExists moduleName, industryName, spurID, spurName
  --  -----
  --  local existingSpurs
  --  -----
  
  --  put field "SpurData" into existingSpurs
  --  set the itemDelimiter to tab
  
  --  repeat with spurIndex = 1 to number of lines of existingSpurs
  
  --    if (item 1 of line spurIndex of existingSpurs = moduleName) and (item 2 of line spurIndex of existingSpurs = industryName) and (item 3 of line spurIndex of existingSpurs = spurID) and (item 4 of line spurIndex of existingSpurs = spurName) then
  --      return true
  --      exit spurExists
  --    end if
  --  end repeat
  
  --  -- if we make it here then the spur does not already exists in the existing spur list
  --  return false
end spurExists


function logarithmicSearch @pArray pItem pLeft pRight
  local tIndex
  local tResult
  # create a new range pointer that points to the item that lies
  # right between the left and right range pointers
  put round ((pLeft + pRight) / 2) into tIndex
  
  #if we are at the first index then we are done
  if tIndex = 1 then
    put tIndex into tResult
    # if we have found the matching item then stop processing and return it
  else if pArray[tIndex-1]["Total"] < pItem and pArray[tIndex]["Total"] >= pItem then
    put tIndex into tResult
    
    # if any of the range pointers have the same value
    # then the item we are looking for does not exist in the array and we return 0
  else if (pLeft = pRight or pLeft = tIndex or pRight = tIndex) then
    put 1 into tResult
    
    # if we have not yet found a match and none of the range pointers have the same
    # value then call logarithmicSearch again with a smaller search range
    # we are effectively halving the search area, each time we call logarithmicSearch
  else if pArray[tIndex]["Total"] > pItem then
    put logarithmicSearch (pArray, pItem, pLeft, tIndex) into tResult
  else
    put logarithmicSearch (pArray, pItem, tIndex, pRight) into tResult
  end if
  return tResult
end logarithmicSearch


function formatRemarks pRemarks
  local tResult
  
  repeat with i = 1 to number of lines of pRemarks
    put "<p>" & line i of pRemarks & "</p>" & return after tResult
  end repeat   
  return tResult
end formatRemarks


on CreateThumbnail pStackName
  local tImageName
  	
  lock screen 
  -- pick a unique name for the image
  put "stack thumbnail" into tImageName
  if there is an image tImageName then
    delete image tImageName
  end if
  
  -- create an image for the thumbnail
  create image tImageName
  set the visible of image tImageName to true
  set the resizequality of image tImageName to "best"
  
  hide button "Print" of card 1 of stack pStackName
  export snapshot from card 1 of stack "switchlist" to image tImageName as PNG
  show button "Print" of card 1 of stack "switchlist"
  
  set the width of image tImageName to 280
  set the height of image tImageName to 364
  -- make the new size permanent
  set the imagedata of image tImageName to the imagedata of image tImageName
  
  set the left of image tImageName to 810
  set the top of image tImageName to 173
  
  unlock screen
end CreateThumbnail
