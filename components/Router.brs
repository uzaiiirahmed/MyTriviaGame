sub init()
    m.mainScene = m.top.findNode("mainScene")
    m.questionScene = m.top.findNode("questionScene")

    m.mainScene.observeField("selectedTrivia", "onTriviaSelected")
    m.questionScene.observeField("backToMain", "onBackToMain")
end sub

sub onTriviaSelected()
    trivia = m.mainScene.selectedTrivia
    if trivia <> invalid
        ' Pass data to question scene
        m.questionScene.trivia = trivia
        
        ' Switch visibility
        m.mainScene.visible = false
        m.questionScene.visible = true
        m.questionScene.setFocus(true)
    end if
end sub

sub onBackToMain()
    if m.questionScene.backToMain = true
        ' Switch visibility
        m.questionScene.visible = false
        m.mainScene.visible = true
        m.mainScene.setFocus(true)

        ' Reset field to allow re-triggering
        m.questionScene.backToMain = false
    end if
end sub 