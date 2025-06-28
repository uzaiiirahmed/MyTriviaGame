sub init()
    m.titleLabel = m.top.findNode("titleLabel")
    m.questionLabel = m.top.findNode("questionLabel")
    m.answerList = m.top.findNode("answerList")
    m.feedbackLabel = m.top.findNode("feedbackLabel")
    m.currentQuestionIndex = 0
    m.trivia = invalid
end sub

sub onTriviaChanged()
    m.currentQuestionIndex = 0
    m.feedbackLabel.text = ""
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
        m.feedbackLabel.text = "Press Back to return."
        return
    end if
    q = questions[m.currentQuestionIndex]
    m.titleLabel.text = m.trivia.title
    m.questionLabel.text = q.question
    m.feedbackLabel.text = ""
    listContent = CreateObject("roSGNode", "ContentNode")
    for each a in q.answers
        item = CreateObject("roSGNode", "ContentNode")
        item.title = a
        listContent.appendChild(item)
    end for
    m.answerList.content = listContent
    m.answerList.setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        if key = "OK" then
            idx = m.answerList.itemFocused
            questions = m.trivia.questions
            q = questions[m.currentQuestionIndex]
            if idx = q.correctIndex then
                m.feedbackLabel.text = "Correct!"
            else
                m.feedbackLabel.text = "Incorrect!"
            end if
            ' Move to next question after 1 second
            nextIdx = m.currentQuestionIndex + 1
            m.currentQuestionIndex = nextIdx
            timer = CreateObject("roSGNode", "Timer")
            timer.duration = 1.0
            timer.control = "start"
            m.top.appendChild(timer)
            timer.ObserveField("fire", "onNextQuestionTimer")
            return true
        else if key = "back" then
            m.top.backToMain = true
            return true
        end if
    end if
    return false
end function

sub onNextQuestionTimer()
    ' Remove the timer node
    timer = m.top.getChild(m.top.getChildCount() - 1)
    if timer <> invalid and timer.isSameNodeType("Timer") then
        m.top.removeChild(timer)
    end if
    showCurrentQuestion()
end sub 