sub init()
    m.mainScene = m.top.findNode("mainScene")
    m.questionScene = m.top.findNode("questionScene")
    m.subscriptionPanel = m.top.findNode("subscriptionPanel")

    m.mainScene.observeField("selectedTrivia", "onTriviaSelected")
    m.questionScene.observeField("backToMain", "onBackToMain")
    m.subscriptionPanel.observeField("onSubscribe", "onSubscribe")
    m.subscriptionPanel.observeField("onCancel", "onCancel")
    m.triviaUnlocked = false ' This should be loaded from registry in a real app
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
            m.questionScene.trivia = trivia
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
    m.triviaUnlocked = true ' In real app, save to registry
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
    if m.questionScene.backToMain = true
        ' Switch visibility
        m.questionScene.visible = false
        m.mainScene.visible = true
        m.mainScene.findNode("triviaList").setFocus(true)

        ' Reset field to allow re-triggering
        m.questionScene.backToMain = false
    end if
end sub 