' SubscriptionPanel.brs
sub init()
    m.subscribeBtn = m.top.findNode("subscribeBtn")
    m.cancelBtn = m.top.findNode("cancelBtn")
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
            m.top.onSubscribe = true
        else
            m.top.onCancel = true
        end if
        return true
    end if
    return false
end function

sub updateButtonFocus()
    if m.focusIndex = 0 then
        m.subscribeBtn.color = &hFFD700FF
        m.cancelBtn.color = &hCCCCCCFF
    else
        m.subscribeBtn.color = &hCCCCCCFF
        m.cancelBtn.color = &hFFD700FF
    end if
end sub 