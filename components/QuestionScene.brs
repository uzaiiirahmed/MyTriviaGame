' QuestionScene.brs - with persistent progress saving using roRegistry

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
end sub

sub cleanupPendingFunFact()
    if m.funFactDelayTimer <> invalid then m.funFactDelayTimer.control = "stop"
    if m.funFactPanel <> invalid then m.top.removeChild(m.funFactPanel)
    m.funFactPanel = invalid
    m.pendingFunFactQuestion = invalid
    m.answered = false
end sub

sub onTriviaChanged()
    cleanupPendingFunFact()
    m.trivia = m.top.trivia
    m.currentQuestionIndex = 0

    reg = CreateObject("roRegistrySection", "TriviaGameSave")
    if m.trivia <> invalid and m.trivia.title <> invalid then
        savedIndex = reg.Read(m.trivia.title)
        if savedIndex <> invalid and savedIndex <> "" then
            m.currentQuestionIndex = val(savedIndex)
            print "[TriviaGame] Loaded saved progress for " + m.trivia.title + ": " + stri(m.currentQuestionIndex)
        else
            print "[TriviaGame] No saved progress found for " + m.trivia.title
        end if
    end if

    showCurrentQuestion()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if m.funFactPanel <> invalid and m.funFactPanel.isInFocusChain() then
        if key = "back" and press then
            cleanupPendingFunFact()
            m.top.backToMain = true
            return true
        end if
        if m.funFactPanel.onKeyEvent <> invalid then
            handled = m.funFactPanel.onKeyEvent(key, press)
            if handled then return true
        end if
    end if

    if press then
        if key = "OK" then
            idx = m.answerList.itemFocused
            if idx < 0 then return false

            content = m.answerList.content
            if content = invalid or content.getChildCount() = 0 then return false

            selected = content.getChild(idx).title
            print "Selected answer: " + selected

            if idx = m.trivia.questions[m.currentQuestionIndex].correctIndex then
                m.feedbackLabel.text = "Correct!"
                m.feedbackIcon.uri = "pkg:/images/correct_icon.png"
                q = m.trivia.questions[m.currentQuestionIndex]
                m.selectedAnswerIndex = idx
                m.isCorrectAnswer = true
                m.pendingFunFactQuestion = q
                m.answerList.itemFocused = idx
                if m.funFactDelayTimer <> invalid then
                    m.funFactDelayTimer.control = "start"
                else
                    showFunFactScreen(q)
                end if
            else
                m.attempts = m.attempts + 1
                if m.attempts = 1 then
                    m.feedbackLabel.text = "Wrong! Try again"
                    m.feedbackIcon.uri = "pkg:/images/wrong_icon.png"
                    startFeedbackClearTimer()
                else
                    m.feedbackLabel.text = "Wrong!"
                    m.feedbackIcon.uri = "pkg:/images/wrong_icon.png"
                    q = m.trivia.questions[m.currentQuestionIndex]
                    m.selectedAnswerIndex = idx
                    m.isCorrectAnswer = false
                    m.pendingFunFactQuestion = q
                    m.answerList.itemFocused = idx
                    if m.funFactDelayTimer <> invalid then
                        m.funFactDelayTimer.control = "start"
                    else
                        showFunFactScreen(q)
                    end if
                end if
            end if
            return true

        else if key = "back" then
            updateProgress()
            cleanupPendingFunFact()
            m.top.backToMain = true
            return true
        end if
    end if

    return false
end function

sub onFunFactDelayTimerFired()
    if m.pendingFunFactQuestion <> invalid then
        showFunFactScreen(m.pendingFunFactQuestion)
        m.pendingFunFactQuestion = invalid
    end if
end sub

sub showCurrentQuestion()
    trivia = m.trivia
    idx = m.currentQuestionIndex
    m.attempts = 0
    totalQuestions = trivia.questions.count()

    if idx < totalQuestions then
        q = trivia.questions[idx]
        m.titleLabel.text = trivia.title
        m.questionLabel.text = "Q " + stri(idx + 1) + "/" + stri(totalQuestions) + " :   " + q.question

        if m.sideImage <> invalid and trivia.image <> invalid then
            m.sideImage.uri = trivia.image
        end if

        if m.feedbackIcon <> invalid then m.feedbackIcon.uri = ""

        if m.answerList <> invalid then m.answerList.focusBitmapUri = "pkg:/images/focus_highlight.png"

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
        if listContent.getChildCount() = 0 then m.answerList.setFocus(false)
        m.feedbackLabel.text = ""

    else
        m.titleLabel.text = trivia.title
        m.questionLabel.text = "Quiz Complete!"
        m.answerList.content = CreateObject("roSGNode", "ContentNode")
        m.answerList.setFocus(false)
        m.feedbackLabel.text = ""
        if m.feedbackIcon <> invalid then m.feedbackIcon.uri = ""
        updateProgress()
    end if
end sub

sub showFunFactScreen(q as Object)
    if m.funFactPanel <> invalid then m.top.removeChild(m.funFactPanel)

    m.funFactPanel = createObject("roSGNode", "FunFactPanel")
    m.funFactPanel.funfact = q.funfact

    if m.trivia <> invalid and m.trivia.image <> invalid then
        m.funFactPanel.sideImageUri = m.trivia.image
    end if

    m.funFactPanel.observeField("onContinue", "onFunFactContinue")
    m.top.appendChild(m.funFactPanel)
    m.funFactPanel.setFocus(true)

    if m.isCorrectAnswer then
        m.answerList.focusBitmapUri = "pkg:/images/correct.png"
    else
        m.answerList.focusBitmapUri = "pkg:/images/wrong.png"
    end if
end sub

sub onFunFactContinue()
    if m.funFactPanel <> invalid then
        m.top.removeChild(m.funFactPanel)
        m.funFactPanel = invalid
    end if

    totalQuestions = m.trivia.questions.count()
    if m.currentQuestionIndex < totalQuestions then
        m.currentQuestionIndex = m.currentQuestionIndex + 1
    end if

    updateProgress()
    showCurrentQuestion()

    if m.answerList <> invalid and m.answerList.content.getChildCount() > 0 then
        m.answerList.setFocus(true)
    else
        m.top.setFocus(true)
    end if
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

sub updateProgress()
    if m.trivia = invalid or m.trivia.title = invalid return

    title = m.trivia.title
    reg = CreateObject("roRegistrySection", "TriviaGameSave")
    reg.Write(title, m.currentQuestionIndex.ToStr())
    reg.Flush()

    print "[TriviaGame] Progress saved for " + title + ": " + stri(m.currentQuestionIndex)
end sub

sub clearProgress()
    if m.trivia = invalid or m.trivia.title = invalid return

    reg = CreateObject("roRegistrySection", "TriviaGameSave")
    reg.Delete(m.trivia.title)
    reg.Flush()

    print "[TriviaGame] Progress cleared for " + m.trivia.title
end sub

sub onUnfocus()
    updateProgress()
end sub
