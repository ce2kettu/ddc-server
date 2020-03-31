local countdownInstances = {}

function createCountdown()
    local instance = newClass(Countdown)
    local newIndex = #countdownInstances + 1
    countdownInstances[newIndex] = instance
    return countdownInstances[newIndex]
end

function destroyCountdown(index)
    deleteClass(countdownInstances[index])
end