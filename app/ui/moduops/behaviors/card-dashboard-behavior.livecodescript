script "card-dashboard-behavior"
on openCard
   local tTemp, tStatsA
   lock screen
   
   put field "Stats Array" into tStatsA
   set the itemDelimiter to comma
   repeat for each line aStat in tStatsA
      put mdbNumRecords(item 1 of aStat) into tTemp
      put item 2 of aStat && tTemp into field item 1 of aStat
   end repeat
   
   unlock screen
   pass openCard
end openCard


on preOpenCard
   put myVersion() into field "myVersion" of card "Dashboard" of stack "Module Operations"
end preOpenCard


on openStack
   set the dgProp[ "dim on focusOut" ] of group "dgTrains" of card "Trains" to false
   set the dgProp[ "dim on focusOut" ] of group "dgCarTypes" of card "Equipment Register" to false
   set the dgProp[ "dim on focusOut" ] of group "dgConsignees" of card "Modules/Towns" to false
   set the dgProp[ "dim on focusOut" ] of group "dgSpots" of card "Modules/Towns" to false
   set the dgProp[ "dim on focusOut" ] of group "dgModules" of card "Modules/Towns" to false
   set the dgProp[ "dim on focusOut" ] of group "dgSpots" of card "Equipment Request" to false
   set the dgProp[ "dim on focusOut" ] of group "dgCarTypes" of card "Equipment Request" to false
   set the dgProp[ "dim on focusOut" ] of group "dgTrains" of card "Train Sequence" to false
   set the dgProp[ "dim on focusOut" ] of group "dgSequence" of card "Train Sequence" to false
   set the dgProp[ "dim on focusOut" ] of group "dgRoute" of card "Route" to false
   
   dispatch "mouseUp" to button "Dashboard"
   
   pass openStack
end openStack


