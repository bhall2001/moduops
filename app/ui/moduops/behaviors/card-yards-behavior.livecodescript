script "card-yards-behavior"
/*
* Yards Screen
* 
* Displays Yards and the details about the capacity and inventory.
*
* @created 16-JAN-2017
* @author Bob Hall
*
*/

/*--------------- SCRIPT LOCAL VARIABLES ---------------*/
local sYardListA
local sYardA
local sTrainA
local sModuleA
local sWorkorderA

/**
* Update the UI showing % used
*/
setProp uPercent pValue
   put pValue into field "percentStorage"
   set the uPercent of this card to pValue
end uPercent
 
/**
* Update the DataGrid when the value of the Car Type array changes
*/
setProp uCarTypeA pDataA
   set the uCarTypeA of this card to pDataA
   
   //
   // Datagrids (UI mechanism used) require the data be in a numeric array. 
   // set the datagrid dgData property to the idex array.
   //
   set the dgData of group "dgCarType" to indexArray(pDataA)
end uCarTypeA
 
 /*
 * Display Yard Information when user selects a Yard in the UI
 *
 * @paramater string UUID
 *
 */
 on displayYard pYardID
   lock screen
   -- Get the Yard Detail record from the DB
   put mdbQueryByValue("spot", "UUID", pYardID, true) into sYardA
   
   -- Get the Module Detail record from the DB
   put mdbQueryByValue("module", "UUID", sYardA["moduleID"], true) into sModuleA
   
   -- Display results in UI
   //put sModuleA["name"] into field "name"
   //put sYardA["length"] into field "length"
   set the uYardSize of this card to sYardA["length"]
   
   displayTrains
   
   yardCarTypes
   
   unlock screen
   
end displayYard

on preOpenCard
   lock screen
end preOpenCard

on openCard
   uiClear
   put yardList() into sYardListA
   set the dgData of group "dgYards" to sYardListA
   set the uPercent of this card to 100
   set the thumbpos of scrollbar "storage" to 100
end openCard

on closeCard
   uiClear
end closeCard

/*
* Clear the UI
*/
private command uiClear
   //put "" into field "name"
   //put "" into field "length"
   set the dgText of group "dgYards" to ""
   set the dgText of group "dgCarType" to ""
   set the dgText of group "dgTrains" to ""
   
end uiClear

/*
* Update UI to display trains that originate from the selected Yard
*/
private command displayTrains
   put mdbQueryByValue("train", "origin", sYardA["UUID"]) into sTrainA
   
   set the dgData of group "dgTrains" to sTrainA
end displayTrains

/*
* Lists all Car Types a Yard requires. The car types are determined from
* the Train routes for the Trains that originate at the Yard.
*/
private command yardCarTypes
   local tResultA
   local tRouteA, tRouteJson
   local tWorkorderA
   local tTotalCPW=0
   local tCarID
   local tCarTypeA
   local tTotalLength=0
   local tAddFlag
   
   // Loop through each train that Originates from the yard
   repeat for each key aTrain in sTrainA
      
      // Retrieve the route and convert to a Livecode Array
      // Order is not important as we are looking for the Car Types
      // the Yard requires to have on hand.
      put sTrainA[aTrain]["route"] into tRouteJson
      put jsonImport(tRouteJson) into tRouteA
      
      // For each stop, retrieve all the Workorders for a given module.
      repeat for each key aStop in tRouteA
         
         put true into tAddFlag
         
         // Handle a consignee that is NOT included
         if char 1 of tRouteA[aStop]["consigneeID"] = "!" then
            put false into tAddFlag
            put mdbQueryByValue("workorder", "consigneeID", char 2 to -1 of tRouteA[aStop]["consigneeID"]) into tWorkorderA
            
            // if this stop is for a consignee, add only the Consignee's requests
         else if tRouteA[aStop]["consigneeID"] contains "-" then
            put mdbQueryByValue("workorder", "consigneeID", tRouteA[aStop]["consigneeID"]) into tWorkorderA
            
            // If this stop is for a module, add the module requests
         else if tRouteA[aStop]["moduleID"] contains "-" then
            put mdbQueryWOByModuleID(tRouteA[aStop]["moduleID"]) into tWorkorderA
         else
            // if we get here there's nothing we need at this stop so move on
            next repeat
         end if
         
         // Only proceed if tWorkorderA is an array. If not, we got some kind of an error.
         // Display the error and exit out.
         if tWorkorderA is not an array then
            uiDisplayError tWorkorderA
            exit to top
         end if
         
         // Loop through WorkOrders to assemble the resulting Car Type data
         repeat for each key aWorkorder in tWorkorderA
            // increment total number of cars needed and save to Result Array
            put tWorkorderA[aWorkorder]["carID"] into tCarID
            if tAddFlag then
               add tWorkorderA[aWorkorder]["CPW"] to tResultA[tCarID]["quantity"]
               add tWorkorderA[aWorkorder]["CPW"] to tTotalCPW
            else
               subtract tWorkorderA[aWorkorder]["CPW"] from tResultA[tCarID]["quantity"]
               subtract tWorkorderA[aWorkorder]["CPW"] from tTotalCPW
            end if         
         end repeat
      end repeat
   end repeat
   
   // Determine the total length of each car type needed. The total length is
   // the result of multiplying the total number of car requests for a car type
   // by the length of the car.
   //
   // Also calculate the total length of all car types.
   repeat for each key aCar in tResultA
      // If a car type has 0 or less for a quantity, remove it from the result array
      if tResultA[aCar]["quantity"] <= 0 then
         delete variable tResultA[aCar]
         next repeat
      end if
      
      // total length of all cars for this car type
      put mdbQueryByValue("carType", "UUID", aCar, true) into tCarTypeA
      add tResultA[aCar]["quantity"] * tCarTypeA["length"] to tResultA[aCar]["totalLength"]
      
      //total length required to store all the cars
      add tResultA[aCar]["totalLength"] to tTotalLength
   end repeat
   
   // Retrieve data for car class, description and length
   repeat for each key aCar in tResultA
      // returns the DB record for the current car type UUID
      put mdbQueryByValue("carType", "UUID", aCar, true) into tCarTypeA
      
      // move the data points needed into the result array
      put tCarTypeA["class"] into tResultA[aCar]["class"]
      put tCarTypeA["description"] into tResultA[aCar]["description"]
      put tCarTypeA["length"] into tResultA[aCar]["length"]
      
      // calculate the total percentage of this car type needed overall by the Yard
      // the percentage is a function of the length of the car * total CPW for the car
      put round((tResultA[aCar]["totalLength"] / tTotalLength)*100, 2) into tResultA[aCar]["percent"]
      
   end repeat
   
   // store the Car Types Array (note: also updates the UI)
   set the uCarTypeA of this card to tResultA
   
   // update the Actual Cars in Yard
   calcCarCount
   
