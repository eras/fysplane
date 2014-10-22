Gamestate = require 'hump.gamestate'
require 'level_state'
require 'settings'

menu_state = {}

local font = love.graphics.newFont(18)
local titlefont = love.graphics.newFont(72)
local background = love.graphics.newImage('resources/graphics/sky.png')

function menu_state:enter()
    love.graphics.setBackgroundColor(0, 0, 0, 0)
end


function menu_state:draw()
    love.graphics.setColor(128, 128, 128, 255)
    love.graphics.draw(background)

    love.graphics.setColor(255,255,255,255)
    love.graphics.setFont(titlefont)

    love.graphics.printf("FYSPLANE", 0, 100, love.window.getWidth(), "center")

    love.graphics.setFont(font)
    love.graphics.printf("PLAYER 1\
\
Turn CW: " .. KEYMAP[1]['cw'] .. "\
Turn CCW: " .. KEYMAP[1]['ccw'] .. "\
Shoot: " .. KEYMAP[1]['shoot'] .. "\
Engine power up: " .. KEYMAP[1]['accelerate'] .. "\
Engine power down: " .. KEYMAP[1]['decelerate'] .. "\
", 40, 400, 400, "left")

    love.graphics.printf("PLAYER 2\
\
Turn CW: " .. KEYMAP[2]['cw'] .. "\
Turn CCW: " .. KEYMAP[2]['ccw'] .. "\
Shoot: " .. KEYMAP[2]['shoot'] .. "\
Engine power up: " .. KEYMAP[2]['accelerate'] .. "\
Engine power down: " .. KEYMAP[2]['decelerate'] .. "\
", love.window.getWidth() - 40 - 400, 400, 400, "left")

    love.graphics.printf("PRESS ANY KEY TO BEGIN…", 0, 700, love.window.getWidth(), "center")
end


function menu_state:update(dt)

end


function menu_state:focus(bool)

end


function menu_state:keypressed(key, unicode)
    if key == "1" then
        level_state.mode = "solo"
        Gamestate.switch(level_state)
    elseif key == "c" then
        level_state.mode = "computer"
        Gamestate.switch(level_state)
    elseif key == "escape" then
	love.event.quit()
    else
        level_state.computer = "2player"
        Gamestate.switch(level_state)
    end
end


function menu_state:keyreleased(key, unicode)

end


function menu_state:mousepressed(x, y, button)

end

function menu_state:mousereleased(x, y, button)

end
