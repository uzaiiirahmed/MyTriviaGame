sub init()
    m.triviaList = m.top.findNode("triviaList")

    m.triviaTypes = []
    ' Load trivia data from JSON file
    jsonStr = invalid
    dataPath = "pkg:/trivia_data.json"
    jsonStr = ReadAsciiFile(dataPath)
    if jsonStr <> invalid
        parsed = ParseJson(jsonStr)
        if type(parsed) = "roArray"
            m.triviaTypes = parsed
        else
            print "[MainScene] - Failed to parse trivia_data.json as array."
        end if
    else
        print "[MainScene] - trivia_data.json not found or could not be read."
    end if

    ' Load progress from tmp:/tmp.json
    m.progress = {}
    progressStr = ReadAsciiFile("tmp:/tmp.json")
    if progressStr <> invalid and progressStr <> ""
        progressParsed = ParseJson(progressStr)
        if type(progressParsed) = "roAssociativeArray"
            m.progress = progressParsed
        end if
    end if

    if m.triviaTypes.count() = 0
        m.triviaTypes = [{ title: "No Data", description: "No trivia data found.", question: "", answers: [] }]
    end if

    ' Create a ContentNode for the list
    listContent = CreateObject("roSGNode", "ContentNode")
    for i = 0 to m.triviaTypes.count()-1
        t = m.triviaTypes[i]
        item = CreateObject("roSGNode", "ContentNode")
        item.title = t.title
        item.description = t.description
        item.HDPosterUrl = t.image
        ' Add custom field for lock state
        item.addField("isLocked", "boolean", false)
        if i = 0 then
            item.isLocked = false
        else
            item.isLocked = true
        end if
        ' Add progress field
        item.addField("progressText", "string", false)
        totalQuestions = 0
        if t.questions <> invalid and type(t.questions) = "roArray" then totalQuestions = t.questions.count() else totalQuestions = 10 ' fallback
        completed = 0
        if m.progress.DoesExist(t.title) then completed = m.progress[t.title] else completed = 0
        item.progressText = completed.tostr() + "/" + totalQuestions.tostr() + " Complete"
        ' Attach current progress index to trivia object
        t.currentQuestionIndex = completed
        listContent.appendChild(item)
    end for
    ' Add Reset Progress card
    resetItem = CreateObject("roSGNode", "ContentNode")
    resetItem.title = "Reset Progress"
    resetItem.description = "Reset all trivia progress to the start."
    resetItem.HDPosterUrl = "pkg:/images/resetprogress.png" ' Set image on initial load too
    resetItem.addField("isLocked", "boolean", false)
    resetItem.isLocked = false
    resetItem.addField("progressText", "string", false)
    resetItem.progressText = ""
    resetItem.addField("isResetCard", "boolean", false)
    resetItem.isResetCard = true
    listContent.appendChild(resetItem)
    m.triviaList.content = listContent
    m.triviaList.setFocus(true)
    m.triviaList.observeField("itemSelected", "onTriviaSelected")
    m.top.triviaTypes = m.triviaTypes
    m.top.refreshProgress = refreshProgress
    m.resetPanel = invalid
    m.resetPanelVisible = false
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if m.resetPanelVisible then
        if m.resetPanel <> invalid and m.resetPanel.onKeyEvent <> invalid then
            result = m.resetPanel.onKeyEvent(key, press)
            if result = invalid then return false else return result
        end if
        return false
    end if
    if press then
        if key = "OK" then
            idx = m.triviaList.itemFocused
            item = m.triviaList.content.getChild(idx)
            if item <> invalid and item.hasField("isResetCard") and item.isResetCard = true then
                showResetPanel()
                return true
            end if
            if idx >= 0 and idx < m.triviaTypes.count()
                print "[MainScene] - OK pressed. Sending trivia selection signal for item: " + stri(idx)
                m.top.selectedTrivia = m.triviaTypes[idx]
                return true
            end if
        end if
    end if
    return false
end function

