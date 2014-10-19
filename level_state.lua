Gamestate = require 'hump.gamestate'
require 'level'
require 'player'
require 'computerplayer'
require 'scoreboard'
require 'entities/powerup'
require 'entities/chaingunpowerup'
require 'entities/bigballpowerup'
require 'entities/plane'
require 'entities/debug'
require 'chaingunmode'
require 'entities/plane'
require 'machinegun'

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

local POWERUPS = {
    BigBallPowerUp,
    ChaingunPowerUp
}

function level_state:init()
end

function level_state:enter(previous, level_file)
    entity_id = 1
    if level_music == nil then
        level_music = love.audio.newSource("resources/audio/Beavis II.mp3")
        level_music:setVolume(0.5)
        level_music:setLooping(true)
        level_music:play()
    end

    if self.computer then
        players[2] = ComputerPlayer(2, 'Vengeance')
    else
        players[2] = Player(2, 'Nicd')
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

        scoreboards[i] = Scoreboard(x, 20,
                                    function()
                                        return players[i]
                                    end)
    end
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

        POWERUPS[love.math.random(1, #POWERUPS)](x, y, current_level)
    end

    if not paused then
        current_level:updateEntities(dt)
    end

    players[1]:update(dt)
    players[2]:update(dt)

    if players[1]:getPlane() == nil then
        current_level:respawnPlayer(1)
        players[1]:setPlane(current_level:getPlane(1))
    end
    if players[2]:getPlane() == nil then
        current_level:respawnPlayer(2)
        players[2]:setPlane(current_level:getPlane(2))
    end
end


function level_state:focus(bool)

end


function level_state:leave(bool)
    current_level:delete()
    current_level = nil
end

function level_state:keypressed(key, unicode)
    -- Ctrl + R restarts current level.
    if key == "r"
       and (love.keyboard.isDown("lctrl")
       or love.keyboard.isDown("rctrl")) then

        current_level.reset = true
    elseif key == "d"
       and (love.keyboard.isDown("lctrl")
       or love.keyboard.isDown("rctrl")) then

        debugEnabled = not debugEnabled
    elseif key == " " then
        paused = not paused
    else
        for id, player in pairs(players) do
            player:press(key)
        end
    end
end


function level_state:keyreleased(key, unicode)
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
        if aObj:isinstance(Plane) and bObj:isinstance(PowerUp) then
            bObj.deleteLater = true
            aObj:setPowerUpMode(bObj.mode)
            coll:setEnabled(false)
        elseif bObj:isinstance(Plane) and aObj:isinstance(PowerUp) then
            aObj.deleteLater = true
            bObj:setPowerUpMode(bObj.mode)
            coll:setEnabled(false)
        else
            aObj:wasHit()
            bObj:wasHit()

            local plane = nil
            local other = nil
            if aObj:isinstance(Plane) then
                plane = aObj
                other = bObj
            elseif bObj:isinstance(Plane) then
                plane = bObj
                other = aObj
            end

            if other and other:isinstance(Plane) then
                -- nothing
            elseif plane then
                if other:getOwner() == nil then
                    -- Collision with ground or other plane
                    plane:receiveDamage(1000)
                    plane:getOwner():addScore(SUICIDE_SCORE)
                elseif other:getOwner().id ~= plane.id then
                    for key, gun in pairs(GUNS) do
                        if other:isinstance(gun['projectile']) and plane.health > 0 then
                            plane:receiveDamage(gun['damage'])

                            local shooter = other:getOwner():getOwner()
                            shooter:addScore(HIT_SCORE)
                            if plane.health == 0 then
                                shooter:addScore(KILL_SCORE)
                            end
                        end
                    end
                end
            end
        end
    end
end

function end_contact(a, b, coll)

end

function pre_solve(a, b, coll)
    if aObj ~= nil and bObj ~= nil then
        if aObj:isinstance(Plane) and bObj:isinstance(PowerUp) then
            bObj.deleteLater = true
            aObj:setPowerUpMode(bObj.mode)
            coll:setEnabled(false)
        elseif bObj:isinstance(Plane) and aObj:isinstance(PowerUp) then
            aObj.deleteLater = true
            bObj:setPowerUpMode(bObj.mode)
            coll:setEnabled(false)
        end
    end
end

function end_solve(a, b, coll)

end

function resetLevel()
    Gamestate.switch(level_state)
end
