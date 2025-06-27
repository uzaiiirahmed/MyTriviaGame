sub init()
    m.titleLabel = m.top.findNode("titleLabel")
    m.triviaList = m.top.findNode("triviaList")
    m.descLabel = m.top.findNode("descLabel")

    ' Define 10 trivia types with descriptions and sample questions/answers
    m.triviaTypes = [
        { title: "General Knowledge", description: "Test your general knowledge!", question: "What is the capital of France?", answers: ["Paris", "London", "Berlin", "Rome"] },
        { title: "Science", description: "Explore the wonders of science.", question: "What planet is known as the Red Planet?", answers: ["Mars", "Venus", "Jupiter", "Saturn"] },
        { title: "History", description: "Dive into historical facts.", question: "Who was the first President of the United States?", answers: ["George Washington", "Abraham Lincoln", "John Adams", "Thomas Jefferson"] },
        { title: "Geography", description: "World, countries, and places.", question: "Which is the largest ocean?", answers: ["Pacific", "Atlantic", "Indian", "Arctic"] },
        { title: "Sports", description: "For the sports enthusiasts.", question: "How many players in a soccer team?", answers: ["11", "9", "7", "5"] },
        { title: "Movies", description: "Cinema and film trivia.", question: "Who directed 'Jurassic Park'?", answers: ["Steven Spielberg", "James Cameron", "George Lucas", "Tim Burton"] },
        { title: "Music", description: "Notes, artists, and songs.", question: "Who is known as the King of Pop?", answers: ["Michael Jackson", "Elvis Presley", "Prince", "Freddie Mercury"] },
        { title: "Literature", description: "Books and famous authors.", question: "Who wrote 'Romeo and Juliet'?", answers: ["William Shakespeare", "Jane Austen", "Mark Twain", "Charles Dickens"] },
        { title: "Technology", description: "Gadgets, IT, and more.", question: "What does 'CPU' stand for?", answers: ["Central Processing Unit", "Computer Power Unit", "Central Print Unit", "Control Processing Unit"] },
        { title: "Food & Drink", description: "Culinary questions.", question: "Which fruit is used to make wine?", answers: ["Grapes", "Apples", "Oranges", "Bananas"] }
    ]

    ' Create a ContentNode for the list
    listContent = CreateObject("roSGNode", "ContentNode")
    for each t in m.triviaTypes
        item = CreateObject("roSGNode", "ContentNode")
        item.title = t.title
        listContent.appendChild(item)
    end for
    m.triviaList.content = listContent
    m.triviaList.setFocus(true)

    ' Show description for the first item
    m.descLabel.text = m.triviaTypes[0].description

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
