Core = inherit(Singleton)
inherit(Autoloader, Core)

function Core:constructor()
    self:initAllClasses()

    -- tell the server that the core resource has been loaded
    triggerServerEvent("onPlayerCoreResourceStarted", resourceRoot)

    setPlayerHudComponentVisible("all", false)
    setTime(14, 0)
    setMinuteDuration(3600000)
    setWeather(4)
    setAmbientSoundEnabled("general", false)
    setCloudsEnabled(false)
    fadeCamera(true)
end

function Core:destructor()
    self:destroyAllClasses()
end