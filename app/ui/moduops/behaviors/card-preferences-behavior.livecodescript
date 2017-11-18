script "card-preferences-behavior"
local sPrefs

on openCard
   local tConfigA
   
   lock screen
      
   put mdbTableToArray("config_data") into tConfigA
   put tConfigA[1]["setup_name"] into field "setup_name"
   
   set the label of button "month" to tConfigA[1]["month"]
   put tConfigA[1]["day"] into field "day"
   put tConfigA[1]["year"] into field "year"
   put tConfigA[1]["header"] into field "header"
   put tConfigA[1]["footer"] into field "footer"
   
   disable button "Save"
   
   unlock screen
end openCard

on textChanged
   enable button "Save"
   pass textChanged
end textChanged

on monthSelected pMenuItem
   put pMenuItem into sPrefs["Month"]
end monthSelected

on updatePrefsUI
   set the text of card field "Setup Name" to sPrefs["Setup Name"]
   set the text of card field "Header" to sPrefs["Header"]
   set the text of card field "Footer" to sPrefs["Footer"]
   set the text of card field "Day" to sPrefs["Day"]
   set the text of card field "Year" to sPrefs["Year"]
   if sPrefs["Month"] = "" then
      set the label of button "Month" to " "
   else
      set the label of button "Month" to sPrefs["Month"]
   end if
   
   set the thumbpos of sb "economy" to sPrefs["Economy"]
   set the thumbpos of sb "shipByRail" to sPrefs["ShipByRail"]
   
   set the cShipByRail of this stack to sPrefs["ShipByRail"]
   set the cEconomy of this stack to sPrefs["Economy"]
   
   ##put the cShipByRail of this stack into pTaskName
   ##set the thumbpos of sb "shipByRail" to pTaskName
   ##put the cEconomy of this stack into pTaskName
   ##set the thumbpos of sb "economy" to pTaskName
end updatePrefsUI

on closeField
   put the text of the target into sPrefs[the short name of the target]
end closeField

on updateSlider pSliderPos
   --put the short name of the target into lSlider
   --put pSliderPos into sPrefs["Economy"]
   put pSliderPos into sPrefs[the short name of the target]
   
   ##put the thumbpos of me into lSliderPos
   --set the thumbpos of the short name of the target to pSliderPos
   
   if the short name of the target = "Economy" then
      set the cEconomy of this stack to pSliderPos
   else
      set the cShipByRail of this stack to pSliderPos
   end if
end updateSlider

on closeCard
   cancelPressed
end closeCard

on cancelPressed
   if not the disabled of button "save" then
      answer  info "Would you like to save your changes?" with "No" or "Yes"
      if it is "Yes" then
         savePressed
         exit cancelPressed
      end if
   end if
   
end cancelPressed

on savePressed
   local tResult
   
   put saveRecord() into tResult
   disable button "Save"
end savePressed

private function saveRecord
   local tDataA, tResult
   
   lock screen
   
   ## Move data entry fields into an array
   put field "setup_name" into tDataA["setup_name"]
   put the label of button "Month" into tDataA["month"]
   put field "day" into tDataA["day"]
   put field "year" into tDataA["year"]
   put field "header" into tDataA["header"]
   put field "footer" into tDataA ["footer"]
    
   --update the config data
   put mdbDeleteTable("config_data") into tResult
   put mdbInsertRecord("config_data", tDataA) into tResult
   
   unlock screen
   return tResult
end saveRecord
