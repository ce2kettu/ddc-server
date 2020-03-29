local countdownInstances = {}

function createCountdown()
    local instance = new(Countdown)
    local newIndex = #countdownInstances + 1
    countdownInstances[newIndex] = instance
    return countdownInstances[newIndex]
end

function destroyCountdown(index)
    delete(countdownInstances[index])
end