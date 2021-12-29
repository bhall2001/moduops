script "ModelTrain"
/*
Get all trains
*/
function fetchAllTrains
  local tDataA
  
  put fetchAllRecords("train") into tDataA
  return tDataA
end fetchAllTrains

/*
Get train data from database

parameter pUUID UUID of train to retrieve

returns array of train data
*/
function trainByUUID pUUID
  if pUUID is empty then
    return empty
  end if
  
  local tDataA
  
  put mdbQueryByValue("train", "UUID", pUUID, true) into tDataA
  
  return tDataA
end trainByUUID

/*
get train by Symbol

parameter pSymbol Symbol of train to retrieve

returns array of train data
*/
function trainBySymbol pSymbol
  if pSymbol is empty then
    return empty
  end if
  
  local tDataA
  
  put mdbQueryByValue("train", "symbol", pSymbol, true) into tDataA
  
  return tDataA
end trainBySymbol

/*
Get all trains of a give type

returns array
*/
function trainsByType pType
  if pType is empty then return empty
  
  local tDataA
  put mdbQueryByValue("train", "type", pType) into tDataA
  
  return tDataA
end trainsByType

/*
generate train symbol, train name CSV data
*/
function trainSymbolNameAsCSV
  local tText, tTrainA, tIndex
  
  put fetchAllTrains() into tTrainA
  
  repeat for each element aTrain in tTrainA
    put aTrain["symbol"] after tText
    
    if aTrain["name"] is not empty then
      put "," && aTrain["name"] after tText
    end if
    
    put return after tText
  end repeat
  //delete char -1 of tText
  
  return tText
end trainSymbolNameAsCSV


/*
count number of records
*/
function train.count
  return datalayer.count("train")
end train.count

