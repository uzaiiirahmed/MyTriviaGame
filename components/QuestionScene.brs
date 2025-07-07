' QuestionScene.brs - rewritten for modern UI and robust logic

sub init()
    m.titleLabel = m.top.findNode("titleLabel")
    m.questionLabel = m.top.findNode("questionLabel")
    m.answerList = m.top.findNode("answerList")
    m.feedbackLabel = m.top.findNode("feedbackLabel")
    m.sideImage = m.top.findNode("sideImage")
    m.currentQuestionIndex = 0
    m.trivia = invalid
    m.questions = []
    m.correctIndex = -1
    m.answered = false
end sub

sub onTriviaChanged()
    m.trivia = m.top.trivia
    m.currentQuestionIndex = 0
    showCurrentQuestion()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        if key = "OK" then
            idx = m.answerList.itemFocused
            if idx < 0 then return false
            content = m.answerList.content
            if content = invalid or content.getChildCount() = 0 then return false
            ' Reset all
            for i = 0 to content.getChildCount() - 1
                item = content.getChild(i)
                item.isSelected = false
                item.isIncorrect = false
                content.updateChild(i, item)
            end for
            item = content.getChild(idx)
            if idx = m.trivia.questions[m.currentQuestionIndex].correctIndex then
                item.isSelected = true
                m.feedbackLabel.text = "Correct!"
            else
                item.isIncorrect = true
                m.feedbackLabel.text = "Wrong!"
            end if
            content.updateChild(idx, item)
            m.answerList.content = content
            ' Move to next question after 1.5s
            sleep(1500)
            m.currentQuestionIndex = m.currentQuestionIndex + 1
            showCurrentQuestion()
            return true
        else if key = "back" then
            m.top.backToMain = true
            return true
        end if
    end if
    return false
end function

sub showCurrentQuestion()
    trivia = m.trivia
    idx = m.currentQuestionIndex
    if trivia <> invalid and trivia.questions.count() > idx
        q = trivia.questions[idx]
        m.titleLabel.text = trivia.title
        m.questionLabel.text = q.question

        ' Populate answers
        answers = q.answers
        listContent = CreateObject("roSGNode", "ContentNode")
        for i = 0 to answers.count() - 1
            item = CreateObject("roSGNode", "ContentNode")
            item.title = answers[i]
            item.isSelected = false
            item.isIncorrect = false
            listContent.appendChild(item)
        end for
        m.answerList.content = listContent
        m.answerList.itemFocused = 0
        m.answerList.setFocus(true)
        if listContent.getChildCount() = 0
            m.answerList.setFocus(false)
        end if
        m.feedbackLabel.text = ""
    else
        m.titleLabel.text = trivia.title
        m.questionLabel.text = "Quiz Complete!"
        m.answerList.content = CreateObject("roSGNode", "ContentNode")
        m.answerList.setFocus(false)
        m.feedbackLabel.text = ""
    end if
end sub

sub onAnswerSelected()
    idx = m.answerList.itemFocused
    if m.answered return
    m.answered = true
    options = m.answerList.content
    for i = 0 to options.count() - 1
        options[i].isSelected = (i = idx)
    end for
    m.answerList.content = options
    if idx = m.correctIndex then
        m.feedbackLabel.text = "Correct!"
    else
        m.feedbackLabel.text = "Wrong!"
    end if
    ' Move to next question after 1.5s
    sleep(1500)
    m.currentQuestionIndex = m.currentQuestionIndex + 1
    showCurrentQuestion()
end sub

sub showFunFactScreen(q as Object)
    ' Placeholder: show fun fact logic here
    m.questionLabel.text = "Fun Fact: " + q.funfact
    ' After a delay, go to next question
    sleep(2000)
    onNextQuestionTimer()
end sub

sub onNextQuestionTimer()
    if m.nextTimer <> invalid then m.nextTimer.control = "stop"
    m.currentQuestionIndex = m.currentQuestionIndex + 1
    showCurrentQuestion()
end sub 