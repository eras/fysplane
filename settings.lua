-- Game specific settings go here
-- LÖVE settings should go to conf.lua

dofile("table.lua")

PIXELS_PER_METER = 8

GRAVITY_X = 0
GRAVITY_Y = 9.82599 * PIXELS_PER_METER

WIDTH = 1280
HEIGHT = 768

KEYMAP = {
    [1] = {
        ccw        = { 'k' },
        cw         = { 'l' },
        flip       = { ',' },
        shoot      = { 'o' },
        accelerate = { 'j' },
        decelerate = { 'm' }
    },

    [2] = {
        ccw        = { 'a' },
        cw         = { 's' },
        flip       = { 'a' },
        shoot      = { 'w' },
        accelerate = { 'x' },
        decelerate = { 'z' }
    }
}

function save_settings() 
    table.save({KEYMAP = KEYMAP}, "fysplane.cfg")
end

if love.filesystem.isFile("fysplane.cfg") then
    local m = table.load("fysplane.cfg")
    KEYMAP = m.KEYMAP
end

PLANE_HEALTH = 500
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
