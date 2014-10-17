Gamestate = require 'hump.gamestate'
require 'menu_state'

-- Initialize game global variables and switch to menu state

function love.load()

    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    love.mouse.setVisible(true)
    love.physics.setMeter(30)

    Gamestate.registerEvents()
    Gamestate.switch(menu_state)
end

function love.quit()

end
