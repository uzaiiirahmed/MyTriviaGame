sub init()
    m.top.observeField("isSelected", "onSelectionChanged")
end sub

sub onSelectionChanged()
    if m.top.isSelected then
        if m.top.isCorrect then
            m.top.backgroundColor = "0x00FF00FF" ' Green for correct
        else
            m.top.backgroundColor = "0xFFA500FF" ' Orange for wrong
        end if
    else
        m.top.backgroundColor = "0x444444FF" ' Default gray
    end if
end sub 