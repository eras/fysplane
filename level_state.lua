Gamestate = require 'hump.gamestate'
require 'level'
require 'player'
require 'entities/chaingun'

level_state = {}

local players = {
    [1] = Player(1, 'flux'),
    [2] = Player(2, 'Nicd')
}

local level_music = nil
local current_level = nil

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
end


function level_state:draw()
    current_level:drawEntities()
end


function level_state:update(dt)
    if current_level.reset == true then
        resetLevel()
        return
    end

    current_level:updateEntities(dt)
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
    else
        for id, player in pairs(players) do
            player:press(key)
        end
    end

    local shot = Chaingun(200, 700, current_level)
    shot:setAngle(-45)
    shot:punch(-45, 100000)
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
