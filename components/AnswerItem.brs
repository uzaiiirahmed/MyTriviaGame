sub init()
    m.top.observeField("isSelected", "onSelectionChanged")
    m.top.observeField("isCorrect", "onSelectionChanged")
    m.top.observeField("isIncorrect", "onSelectionChanged")
    m.top.observeField("title", "onTitleChanged")
end sub

sub onSelectionChanged()
    if m.top.isSelected then
        if m.top.isCorrect then
            m.top.backgroundColor = "0x00FF00FF" ' Green for correct
        else if m.top.isIncorrect then
            m.top.backgroundColor = "0xFFA500FF" ' Orange for wrong
        else
            m.top.backgroundColor = "0x444444FF" ' Default gray
        end if
    else
        m.top.backgroundColor = "0x444444FF" ' Default gray
    end if
end sub

sub onTextChanged()
    m.top.text = m.top.text
end sub

sub onTitleChanged()
    m.top.text = m.top.title
end sub 