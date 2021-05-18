' Helper function convert AA to Node
function ParsePictures(onlyPictureItems as object)
    result = []
    for i = 0 to onlyPictureItems.count() - 1
        itemParent = onlyPictureItems[i].GetChildElements() 'Get the child elements of item
        item = {} 'Creates an Associative Array for each row

        'populate most of stuff from even number index - itemParent
        if itemParent <> invalid 'Fall back in case invalid is returned
            for each xmlItem in itemParent 'Goes through all content of itemParent
                ParseItem(xmlItem, result)
            end for
        end if
    end for
    m.global.channels = result
    SaveToTemp(result.Join("|")) ' save parsed images URLs as string in tmp file with | delimiter
    return result
end function

' parse gallery rss feed
sub ParseItem(xmlItem as object, result as object)
    if xmlItem.getName() = "media:group" 'Checks to find <media:group> header
        mediaGroup = xmlItem.GetChildElements()
        for each xmlMediaItem in mediaGroup 'Goes through all content of the mediaGroup
           if xmlMediaItem.getAttributes().isDefault = "true" then result.push(xmlMediaItem.getAttributes().url) ' find gallery default image
        end for
    end if
end sub

' save string delimited images urls
sub SaveToTemp(message as string)
    ' write feed to temp
    fileName = "tmp:/data"
    LocalFileBrowser = CreateObject("roFileSystem")
    WriteAsciiFile(filename, message)
end sub

' store keyboard url into registry
function SetRegRssUrl(userUrl as string) as void
    sec = CreateObject("roRegistrySection", "GalleryonTV")
    if CheckRegistrySpace() = true then sec.Write("UserGalleryUrl", userUrl)
    sec.Flush()
end function

' get reg UserGalleryUrl
function GetRegRssUrl() as dynamic
    sec = CreateObject("roRegistrySection", "GalleryonTV")
    if sec.Exists("UserGalleryUrl")
        return sec.Read("UserGalleryUrl")
    end if
    return invalid
end function

' store index of selected interval into registry
function SetRegIntervalIndex(index as integer) as void
    sec = CreateObject("roRegistrySection", "GalleryonTV")
    ' check avaliable space
    if CheckRegistrySpace() = true then sec.Write("IntervalIndex", index.toStr()) ' write intervalIndex as string
    sec.Flush()
end function

' get reg IntervalIndex
function GetRegIntervalIndex() as dynamic
    sec = CreateObject("roRegistrySection", "GalleryonTV")
    if sec.Exists("IntervalIndex")
        return sec.Read("IntervalIndex").toInt() ' read intervalIndex as integer
    end if
    return invalid
end function

' store interval into registry
function SetRegInterval(index as integer) as void
    sec = CreateObject("roRegistrySection", "GalleryonTV")
    ' check avaliable space
    if CheckRegistrySpace() then sec.Write("Interval", index.toStr()) ' write interval as string
    sec.Flush()
end function

' get reg IntervalIndex
function GetRegInterval() as dynamic
    sec = CreateObject("roRegistrySection", "GalleryonTV")
    if sec.Exists("Interval")
        return sec.Read("Interval").toInt() ' read interval as integer
    end if
    return invalid
end function

function CheckRegistrySpace()
    registry = CreateObject("roRegistry")
    limit = 512 ' arbitrary limit bytes based on the channel application
    if (registry.GetSpaceAvailable() < limit) 'Returns the number of bytes available in the channel application's device registry (16K minus current file size).
        ' remove some old registry entries before writing new ones
        ' alert dialog to remove?
        ' test again?
        return false
    end if
    return true
end function

Function Fetch(url as string) as object
    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.SetMessagePort(port)
    request.SetUrl(url)
    if (request.AsyncGetToString())
        while (true)
            msg = wait(0, port)
            if (type(msg) = "roUrlEvent")
                code = msg.GetResponseCode()
                if (code = 200)
                    return msg.GetString()
                endif
                ' here we test if different code then 200, like 400, it will still be good response from server but will it be error response
                if (code <> 200)
                    return invalid
                endif
            else if (event = invalid)
                request.AsyncCancel()
            endif
        end while
    endif
    return invalid
End Function