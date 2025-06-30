sub init()
    m.top.observeField("itemContent", "onItemContentChange")
end sub

sub onItemContentChange()
    itemContent = m.top.itemContent
    if itemContent <> invalid
        m.top.findNode("title").text = itemContent.title
        m.top.findNode("poster").uri = itemContent.posterUrl
        ' The design shows a progress text and description.
        ' The progress is hardcoded in the XML for now.
        ' The description of the focused item is shown at the bottom of the screen in MainScene.
    end if
end sub 