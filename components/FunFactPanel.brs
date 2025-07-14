' FunFactPanel.brs
sub init()
    m.factLabel = m.top.findNode("factLabel")
    m.sideImage = m.top.findNode("sideImage")
    m.top.observeField("funfact", "onFunFactChanged")
    m.top.observeField("sideImageUri", "onSideImageUriChanged")
end sub

sub onFunFactChanged()
    m.factLabel.text = m.top.funfact
end sub

sub onSideImageUriChanged()
    if m.sideImage <> invalid and m.top.sideImageUri <> invalid then
        m.sideImage.uri = m.top.sideImageUri
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press and key = "OK"
        m.top.onContinue = true
        return true
    end if
    return false
end function 