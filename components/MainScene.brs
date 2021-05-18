'*************************************************************
'***              Gallery on TV by PeVaC                  ***
'*************************************************************

sub init()
  rssUrl = m.top.FindNode("rssUrl")
  rssUrl.text = m.global.rssUrl ' sets rss label text to global rssUrl from registry
  m.rssButton = m.top.FindNode("rssButton")
  m.rssButton.ObserveField("buttonSelected", "OnReplaceButtonSelected")

  m.top.setFocus(true)
  if m.global.rssUrl <> "" ' if there is feed url in registry get the feed content
    RunContentTask()
  end if
  rssUrl.setFocus(false)

end sub

' Configure slideshow dialog
sub showdialog()
  dialog = createObject("roSGNode", "Dialog")
  CheckInterval() ' check for slideshow duration [interval] in registry
  dialog.backgroundUri = "pkg:/images/rsgde_dlg_bg_hd.png"
  dialog.title = "Options"
  dialog.titleFont = "MediumBoldSystemFont"
  dialog.optionsDialog = true
  dialog.message = "Configure slideshow time duration. Select one from the options below and press OK to confirm." + chr(10) + "Press * to close this dialog."
  dialog.buttons = ["Static - NO Slideshow", "5 seconds", "10 seconds", "30 seconds", "1 minute", "5 minutes", "10 minutes"]
  dialog.ObserveField("buttonSelected", "OnIntervalButtonHandler")
  ' setFocus on IntervalIndex from registry
  dialog.buttonGroup.focusButton = GetRegIntervalIndex()

  m.top.dialog = dialog
end sub

' event hanlder for the remote control input
function onKeyEvent(key as string, press as boolean) as boolean
  if press then
    if key = "options"
      showdialog() ' show configuration dialog on options key press on the remote
      return true
    else if key = "down" ' set focus on the Rss Save button
      m.top.setFocus(false)
      m.rssButton.focusedIconUri = ""
      m.rssButton.setFocus(true)
      return true
    end if
  end if
  return false
end function

' Handler for the slideshow duration button
function OnIntervalButtonHandler(event as object)
  timeInterval = [0, 5, 10, 30, 60, 300, 600] ' interval array
  SetRegInterval(timeInterval[event.getData()] * 1000) ' set new milliseconds duration into registry
  SetRegIntervalIndex(event.getData()) ' save timeInderval index, so we can set the focus on proper button if there is saved value in registry
end function

' get default value or set them to default on the first run
sub CheckInterval()
  if GetRegInterval() = invalid then SetRegInterval(1000)
  if GetRegIntervalIndex() = invalid then SetRegIntervalIndex(1)
end sub

' handler for replacing feed url button
function OnReplaceButtonSelected(event as object)
  showKeyBoard()
end function

' show Rss Feed input keyboard dialog
function showKeyBoard()
  m.Keyboard = createObject("roSGNode", "KeyboardDialog")
  m.Keyboard.title = "Add Gallery RSS Feed Address"
  m.Keyboard.message = ["Please enter URL from your Gallery RSS feed. Enter specific album to avoid displaying an entire library. Begin URL with http"]
  m.Keyboard.buttons = ["Save"]
  m.Keyboard.ObserveField("buttonSelected", "onSaveRssUrl")
  m.keyboard.text = m.global.rssUrl
  ' replace dialog compoenent with Keyboard
  m.top.dialog = m.Keyboard
end function

' Save new feed button handler
function onSaveRssUrl(event as object)
  SetRegRssUrl(m.keyboard.text)
  m.keyboard.close = true
end function