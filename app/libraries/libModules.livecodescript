script "libModules"
/*
*  get all the modules associated with the active layout
*
* returns array
*/
function layoutModules
   local tDataA
   
   put fetchAllRecords("module") into tDataA
   
   return tDataA
   
end layoutModules
