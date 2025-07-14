sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("Router")
    screen.show()

    ' --- Start Background Music ---
    m.audioPlayer = CreateObject("roAudioPlayer")
    m.audioPort = CreateObject("roMessagePort")
    m.audioPlayer.SetMessagePort(m.audioPort)

    m.audioPlayer.AddContent({
        url: "pkg:/audio/music1.mp3"
    })

    m.audioPlayer.SetLoop(true)
    m.audioPlayer.Play()
    ' --- End Background Music ---

    while true
        msg = wait(0, m.port)
        if type(msg) = "roSGScreenEvent" and msg.isScreenClosed()
            ' --- Stop Music on App Exit ---
            if m.audioPlayer <> invalid then
                m.audioPlayer.Stop()
            end if
            exit while
        end if
    end while
end sub