end yardCarTypes

/**
* Calculates the number of cars of each Car Type a yard can hold
*
* After much trials and tests, the car counts are based on standard deviations of
* the total number of request per car. This seems to give a very good number
* to work with in the yards for planning on what types of cars need to be
* in the yard at the start of a session.
*
*/
on calcCarCount
   local tPercent, tYardSize, tCarTypeA
   local tCarTypeUsed
   local tPercentTotal, tCarTotal
   
   // Retrieve data required from Properties
   put the uPercent of this card into tPercent
   put the uCarTypeA of this card into tCarTypeA
   put the uYardSize of this card into tYardSize
   
   // adjust the size of the yard to be % used for storage
   put tYardSize * (tPercent/100) into tYardSize
   
   // First, we need the standard deviation for each car. The number being used 
   // in order to normalize the data due to variying car lengths, is multiplying
   // the car length by the CPW. This gives us essentially the required storage
   // length for a car type.
   //
   // Once this number is calculated, we calculate the Standard Deviation
   // of the required storage and use that number to determine the car counts.
   //
   if (the hilite of button "Standard Deviation") then
      local tLengthList, tStDev
      repeat for each key aCar in tCarTypeA
         put tCarTypeA[aCar]["totalLength"] & "," after tLengthList
      end repeat
      delete last char of tLengthList
      put standardDeviation(tLengthList) into tStDev
      
      // Next, set the standard deviation for the car type.
      // Well use is the roundUp of (total requested Qty / the calculated Standard Deviation)
      // as our card types quantity ratio for the yard
      
      // Total of all the Standard Deviation ratios. Needed to calculate the percentage.
      local tRatioTotal = 0
      
      repeat for each key aCar in tCarTypeA
         put ceiling(tCarTypeA[aCar]["totalLength"] / tStDev) into tCarTypeA[aCar]["percent"]
         add tCarTypeA[aCar]["percent"] to tPercentTotal
      end repeat
      
   else
      // use CPW Percent to set #cars
      // Calculate the total CPW for the selected Yard
      local tCPWTotal
      repeat for each key aCar in tCarTypeA
         add tCarTypeA[aCar]["quantity"] to tCarTotal
      end repeat
      
      local tRatio
      repeat for each key aCar in tCarTypeA
         put (tCarTypeA[aCar]["quantity"]/tCarTotal)*100 into tRatio
         put round( tRatio, 0 ) into tCarTypeA[aCar]["percent"]
         add tCarTypeA[aCar]["percent"] to tPercentTotal
      end repeat
   end if
   
   
   // Now set the quantity of each car in the Yard
   // Calculated by taking the (percentage of the sdRatio * Yard size) / car type length
   //
   
   local tYardTotal = 0
   repeat for each key aCar in tCarTypeA
      if tPercentTotal = 0 then
         put 0 into tCarTypeUsed
      else
         put ((tCarTypeA[aCar]["percent"]/tPercentTotal)) * tYardSize into tCarTypeUsed
      end if
      
      put tCarTypeUsed / tCarTypeA[aCar]["length"] into tCarTypeUsed
      
      // store the number of cars for this car type
      put round(tCarTypeUsed) into tCarTypeA[aCar]["actual"]
      
      // Calculate total Yard Storage used (# of cars * length of car type)
      put tCarTypeA[aCar]["actual"] * tCarTypeA[aCar]["length"] into tCarTypeA[aCar]["yardLength"]
      add tCarTypeA[aCar]["yardLength"] to tYardTotal
   end repeat
   
   set the uCarTypeA of this card to tCarTypeA
   
   set the text of field "totalCars" to the uSumOfColumn["actual"] of group "dgCarType"
   set the text of field "totalCPW" to the uSumOfColumn["quantity"] of group "dgCarType"
   set the text of field "yardUsed" to tYardTotal
   
end calcCarCount
