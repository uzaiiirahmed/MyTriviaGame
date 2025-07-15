sub init()
    m.mainScene = m.top.findNode("mainScene")
    m.questionScene = m.top.findNode("questionScene")
    m.subscriptionPanel = m.top.findNode("subscriptionPanel")

    ' Load unlock state from registry
    reg = CreateObject("roRegistrySection", "TriviaGameSave")
    unlocked = reg.Read("triviaUnlocked")
    m.triviaUnlocked = (unlocked = "true")

    m.mainScene.observeField("selectedTrivia", "onTriviaSelected")
    m.questionScene.observeField("backToMain", "onBackToMain")
    m.subscriptionPanel.observeField("onSubscribe", "onSubscribe")
    m.subscriptionPanel.observeField("onCancel", "onCancel")
end sub

sub onTriviaSelected()
    trivia = m.mainScene.selectedTrivia
    print "[Router] - onTriviaSelected called, trivia="; trivia
    if trivia <> invalid
        ' Only allow first trivia for free, others require subscription
        idx = 0
        triviaList = m.mainScene.triviaTypes
        for i = 0 to triviaList.count()-1
            if triviaList[i].title = trivia.title then idx = i : exit for
        end for
        if idx = 0 or m.triviaUnlocked = true then
            ' Pass current progress index if available
            if trivia.DoesExist("currentQuestionIndex") then
                m.questionScene.trivia = trivia
                m.questionScene.trivia.currentQuestionIndex = trivia.currentQuestionIndex
            else
                m.questionScene.trivia = trivia
            end if
            m.mainScene.visible = false
            m.questionScene.visible = true
            m.questionScene.setFocus(true)
        else
            m.mainScene.visible = false
            m.subscriptionPanel.visible = true
            m.subscriptionPanel.setFocus(true)
        end if
    end if
end sub

sub onSubscribe()
    print "[Router] - User chose to subscribe. Unlocking trivia."
    m.triviaUnlocked = true

    ' Save unlock state in registry
    reg = CreateObject("roRegistrySection", "TriviaGameSave")
    reg.Write("triviaUnlocked", "true")
    reg.Flush()

    ' Unlock all trivia in the main menu
    triviaListNode = m.mainScene.findNode("triviaList")
    if triviaListNode <> invalid then
        listContent = triviaListNode.content
        for i = 0 to listContent.getChildCount() - 1
            node = listContent.getChild(i)
            if node.hasField("isLocked")
                node.isLocked = false
            end if
        end for
    end if
    m.subscriptionPanel.setFocus(false)
    m.subscriptionPanel.visible = false
    m.mainScene.visible = true
    m.mainScene.findNode("triviaList").setFocus(true)
end sub

sub onCancel()
    print "[Router] - User cancelled subscription. Returning to main menu."
    m.subscriptionPanel.setFocus(false)
    m.subscriptionPanel.visible = false
    m.mainScene.visible = true
    m.mainScene.findNode("triviaList").setFocus(true)
end sub

sub onBackToMain()
    print "[Router] - onBackToMain called, backToMain = " + m.questionScene.backToMain.tostr()
    if m.questionScene.backToMain = true
        print "[Router] - Switching back to main scene"
        ' Switch visibility
        m.questionScene.visible = false
        m.mainScene.visible = true
        m.mainScene.refreshProgress = true
        ' Set focus to triviaList after a short delay to ensure UI is ready
        focusTimer = CreateObject("roSGNode", "Timer")
        focusTimer.id = "focusTimer"
        focusTimer.duration = 0.1 ' 100ms delay
        focusTimer.control = "start"
        focusTimer.observeField("fire", "onFocusTimerFired")
        m.mainScene.appendChild(focusTimer)
        ' Reset field to allow re-triggering
        m.questionScene.backToMain = false
    end if
end sub

sub onFocusTimerFired()
    print "[Router] - Focus timer fired, setting focus to triviaList"
    triviaList = m.mainScene.findNode("triviaList")
    if triviaList <> invalid then
        triviaList.setFocus(true)
    end if
    ' Remove the timer node after firing
    timer = m.mainScene.findNode("focusTimer")
    if timer <> invalid then m.mainScene.removeChild(timer)
end sub 