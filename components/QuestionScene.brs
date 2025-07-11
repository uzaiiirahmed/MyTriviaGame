' QuestionScene.brs - rewritten for modern UI and robust logic

sub init()
    m.titleLabel = m.top.findNode("titleLabel")
    m.questionLabel = m.top.findNode("questionLabel")
    m.answerList = m.top.findNode("answerList")
    m.feedbackLabel = m.top.findNode("feedbackLabel")
    m.sideImage = m.top.findNode("sideImage")
    m.feedbackIcon = m.top.findNode("feedbackIcon")
    m.currentQuestionIndex = 0
    m.trivia = invalid
    m.questions = []
    m.correctIndex = -1
    m.answered = false
    m.attempts = 0
    m.funFactPanel = invalid
    m.funFactDelayTimer = m.top.findNode("funFactDelayTimer")
    if m.funFactDelayTimer <> invalid then
        m.funFactDelayTimer.observeField("fire", "onFunFactDelayTimerFired")
    end if
    m.pendingFunFactQuestion = invalid
    
    ' LabelList doesn't support itemComponentName, so we'll use ContentNode with proper color management
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
            selected = content.getChild(idx).title
            print "Selected answer: " + selected
            if idx = m.trivia.questions[m.currentQuestionIndex].correctIndex
                print "[QuestionScene] - Correct answer selected!"
                m.feedbackLabel.text = "Correct!"
                m.feedbackIcon.uri = "pkg:/images/correct_icon.png"
                q = m.trivia.questions[m.currentQuestionIndex]
                ' Store the selected answer index for visual feedback
                m.selectedAnswerIndex = idx
                m.isCorrectAnswer = true
                m.pendingFunFactQuestion = q
                ' Keep focus on the selected answer during delay
                m.answerList.itemFocused = idx
                print "[QuestionScene] - Starting fun fact delay timer..."
                if m.funFactDelayTimer <> invalid then
                    m.funFactDelayTimer.control = "start"
                else
                    print "[QuestionScene] - No timer, showing fun fact immediately"
                    showFunFactScreen(q)
                end if
            else
                m.attempts = m.attempts + 1
                if m.attempts = 1
                    m.feedbackLabel.text = "Wrong! Try again"
                    m.feedbackIcon.uri = "pkg:/images/wrong_icon.png"
                    startFeedbackClearTimer()
                else
                    print "[QuestionScene] - Wrong answer selected (attempt " + stri(m.attempts) + ")"
                    m.feedbackLabel.text = "Wrong!"
                    m.feedbackIcon.uri = "pkg:/images/wrong_icon.png"
                    q = m.trivia.questions[m.currentQuestionIndex]
                    ' Store the selected answer index for visual feedback
                    m.selectedAnswerIndex = idx
                    m.isCorrectAnswer = false
                    m.pendingFunFactQuestion = q
                    ' Keep focus on the selected answer during delay
                    m.answerList.itemFocused = idx
                    print "[QuestionScene] - Starting fun fact delay timer for wrong answer..."
                    if m.funFactDelayTimer <> invalid then
                        m.funFactDelayTimer.control = "start"
                    else
                        print "[QuestionScene] - No timer, showing fun fact immediately"
                        showFunFactScreen(q)
                    end if
                end if
            end if
            return true
        else if key = "back" then
            m.top.backToMain = true
            return true
        end if
    end if
    return false
end function

sub onFunFactDelayTimerFired()
    print "[QuestionScene] - Fun fact delay timer fired!"
    if m.pendingFunFactQuestion <> invalid then
        print "[QuestionScene] - Showing fun fact panel..."
        showFunFactScreen(m.pendingFunFactQuestion)
        m.pendingFunFactQuestion = invalid
    else
        print "[QuestionScene] - No pending fun fact question!"
    end if
end sub

sub showCurrentQuestion()
    trivia = m.trivia
    idx = m.currentQuestionIndex
    m.attempts = 0
    if trivia <> invalid and trivia.questions.count() > idx
        q = trivia.questions[idx]
        m.titleLabel.text = trivia.title
        m.questionLabel.text = q.question

        ' Set the side image from trivia data
        if m.sideImage <> invalid and trivia.image <> invalid
            m.sideImage.uri = trivia.image
        end if

        ' Reset feedback icon
        if m.feedbackIcon <> invalid then
            m.feedbackIcon.uri = ""
        end if

        ' Reset focus highlight to default
        if m.answerList <> invalid then
            m.answerList.focusBitmapUri = "pkg:/images/focus_highlight.png"
        end if

        ' Populate answers
        answers = q.answers
        listContent = CreateObject("roSGNode", "ContentNode")
        for i = 0 to answers.count() - 1
            item = CreateObject("roSGNode", "ContentNode")
            item.title = answers[i]
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
        if m.feedbackIcon <> invalid then
            m.feedbackIcon.uri = ""
        end if
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
    print "[QuestionScene] - Creating fun fact panel..."
    if m.funFactPanel <> invalid then m.top.removeChild(m.funFactPanel)
    m.funFactPanel = createObject("roSGNode", "FunFactPanel")
    m.funFactPanel.funfact = q.funfact
    m.funFactPanel.observeField("onContinue", "onFunFactContinue")
    m.top.appendChild(m.funFactPanel)
    m.funFactPanel.setFocus(true)
    
    ' Set the focus highlight based on whether the answer was correct
    if m.isCorrectAnswer then
        m.answerList.focusBitmapUri = "pkg:/images/correct.png"
    else
        m.answerList.focusBitmapUri = "pkg:/images/wrong.png"
    end if
    
    print "[QuestionScene] - Fun fact panel created and focused"
end sub

sub onFunFactContinue()
    if m.funFactPanel <> invalid then m.top.removeChild(m.funFactPanel)
    m.currentQuestionIndex = m.currentQuestionIndex + 1
    showCurrentQuestion()
    ' Set focus back to the answerList for the next question
    if m.answerList <> invalid then
        m.answerList.setFocus(true)
    end if
end sub

sub startNextQuestionTimer()
    if m.nextTimer <> invalid then m.nextTimer.control = "stop"
    m.nextTimer = createObject("roSGNode", "Timer")
    m.nextTimer.duration = 1.5
    m.nextTimer.observeField("fire", "onNextQuestionTimer")
    m.top.appendChild(m.nextTimer)
    m.nextTimer.control = "start"
end sub

sub startFeedbackClearTimer()
    if m.feedbackTimer <> invalid then m.feedbackTimer.control = "stop"
    m.feedbackTimer = createObject("roSGNode", "Timer")
    m.feedbackTimer.duration = 1.5
    m.feedbackTimer.observeField("fire", "onFeedbackClearTimer")
    m.top.appendChild(m.feedbackTimer)
    m.feedbackTimer.control = "start"
end sub

sub onFeedbackClearTimer()
    if m.feedbackTimer <> invalid then m.feedbackTimer.control = "stop"
    m.feedbackLabel.text = ""
    m.feedbackIcon.uri = ""
    if m.answerList <> invalid then
        m.answerList.focusBitmapUri = "pkg:/images/focus_highlight.png"
        m.answerList.setFocus(false)
        m.answerList.setFocus(true)
    end if
end sub 