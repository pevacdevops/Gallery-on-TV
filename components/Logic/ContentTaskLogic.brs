'*************************************************************
'***              Gallery on TV by PeVaC                  ***
'*************************************************************

sub RunContentTask()
    m.contentTask = CreateObject("roSGNode", "MainLoaderTask") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    m.contentTask.ObserveField("content", "OnMainContentLoaded")
    m.contentTask.control = "run" ' GetContentFeed (see MainLoaderTask.brs) method is executed
    m.loadingIndicator = m.top.FindNode("loadingIndicator")
    m.loadingIndicator.visible = true ' show loading indicator while content is loading
end sub

sub OnMainContentLoaded() ' invoked when content is ready to be used
    if m.contentTask.content.Count() <> 0
        m.loadingIndicator.visible = false ' hide loading indicator because content was retrieved
    else m.loadingIndicator.text = "Feed is currently not available. Check URL and try again later."
    endif
end sub