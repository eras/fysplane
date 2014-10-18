-- Game specific settings go here
-- LÖVE settings should go to conf.lua

PIXELS_PER_METER = 10

GRAVITY_X = 0
GRAVITY_Y = 9.82599 * PIXELS_PER_METER

KEYMAP = {
    [1] = {
        ccw        = 'k',
        cw         = 'l',
        flip       = 'i',
        shoot      = 'o',
        accelerate   = 'j',
        decelerate = 'm'
    },

    [2] = {
        ccw        = 'a',
        cw         = 's',
        flip       = 'q',
        shoot      = 'w',
        accelerate   = 'x',
        decelerate = 'z'
    }
}
