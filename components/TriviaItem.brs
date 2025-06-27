sub init()
    m.titleLabel = m.top.findNode("titleLabel")
    m.triviaMenu = m.top.findNode("triviaMenu")

    rowListContent = CreateObject("roSGNode", "ContentNode")
    rowNode = CreateObject("roSGNode", "ContentNode")
    rowNode.title = "Sample Row"

    item1 = CreateObject("roSGNode", "ContentNode")
    item1.title = "Item 1"
    rowNode.appendChild(item1)

    item2 = CreateObject("roSGNode", "ContentNode")
    item2.title = "Item 2"
    rowNode.appendChild(item2)

    rowListContent.appendChild(rowNode)
    m.triviaMenu.content = rowListContent
end sub 

sub showQuestionScene(trivia as Object)
    m.top.goToQuestionScene = trivia
end sub 

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        if key = "back" then
            m.top.goToMainScene = true
            return true
        end if
        if key = "OK" then
            idx = m.answerList.getFocusedItem()
            print "Selected answer: " + m.answerList.content.getChild(idx).title
            ' Add answer logic here
            return true
        end if
    end if
    return false
end function 