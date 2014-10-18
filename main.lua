Gamestate = require 'hump.gamestate'
require 'menu_state'
require 'level_state'
require 'settings'

-- Initialize game global variables and switch to menu state

function love.load()

    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    love.mouse.setVisible(true)
    love.physics.setMeter(PIXELS_PER_METER)

    Gamestate.registerEvents()
    Gamestate.switch(level_state)
end

function love.quit()

end
