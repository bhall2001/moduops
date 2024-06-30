script "stack-script-switchlist"
on closeStack
end closeStack

on closeStackRequest
   set the destroyStack of this stack to true
   close this stack
end closeStackRequest

on openStack
  set the width of this stack  to 612
  set the height of this stack to 792
end openStack

on preOpenStack
   
end preOpenStack
