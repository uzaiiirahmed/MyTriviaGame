sub init()
    m.titleLabel = m.top.findNode("titleLabel")
    m.triviaMenu = m.top.findNode("triviaMenu")

    rowListContent = CreateObject("roSGNode", "ContentNode")
    rowNode = CreateObject("roSGNode", "ContentNode")
    rowNode.title = "Sample Row"

    item1 = CreateObject("roSGNode", "ContentNode")
    item1.title = "Item 1"
    rowNode.appendChild(item1)

    item2 = CreateObject("roSGNode", "ContentNode")
    item2.title = "Item 2"
    rowNode.appendChild(item2)

    rowListContent.appendChild(rowNode)
    m.triviaMenu.content = rowListContent
end sub 