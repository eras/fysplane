-- Game specific settings go here
-- LÖVE settings should go to conf.lua

dofile("table.lua")

PIXELS_PER_METER = 8

GRAVITY_X = 0
GRAVITY_Y = 9.82599 * PIXELS_PER_METER

INITIAL_WIDTH = 1280
INITIAL_HEIGHT = 768

KEYMAP = {
    [1] = {
        ccw        = { 'k', 'none' },
        cw         = { 'l', 'none' },
        flip       = { ',', 'none' },
        shoot      = { 'o', 'button8' },
        accelerate = { 'j', 'none' },
        decelerate = { 'm', 'button7' }
    },

    [2] = {
        ccw        = { 'a', 'none' },
        cw         = { 's', 'none' },
        flip       = { 'a', 'none' },
        shoot      = { 'w', 'button8' },
        accelerate = { 'x', 'none' },
        decelerate = { 'z', 'button7' }
    }
}

AXISMAP = {
    [1] = {
	rotation  = { { flipped = true,  axis = 3 }, 
		      { flipped = false, axis = 4 } },
	throttle  = { { flipped = false, axis = 1 }, 
		      { flipped = true,  axis = 2 } },
    },
    [2] = {
	rotation  = { { flipped = true,  axis = 3 }, 
		      { flipped = false, axis = 4 } },
	throttle  = { { flipped = false, axis = 1 }, 
		      { flipped = true,  axis = 2 } },
    }
}


function save_settings() 
    table.save({KEYMAP = KEYMAP, AXISMAP = AXISMAP}, "fysplane.cfg")
end

if love.filesystem.isFile("fysplane.cfg") then
    local m = table.load("fysplane.cfg")
    KEYMAP = m.KEYMAP
    AXISMAP = m.AXISMAP
end

function levelWidth()
    local width, height = love.window.getMode()
    return width
end

function levelHeight()
    local width, height = love.window.getMode()
    return height
end

PLANE_HEALTH = 200
PLANE_DEFAULT_GUN = "vickers77"

SCOREBOARD_WIDTH = 250
SCOREBOARD_HEIGHT = 125
SCOREBOARD_MARGIN = 20

ENGINE_MAX = 300

INITIAL_PLANE_SPEED = 400
INITIAL_ENGINE_SPEED = 200

HIT_SCORE = 1
KILL_SCORE = 10
SUICIDE_SCORE = -2
