Gamestate = require 'hump.gamestate'
require 'level'
require 'player'
require 'scoreboard'
require 'entities/chaingunpowerup'
require 'entities/plane'
require 'chaingunmode'

level_state = {}

local players = {
    [1] = Player(1, 'flux'),
    [2] = Player(2, 'Nicd')
}

local scoreboards = {}

local level_music = nil
local current_level = nil
local paused = false

local POWERUP_POSSIBILITY = 0.001

function level_state:init()
end

function level_state:enter(previous, level_file)
    entity_id = 1
    if level_music == nil then
        --level_music = love.audio.newSource("resources/audio/freeze.ogg")
        --level_music:setVolume(0.5)
        --level_music:setLooping(true)
        --level_music:play()
    end

    love.graphics.setBackgroundColor({0, 0, 0, 255})
    current_level = Level()
    current_level.world:setCallbacks(begin_contact, end_contact, pre_solve, post_solve)

    players[1]:setPlane(current_level:getPlane(1))
    players[2]:setPlane(current_level:getPlane(2))

    -- Set up scoreboards
    for i = 1, #players, 1 do
        local i0 = i - 1
        local x = 20 + (i0 * SCOREBOARD_WIDTH) + (i0 * SCOREBOARD_MARGIN)

        scoreboards[i] = Scoreboard(x, 20, players[i])
    end

    ChaingunPowerUp(750, 750, current_level)
end


function level_state:draw()
    current_level:drawBackground()

    for i = 1, #scoreboards, 1 do
        scoreboards[i]:draw()
    end

    current_level:drawEntities()
end


function level_state:update(dt)
    if current_level.reset == true then
        resetLevel()
        return
    end

    -- Generate powerups
    local r = love.math.random()

    if r <= POWERUP_POSSIBILITY then
        local x = love.math.random(love.window.getWidth())
        local y = love.math.random(love.window.getHeight())
        ChaingunPowerUp(x, y, current_level)
    end

    if not paused then
        current_level:updateEntities(dt)
    end
end


function level_state:focus(bool)

end


function level_state:leave(bool)
    current_level:delete()
    current_level = nil
end

function level_state:keypressed(key, unicode)
    print('Somebody pressed ' .. key)

    -- Ctrl + R restarts current level.
    if key == "r"
       and (love.keyboard.isDown("lctrl")
       or love.keyboard.isDown("rctrl")) then

        current_level.reset = true
    elseif key == " " then
        paused = not paused
    else
        for id, player in pairs(players) do
            player:press(key)
        end
    end
end


function level_state:keyreleased(key, unicode)
    print('Somebody released ' .. key)

   for id, player in pairs(players) do
        player:release(key)
    end
end


function level_state:mousepressed(x, y, button)

end

function begin_contact(a, b, coll)
    local aObj = a:getUserData()
    local bObj = b:getUserData()

    if aObj ~= nil and bObj ~= nil then
        if aObj:isinstance(Plane) and bObj:isinstance(ChaingunPowerUp) then
            bObj.deleteLater = true
            aObj:setPowerUpMode(ChaingunMode())
        elseif bObj:isinstance(Plane) and aObj:isinstance(ChaingunPowerUp) then
            aObj.deleteLater = true
            bObj:setPowerUpMode(ChaingunMode())
        end
    end
end

function end_contact(a, b, coll)

end

function pre_solve(a, b, coll)

end

function end_solve(a, b, coll)

end

function resetLevel()
    Gamestate.switch(level_state)
end
