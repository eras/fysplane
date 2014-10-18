-- LÖVE configuration values

function love.conf(t)
    -- Disable unneeded modules
    t.modules.joystick = false

    t.window.title = "Fysplane"
    t.window.width = 1024
    t.window.height = 768
    t.window.resizable = false

    -- LÖVE version
    t.version = "0.9.1"

    -- Game save directory name
    t.identity = "fysplane"
end