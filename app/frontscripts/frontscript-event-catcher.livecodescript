script "frontscript-event-catcher"
on preOpenStack
  if the short name of this stack is "answer dialog" then
    set the loc of stack "answer dialog" to 100,100
  end if
  
  pass preOpenStack
end preOpenStack

on mouseDown
  dispatch "hideMenus" to this card with the short name of the target
  pass mouseDown
end mouseDown

on openField
  dispatch "hideMenus" to this card with the short name of the target
  pass openField
end openField

on hiliteChanged
  dispatch "hideMenus" to this card with the short name of the target
  pass hiliteChanged
end hiliteChanged

on dateChanged
  dispatch "hideMenus" to this card with the short name of the target
  pass dateChanged
end dateChanged

on dragStart
 dispatch "hideMenus" to this card with the short name of the target
 pass dragStart
end dragStart
