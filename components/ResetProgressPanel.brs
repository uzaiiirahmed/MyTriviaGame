' ResetProgressPanel.brs
sub init()
    m.yesBtn = m.top.findNode("yesBtn")
    m.noBtn = m.top.findNode("noBtn")
    m.focusIndex = 0
    updateButtonFocus()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press return false
    if key = "right" or key = "left" then
        m.focusIndex = (m.focusIndex + 1) mod 2
        updateButtonFocus()
        return true
    else if key = "OK" then
        if m.focusIndex = 0 then
            m.top.onYes = true
        else
            m.top.onNo = true
        end if
        return true
    end if
    return false
end function

sub updateButtonFocus()
    if m.focusIndex = 0 then
        m.yesBtn.color = &hFFD700FF
        m.noBtn.color = &hCCCCCCFF
    else
        m.yesBtn.color = &hCCCCCCFF
        m.noBtn.color = &hFFD700FF
    end if
end sub 