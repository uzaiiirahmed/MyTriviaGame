sub init()
    m.top.observeField("title", "onTitleChanged")
    m.top.observeField("isSelected", "onSelectedChanged")
end sub

sub onTitleChanged()
    m.optionLabel = m.top.findNode("optionLabel")
    m.optionLabel.text = m.top.title
end sub

sub onSelectedChanged()
    m.bg = m.top.findNode("bg")
    if m.top.isSelected then
        m.bg.color = "0x4444FFFF" ' Highlight color
    else
        m.bg.color = "0x222222FF" ' Default color
    end if
end sub 