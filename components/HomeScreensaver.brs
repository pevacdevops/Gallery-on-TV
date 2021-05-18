'*************************************************************
'***              Gallery on TV by PeVaC                  ***
'*************************************************************

function init()

    m.currentImage = 0 'Current image index

    m.top.backgroundUri = m.global.channels[0] 'Background URI of screensaver, get first image URI from array

    Change()
    m.global.observeField("IsChangeImage", "Change") '(Observer for IsChangeImage) Everytime the value of IsChangeImage Changes, the Change() function is called
end function

function Change() as void
    if m.currentImage > m.global.channels.count() - 1 ' we need zero based index for channels array
        m.currentImage = -1 ' Current image index reset
    end if
    m.currentImage += 1 ' advance current image for two positions

    m.top.backgroundUri = m.global.channels[m.currentImage] 'Sets uri of PosterOne to random uri in Channel Artwork array
end function