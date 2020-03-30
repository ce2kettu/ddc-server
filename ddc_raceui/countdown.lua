local SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()
local COUNTDOWN_WIDTH, COUNTDOWN_HEIGHT = 250, 250
local START_X = (SCREEN_WIDTH / 2) - (COUNTDOWN_WIDTH / 2)
local START_Y = (SCREEN_HEIGHT / 3) - (COUNTDOWN_HEIGHT / 2)
local FADE_SPEED = 0.2

Countdown = {}

function Countdown:constructor()
    self.isFinished = false
    self.minCount = 0
    self.maxCount = 3
    self.currentCount = self.maxCount + 1
    self.alpha = 255
    self.animationDelta = 0
    self.currentTick = 0
    self.lastTick = false

    self._onClientRender = bind(self.render, self)
    addEventHandler("onClientRender", root, self._onClientRender)
end

function Countdown:destructor()
    removeEventHandler("onClientRender", root, self._onClientRender)
end

function Countdown:render()
    if (self.isFinished) then return end

    if (self.lastTick) then
        self.animationDelta = getTickCount() - self.lastTick
        self.animationDelta = math.min(self.animationDelta, (1 / 60) * 1000)
    end

    self.lastTick = getTickCount()

    if (getTickCount() - self.currentTick > 1000) then

        self.currentTick = getTickCount()
        self.currentCount = self.currentCount - 1

        if (self.currentCount > self.minCount) then
            self.alpha = 255
            playSound("assets/sounds/cd.wav")
        elseif (self.currentCount == self.minCount) then
            self.alpha = 255
            playSound("assets/sounds/cd0.wav")
        else
            self.currentCount = self.minCount

            if (self.alpha <= 0) then
                self.isFinished = true
                removeEventHandler("onClientRender", root, self._onClientRender)
                return
            end
        end
    end

    self.alpha = self.alpha - FADE_SPEED * self.animationDelta
    dxDrawImage(START_X, START_Y, COUNTDOWN_WIDTH, COUNTDOWN_HEIGHT, "assets/images/countdown/cd"..self.currentCount..".png", 0, 0, 0, tocolor(255, 255, 255, math.max(0, self.alpha)), false)
end