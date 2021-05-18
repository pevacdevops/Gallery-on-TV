'*************************************************************
'** Gallery on TV by PeVaC
'*************************************************************
' Note: Main application and Screen Saver components are working like two separate applications
' They do not share same global space, and they run on different ports for debugging
' They share same temp file location and registry, so tmp file is used to share feed data
sub Main()
    screen = CreateObject("roSGScreen") ' create screen
    m.port = CreateObject("roMessagePort") ' create application event message port
    m.global = screen.getGlobalNode() 'get global node
    m.global.AddField("rssUrl", "string", true) ' create global variable with always notify set to true

    'Check if there is URL recorded in registry
    if GetRegRssUrl() <> invalid
        m.global.rssUrl = GetRegRssUrl()
    else
        m.global.rssUrl = "https://gallery.adreca.net/index.php/rss/feed/gallery/album/3" ' set deafult gallery url
    end if
    '(Global Main Screen) array of channel paths to artwork this is not visible in the Screen saver, and it is saved to tmp:/data file
    m.global.AddField("channels", "stringarray", true)
    m.global.channels = [] ' initialize empty array
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("MainScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub

sub RunScreenSaver()
    screen = createObject("roSGScreen")
    m.port = createObject("roMessagePort")
    screen.setMessagePort(m.port)

    m.global = screen.getGlobalNode() 'get global node

    m.global.AddField("channels", "stringarray", true) '(Global Screen Saver) array of channel paths to artwork
    m.global.channels = ReadAsciiFile("tmp:/data").split("|") ' read images from temp file into array

    m.global.AddField("ScreenDuration", "int", true) '(Global) duration interval for changing images
    m.global.ScreenDuration = GetRegInterval() ' set duration from registry

    m.global.AddField("IsChangeImage", "bool", true) '(Global) Sets change image variable that will be changed on timer
    m.global.IsChangeImage = false

    scene = screen.createScene("HomeScreensaver") 'Create Scene called HomeScreensaver
    screen.Show()

    while(true) 'While loop that fires every ScreenDuration seconds to change (Global) IsChangeImage value. It also checks to see if app is closed
        msg = wait(m.global.ScreenDuration, m.port) ' wait for screen duratio to runs out
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            end if
        else
            if m.global.IsChangeImage = true 
                m.global.IsChangeImage = false
            else
                m.global.IsChangeImage = true' change IsChangeImage variable to activate observe field (see HomeScreensaver.brs) and Change function
            end if
        end if
    end while
end sub