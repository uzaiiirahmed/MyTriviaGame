sub init()
    m.titleLabel = m.top.findNode("titleLabel")
    m.questionLabel = m.top.findNode("questionLabel")
    m.answerList = m.top.findNode("answerList")
end sub

sub onTriviaChanged()
    trivia = m.top.trivia
    if trivia <> invalid
        m.titleLabel.text = trivia.title
        m.questionLabel.text = trivia.question

        ' Populate answers
        answers = trivia.answers
        listContent = CreateObject("roSGNode", "ContentNode")
        for each a in answers
            item = CreateObject("roSGNode", "ContentNode")
            item.title = a
            listContent.appendChild(item)
        end for
        m.answerList.content = listContent
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        if key = "OK" then
            idx = m.answerList.getFocusedItem()
            print "Selected answer: " + m.answerList.content.getChild(idx).title
            ' You can add logic here to check if the answer is correct
            return true
        else if key = "back" then
            m.top.backToMain = true
            return true
        end if
    end if
    return false
end function 