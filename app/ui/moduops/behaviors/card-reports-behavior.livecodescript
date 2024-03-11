script "card-reports-behavior"
on openCard
  lock screen
  
  // update layout name field
  put config.get("name") into field "layoutName"
  
  unlock screen
end openCard
