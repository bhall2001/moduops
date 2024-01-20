script "frontscript-event-catcher"
on preOpenStack
  if the short name of this stack is "answer dialog" then
    set the loc of stack "answer dialog" to 100,100
  end if
  
  pass preOpenStack
end preOpenStack
