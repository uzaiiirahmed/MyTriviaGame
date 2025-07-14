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
    m.triviaList.content = listContent
    m.triviaList.setFocus(true)
    m.triviaList.observeField("itemSelected", "onTriviaSelected")
    m.top.triviaTypes = m.triviaTypes
    m.top.refreshProgress = refreshProgress
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        if key = "OK" then
            idx = m.triviaList.itemFocused
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
    m = m.top ' Ensure m is the component's m.top
    m.progress = {}
    progressStr = ReadAsciiFile("tmp:/tmp.json")
    if progressStr <> invalid and progressStr <> ""
        progressParsed = ParseJson(progressStr)
        if type(progressParsed) = "roAssociativeArray"
            m.progress = progressParsed
        end if
    end if
    listContent = m.triviaList.content
    for i = 0 to m.triviaTypes.count()-1
        t = m.triviaTypes[i]
        item = listContent.getChild(i)
        totalQuestions = 0
        if t.questions <> invalid and type(t.questions) = "roArray" then totalQuestions = t.questions.count() else totalQuestions = 10
        completed = 0
        if m.progress.DoesExist(t.title) then completed = m.progress[t.title] else completed = 0
        item.progressText = completed.tostr() + "/" + totalQuestions.tostr() + " Complete"
    end for
    m.triviaList.content = listContent
end function
