sub init()
    m.titleLabel = m.top.findNode("titleLabel")
    m.triviaList = m.top.findNode("triviaList")

    ' Create a ContentNode for the list
    listContent = CreateObject("roSGNode", "ContentNode")

    ' Add trivia types as children
    triviaTypes = ["General Knowledge", "Science", "History"]
    for each t in triviaTypes
        item = CreateObject("roSGNode", "ContentNode")
        item.title = t
        listContent.appendChild(item)
    end for

    m.triviaList.content = listContent
    m.triviaList.setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        if key = "OK" then
            idx = m.triviaList.getFocusedItem()
            print "Selected trivia type: " + m.triviaList.content.getChild(idx).title
            ' Here you can add logic to handle selection
            return true
        end if
    end if
    return false
end function
