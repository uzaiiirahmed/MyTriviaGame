sub init()
    m.titleLabel = m.top.findNode("titleLabel")
    m.triviaList = m.top.findNode("triviaList")
    m.descLabel = m.top.findNode("descLabel")

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

    if m.triviaTypes.count() = 0
        m.triviaTypes = [{ title: "No Data", description: "No trivia data found.", question: "", answers: [] }]
        m.descLabel.text = "No trivia data found."
    else
        m.descLabel.text = m.triviaTypes[0].description
    end if

    ' Create a ContentNode for the list
    listContent = CreateObject("roSGNode", "ContentNode")
    for each t in m.triviaTypes
        item = CreateObject("roSGNode", "ContentNode")
        item.title = t.title
        listContent.appendChild(item)
    end for
    m.triviaList.content = listContent
    m.triviaList.setFocus(true)

    ' Observe itemFocused to update description
    m.triviaList.ObserveField("itemFocused", "onItemFocused")
end sub

sub onItemFocused()
    idx = m.triviaList.itemFocused
    if idx >= 0 and idx < m.triviaTypes.count()
        m.descLabel.text = m.triviaTypes[idx].description
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        if key = "OK" then
            idx = m.triviaList.itemFocused
            print "[MainScene] - OK pressed. Sending trivia selection signal for item: " + stri(idx)
            m.top.selectedTrivia = m.triviaTypes[idx]
            return true
        end if
    end if
    return false
end function

sub showQuestionScene(trivia as Object)
    ' This function is no longer needed, navigation is handled by the Router.
end sub
