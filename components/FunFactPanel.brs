' FunFactPanel.brs
sub init()
    m.factLabel = m.top.findNode("factLabel")
    m.top.observeField("funfact", "onFunFactChanged")
end sub

sub onFunFactChanged()
    m.factLabel.text = m.top.funfact
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press and key = "OK"
        m.top.onContinue = true
        return true
    end if
    return false
end function 