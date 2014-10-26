-- LÖVE configuration values
require 'settings'

function love.conf(t)
    t.window.title = "Fysplane"
    t.window.width = INITIAL_WIDTH
    t.window.height = INITIAL_HEIGHT
    t.window.resizable = true
    t.window.vsync = true

    -- LÖVE version
    t.version = "0.9.1"

    -- Game save directory name
    t.identity = "fysplane"
end