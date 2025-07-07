sub init()
    m.top.observeField("title", "onTitleChanged")
    m.top.observeField("isSelected", "onStateChanged")
    m.top.observeField("isIncorrect", "onStateChanged")
end sub

sub onTitleChanged()
    m.top.text = m.top.title
end sub

sub onStateChanged()
    if m.top.isSelected then
        m.top.color = "0x00FF00FF" ' Green
    else if m.top.isIncorrect then
        m.top.color = "0xFFA500FF" ' Orange
    else
        m.top.color = "0xFFFFFFFF" ' White
    end if
end sub 