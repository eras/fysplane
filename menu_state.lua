Gamestate = require 'hump.gamestate'
Class = require 'hump.class'

menu_state = {}

local font = love.graphics.newFont(18)

function menu_state:enter()
    love.graphics.setBackgroundColor(0, 0, 0, 0)
end


function menu_state:draw()
    love.graphics.setColor(255,255,255,255)
    love.graphics.setFont(font)
    love.graphics.printf("WASD to move", 50, height-100, width, "left")
    love.graphics.printf("Left mouse button to freeze, right mouse button to speed", width-250, height-100, 200, "right")
end


function menu_state:update(dt)

end


function menu_state:focus(bool)

end


function menu_state:keypressed(key, unicode)

end


function menu_state:keyreleased(key, unicode)

end


function menu_state:mousepressed(x, y, button)

end

function menu_state:mousereleased(x, y, button)

end
