sub init()
    m.top.observeField("itemContent", "onItemContentChange")
    m.top.observeField("state", "onStateChange")
    m.border = m.top.findNode("border")
end sub

sub onStateChange()
    if m.top.state = "focused"
        m.border.color = "0xFFD700FF" ' Yellow
    else if m.top.state = "unfocused"
        m.border.color = "0x555555FF" ' Original Gray
    end if
end sub

sub onItemContentChange()
    itemContent = m.top.itemContent
    if itemContent <> invalid
        m.top.findNode("title").text = itemContent.title
        m.top.findNode("poster").uri = itemContent.HDPosterUrl
        ' The design shows a progress text and description.
        ' The progress is hardcoded in the XML for now.
        ' The description of the focused item is shown at the bottom of the screen in MainScene.
    end if
end sub 