sub showQuestionScene(trivia as Object)
    ' This function is no longer needed, navigation is handled by the Router.
end sub

sub onTriviaSelected()
    idx = m.triviaList.itemSelected
    print "[MainScene] - itemSelected fired, idx="; idx
    if idx >= 0 and idx < m.triviaTypes.count()
        print "[MainScene] - Setting selectedTrivia for Router"
        m.top.selectedTrivia = m.triviaTypes[idx]
    end if
end sub

function refreshProgress() as Void
    m = m.top

    ' Read saved progress from file
    m.progress = {}
    progressStr = ReadAsciiFile("tmp:/tmp.json")
    if progressStr <> invalid and progressStr <> ""
        progressParsed = ParseJson(progressStr)
        if type(progressParsed) = "roAssociativeArray"
            m.progress = progressParsed
        end if
    end if

    ' Update the progress text for each trivia type
    listContent = m.triviaList.content
    for i = 0 to m.triviaTypes.count() - 1
        t = m.triviaTypes[i]
        item = listContent.getChild(i)
        
        totalQuestions = t.questions.count()
        completed = 0
        if m.progress.DoesExist(t.title)
            completed = m.progress[t.title]
        end if

        item.progressText = completed.tostr() + "/" + totalQuestions.tostr() + " Complete"
    end for

    ' Apply the changes to the list
    m.triviaList.content = listContent
end function

sub resetProgress()
    print "[MainScene] - Resetting all trivia progress"
    ' Only clear progress, not subscription
    m.progress = {}

    reg = CreateObject("roRegistrySection", "TriviaGameSave")
    for i = 0 to m.triviaTypes.count()-1
        title = m.triviaTypes[i].title
        reg.Delete(title)
        m.triviaTypes[i].currentQuestionIndex = 0
    end for
    reg.Flush()

    ' Rebuild the list
    listContent = CreateObject("roSGNode", "ContentNode")
    for i = 0 to m.triviaTypes.count()-1
        t = m.triviaTypes[i]
        item = CreateObject("roSGNode", "ContentNode")
        item.title = t.title
        item.description = t.description
        item.HDPosterUrl = t.image
        item.addField("isLocked", "boolean", false)
        if i = 0 then
            item.isLocked = false
        else
            item.isLocked = true
        end if
        item.addField("progressText", "string", false)
        item.progressText = "0/" + (t.questions.count().tostr()) + " Complete"
        listContent.appendChild(item)
    end for
    ' Add Reset Progress card again
    resetItem = CreateObject("roSGNode", "ContentNode")
    resetItem.title = "Reset Progress"
    resetItem.description = "Reset all trivia progress to the start."
    resetItem.HDPosterUrl = "pkg:/images/resetprogress.png" ' or "" if you haven't added the image yet
    resetItem.addField("isLocked", "boolean", false)
    resetItem.isLocked = false
    resetItem.addField("progressText", "string", false)
    resetItem.progressText = ""
    resetItem.addField("isResetCard", "boolean", false)
    resetItem.isResetCard = true
    listContent.appendChild(resetItem)
    m.triviaList.content = listContent
end sub

sub showResetPanel()
    if m.resetPanelVisible then return
    m.resetPanel = CreateObject("roSGNode", "ResetProgressPanel")
    m.resetPanel.observeField("onYes", "onResetYes")
    m.resetPanel.observeField("onNo", "onResetNo")
    m.top.appendChild(m.resetPanel)
    m.resetPanelVisible = true
    m.resetPanel.setFocus(true)
end sub

sub onResetYes()
    if m.resetPanel <> invalid then
        m.top.removeChild(m.resetPanel)
        m.resetPanel = invalid
        m.resetPanelVisible = false
    end if
    resetProgress()
    m.triviaList.setFocus(true)
end sub

sub onResetNo()
    if m.resetPanel <> invalid then
        m.top.removeChild(m.resetPanel)
        m.resetPanel = invalid
        m.resetPanelVisible = false
    end if
    m.triviaList.setFocus(true)
end sub
