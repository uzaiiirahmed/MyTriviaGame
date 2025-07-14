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
        m.top.findNode("description").text = itemContent.description
        ' Show lock icon if isLocked is true
        lockIcon = m.top.findNode("lockIcon")
        if lockIcon <> invalid and itemContent.isLocked = true
            lockIcon.visible = true
        else if lockIcon <> invalid
            lockIcon.visible = false
        end if
        ' Set progress label
        progressLabel = m.top.findNode("progress")
        if progressLabel <> invalid and itemContent.progressText <> invalid
            progressLabel.text = itemContent.progressText
        end if
    end if
end sub 