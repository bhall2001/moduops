script "navigation-backscript"
command goDashboard
  // reset ui depending on where we are
  if the short name of this card is "Dashboard" then
    send "openCard" to this card
  else
    go to card "Dashboard"
  end if
end goDashboard
