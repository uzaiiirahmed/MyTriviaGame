sub init()
    m.titleLabel = m.top.findNode("titleLabel")
    m.questionLabel = m.top.findNode("questionLabel")
    m.answerList = m.top.findNode("answerList")
    m.currentQuestionIndex = 0
    m.trivia = invalid
end sub

sub onTriviaChanged()
    m.currentQuestionIndex = 0
    m.trivia = m.top.trivia
    showCurrentQuestion()
end sub

sub showCurrentQuestion()
    if m.trivia = invalid return
    questions = m.trivia.questions
    if m.currentQuestionIndex >= questions.count()
        m.titleLabel.text = "Quiz Complete!"
        m.questionLabel.text = "You finished all questions."
        m.answerList.content = CreateObject("roSGNode", "ContentNode")
        return
    end if
    q = questions[m.currentQuestionIndex]
    m.titleLabel.text = m.trivia.title
    m.questionLabel.text = q.question

    listContent = CreateObject("roSGNode", "ContentNode")
    for i = 0 to q.answers.count() - 1
        item = CreateObject("roSGNode", "ContentNode")
        item.text = q.answers[i]
        item.isSelected = false
        item.isCorrect = (i = q.correctIndex)
        listContent.appendChild(item)
    end for
    m.answerList.content = listContent
    m.answerList.setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        if key = "OK" then
            onAnswerSelected()
            return true
        else if key = "back" then
            m.top.backToMain = true
            return true
        end if
    end if
    return false
end function

sub onNextQuestionTimer()
    if m.nextTimer <> invalid then m.nextTimer.control = "stop"
    m.currentQuestionIndex = m.currentQuestionIndex + 1
    showCurrentQuestion()
end sub

sub onAnswerSelected()
    idx = m.answerList.itemFocused
    questions = m.trivia.questions
    q = questions[m.currentQuestionIndex]
    listContent = m.answerList.content
    for i = 0 to listContent.getChildCount() - 1
        item = listContent.getChild(i)
        item.isSelected = (i = idx)
        item.isCorrect = (i = q.correctIndex)
        listContent.updateChild(i, item)
    end for
    m.answerList.content = listContent
    m.answerList.itemFocused = idx
    sleep(500)
    if m.nextTimer = invalid then
        m.nextTimer = CreateObject("roSGNode", "Timer")
        m.nextTimer.duration = 2.0
        m.nextTimer.control = "stop"
        m.top.appendChild(m.nextTimer)
        m.nextTimer.ObserveField("fire", "onNextQuestionTimer")
    end if
    m.nextTimer.control = "start"
end sub 