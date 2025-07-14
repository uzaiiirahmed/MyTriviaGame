sub init()
    m.poster = m.top.findNode("poster")
    m.lockIcon = m.top.findNode("lockIcon")
    m.titleLabel = m.top.findNode("title")
    m.progressLabel = m.top.findNode("progress")
    m.descriptionLabel = m.top.findNode("description")
end sub

sub onItemContentChange()
    item = m.top.itemContent
    if item = invalid then return

    ' Set poster image
    if item.HDPosterUrl <> invalid then
        m.poster.uri = item.HDPosterUrl
    end if

    ' Set title
    if item.title <> invalid then
        m.titleLabel.text = item.title
    end if

    ' Set description
    if item.description <> invalid then
        m.descriptionLabel.text = item.description
    end if

    ' Set progress text (e.g., "3/10 Completed")
    if item.progressText <> invalid then
        m.progressLabel.text = item.progressText
    else
        m.progressLabel.text = "0/10 Completed"
    end if

    ' Handle lock state
    if item.hasField("isLocked") and item.isLocked = true then
        m.lockIcon.visible = true
    else
        m.lockIcon.visible = false
    end if
end sub
