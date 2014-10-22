-- LÖVE configuration values
require 'settings'

function love.conf(t)
    t.window.title = "Fysplane"
    t.window.width = WIDTH
    t.window.height = HEIGHT
    t.window.resizable = false
    t.window.vsync = true

    -- LÖVE version
    t.version = "0.9.1"

    -- Game save directory name
    t.identity = "fysplane"
end