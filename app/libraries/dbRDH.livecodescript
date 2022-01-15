script "dbRDH"
/*
additional helper functions for aag's dbLib library. These functions
have not made the cut as of yet and therefore are not included in
the aagDBLib code
*/


/*
opens a sqlite connection and sets the default databse ID

parameters:
pParamA: array: of parameters
pParamA["filePath"]: string: required path to sqlite file to open
*/
function dbOpenSqlite pParamA
   local tParamA
   local tId
   local tURI
   
   if pParamA is an array then
      put pParamA into tParamA
   else
      put pParamA into tParamA["filePath"]
   end if
   
   if tParamA["filePath"] is empty then 
      return empty
   end if
   
   put tParamA["filePath"] into tURI
   
   put revOpenDatabase("sqlite", tURI, "binary,extensions") into tId
   
   // if we dont get a nunber, there's an error so we stop
   if tId is not a number then
      throw tId
   end if
   
   // check if there's an open default db
   if dbGetDefaultConnectionID() is a number then
      // close the current open default database
      revCloseDatabase dbGetDefaultConnectionID()
   end if
   
   // now we set the default id to the db we just opened
   dbSetDefaultConnectionID tId
   
   // and return the new database id
   return tId
end dbOpenSqlite


function dbClose pId
   revCloseDatabase pId
   
   // if we get an error, let's return it
   if the result contains "revdberr" then
      return the result
   end if
   
   
   // clear default id when same as passed in
   if dbGetDefaultConnectionID() = pId then
      dbSetDefaultConnectionID empty
   end if
   
   return empty
end dbClose
