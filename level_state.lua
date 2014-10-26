Gamestate = require 'hump.gamestate'
require 'level'
require 'player'
require 'computerplayer'
require 'nullplayer'
require 'scoreboard'
require 'entities/powerup'
require 'entities/chaingunpowerup'
require 'entities/bigballpowerup'
require 'entities/plane'
require 'entities/debug'
require 'chaingunmode'
require 'entities/plane'
require 'machinegun'
require 'utils'

level_state = {}

local players = {
    [1] = Player(1, 'flux'),
    [2] = Player(2, 'Nicd')
}

local lastJoystickButtons = { nil, nil }

local scoreboards = {}

local level_music = nil
local current_level = nil
local paused = false
local level_time = 0.0
local updated_time = 0.0

local PHYSICS_STEP = 0.001
local POWERUP_POSSIBILITY = 0.1

local POWERUPS = {
    BigBallPowerUp,
    ChaingunPowerUp
}

local joysticks = {}

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

    if self.mode == "solo" then
        players[2] = NullPlayer(2, "Null")
    elseif self.mode == "computer" then
        players[2] = ComputerPlayer(2, 'Vengeance')
    else
        players[2] = Player(2, 'Nicd')
    end

    level_time = 0.0
    updated_time = 0.0

    for i, joystick in ipairs(love.joystick.getJoysticks()) do
	joysticks[i] = joystick
    end

    love.graphics.setBackgroundColor({0, 0, 0, 255})
    current_level = Level()
    current_level.world:setCallbacks(begin_contact, end_contact, pre_solve, post_solve)

    players[1]:setPlane(current_level:getPlane(1))
    if players[2] then
	players[2]:setPlane(current_level:getPlane(2))
    end

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

    level_time = level_time + dt

    for player = 1, #players, 1 do
	local j = joysticks[player]
	if j then
	    local buttons = getJoystickButtons(j)
	    if lastJoystickButtons[player] ~= nil then
		for i = 1, #buttons, 1 do
		    if buttons[i] ~= lastJoystickButtons[player][i] then
			local key = string.format("button%d", i)
			if buttons[i] then
			    players[player]:press(key)
			else
			    players[player]:release(key)
			end
		    end
		end
	    end
	    lastJoystickButtons[player] = buttons

	    local getAxis = function(info)
		local value = 0
		if j:getAxisCount() >= info.axis then
		    value = j:getAxis(info.axis)
		    if info.flipped then
			value = -value
		    end
		end
		return value
	    end
	    
	    players[player]:joystick(getRotation(j, player), getThrottle(j, player))
	end
    end
    
    dt = PHYSICS_STEP
    while updated_time < level_time do
	updated_time = updated_time + dt

	-- Generate powerups
	local r = love.math.random()

	if r <= POWERUP_POSSIBILITY * dt then
	    local x = love.math.random(levelWidth())
	    local y = love.math.random(levelHeight())

	    POWERUPS[love.math.random(1, #POWERUPS)](x, y, current_level)
	end

	if not paused then
	    current_level:updateEntities(dt)
	end

	players[1]:update(dt)
	players[2]:update(dt)
    end

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
    elseif key == "escape" then
        Gamestate.switch(menu_state)
    elseif key == "d"
       and (love.keyboard.isDown("lctrl")
       or love.keyboard.isDown("rctrl")) then

        debugEnabled = not debugEnabled
    else
	local found = false
        for id, player in pairs(players) do
            found = player:press(key) or found
        end
	if not found and (key == " " or key == "p") then
	    paused = not paused
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
	    bObj:wasHitBy()
            bObj.deleteLater = true
            aObj:setPowerUpMode(bObj.mode)
            coll:setEnabled(false)
        elseif bObj:isinstance(Plane) and aObj:isinstance(PowerUp) then
	    aObj:wasHitBy()
            aObj.deleteLater = true
            bObj:setPowerUpMode(bObj.mode)
            coll:setEnabled(false)
        else
            aObj:wasHitBy(bObj)
            bObj:wasHitBy(aObj)

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
    local aObj = a:getUserData()
    local bObj = b:getUserData()

    if aObj ~= nil and bObj ~= nil then
	aObj:noLongerHitBy(bObj)
	bObj:noLongerHitBy(aObj)
    end
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
