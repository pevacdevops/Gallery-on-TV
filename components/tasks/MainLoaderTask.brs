'*************************************************************
'***              Gallery on TV by PeVaC                  ***
'*************************************************************

sub Init()
    ' function that will be executed with run (see ContentTaskLogic)
    m.top.functionName = "GetContentFeed"
end sub

function ParseXML(str as string) as dynamic 'Takes the content feed as a string
    if str = invalid return invalid 'if the response is invalid, return invalid
    xml = CreateObject("roXMLElement") '
    if not xml.Parse(str) return invalid 'If the string cannot be parsed, return invalid
    return xml 'returns parsed XML if not invalid
end function

function ParseItemsIntoArray(xml as object) as object 'Parse XML feed into AA
    result = []
    for each xmlItem in xml 'For loop to grab content inside each item in the XML feed
        if xmlItem.getName() = "item" 'Each individual channel content is stored inside the XML header named <item>
            result.push(xmlItem)
        end if
    end for
    return result
end function

function GetContentFeed() 'This function retrieves and parses the feed and stores each content item in a ContentNode

    rsp = Fetch(m.global.rssUrl) ' get http requst with url
    if rsp <> invalid
    
        responseXML = ParseXML(rsp) 'Roku includes it's own XML parsing method

        if responseXML <> invalid then 
            responseXML = responseXML.GetChildElements() 'Access content inside Feed
            responseArray = responseXML.GetChildElements()
        end if

        onlyPictureItems = ParseItemsIntoArray(responseArray) ' create AA with only <item> objects
        parsedResult = ParsePictures(onlyPictureItems) ' parse image URL from images array

        m.top.content = parsedResult
    else
        empty = [] ' empty content means feed is not available
        m.top.content = empty 
    endif
end function