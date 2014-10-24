Gamestate = require 'hump.gamestate'
require 'level_state'
require 'settings'
require 'entities/label'
require 'entities/valuecontroller'
require 'utils'

menu_state = {}

local font = love.graphics.newFont(18)
local midfont = love.graphics.newFont(40)
local titlefont = love.graphics.newFont(72)
local background = love.graphics.newImage('resources/graphics/sky.png')

local menuTime = 0

local currentlyChosen = nil

local bindingName = {
    ccw	       = "Turn CW",
    cw	       = "Turn CCW",
    shoot      = "Shoot",
    accelerate = "Engine power up",
    decelerate = "Engine power down",
    flip       = "Flip"
}

local bindingOrder = { "ccw", "cw", "shoot", "accelerate", "decelerate", "flip" }

function menu_state:enter()
    menu_state.entity_list = {}
    love.graphics.setBackgroundColor(0, 0, 0, 0)
    
    local x = 40
    for player = 1, 2, 1 do
	local y = 300
	Label(string.format("Player %d", player), midfont, { 255, 255, 255, 255 }, "left", 500, 0, x, y, menu_state)
	y = y + 60
	for idx, key in ipairs(bindingOrder) do
	    Label(bindingName[key], font, { 255, 255, 255, 255 }, "left", 190, 25, x, y, menu_state)
	    for bindingIdx, binding in ipairs(KEYMAP[player][key]) do
		local label = Label(binding, font, { 255, 255, 255, 255 }, "left", 50, 25, x + 200 + 20 * (bindingIdx - 1), y, menu_state)
		label:onClick(function()
				  menu_state:adjustBindings(label, bindingIdx, player, key)
			      end)
	    end
	    y = y + 30
	end
	x = x + 400
    end
end

local blinkColor = function(t)
    local seconds, subseconds = math.modf(menuTime)
    return 255 * ((math.sin(math.pow((math.log(subseconds + 1) / math.log(2)), 2) * math.pi * 2) * 0.5 + 0.5));
end

function menu_state:adjustBindings(label, bindingIdx, player, key)
    if currentlyChosen ~= nil then
	currentlyChosen:delete()
    end

    currentlyChosen = ValueController(function ()
					  label.color[4] = blinkColor(); 
				      end, menu_state)
    currentlyChosen.data = { bindingIdx = bindingIdx, player = player, key = key, label = label }
    currentlyChosen.onDelete = function()
	label.color[4] = 255; 
    end
end

function menu_state:draw()
    love.graphics.setColor(128, 128, 128, 255)
    love.graphics.draw(background)

    local seconds, subseconds = math.modf(menuTime)

    love.graphics.setColor(255,255,255,255)
    love.graphics.setFont(titlefont)

    love.graphics.printf("FYSPLANE", 0, 100, love.window.getWidth(), "center")

    love.graphics.printf("PRESS ANY KEY TO BEGIN…", 0, 700, love.window.getWidth(), "center")

    for key, entity in pairs(menu_state.entity_list) do
        entity:draw()
    end

end


function menu_state:update(dt)
    menuTime = menuTime + dt

    if currentlyChosen ~= nil then
	local button = nil
	local joysticks = love.joystick.getJoysticks()
	if #joysticks >= currentlyChosen.data.player then
	    local buttons = getJoystickButtons(joysticks[currentlyChosen.data.player])

	    for i = 1, #buttons, 1 do
		if buttons[i] then
		    button = i
		end
	    end
	end

	if button ~= nil then
	    local key = string.format("button%d", button)
	    KEYMAP[currentlyChosen.data.player][currentlyChosen.data.key][currentlyChosen.data.bindingIdx] = key
	    currentlyChosen.data.label.label = key
	    currentlyChosen:delete()
	    currentlyChosen = nil
	    save_settings()
	end
    end


    for key, entity in pairs(menu_state.entity_list) do
        if entity.update then
	    entity:update(dt)
	end
    end
end


function menu_state:focus(bool)

end


function menu_state:keypressed(key, unicode)
    if currentlyChosen == nil then
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
    elseif key == "escape" then
	currentlyChosen:delete()
	currentlyChosen = nil
    else
	if key == "backspace" then
	    key = "none"
	end
	KEYMAP[currentlyChosen.data.player][currentlyChosen.data.key][currentlyChosen.data.bindingIdx] = key
	currentlyChosen.data.label.label = key
	currentlyChosen:delete()
	currentlyChosen = nil
	save_settings()
    end
end


function menu_state:keyreleased(key, unicode)

end

function menu_state:joystickpressed(key, button)
end


function menu_state:mousepressed(x, y, button)
    for key, entity in pairs(menu_state.entity_list) do
	if entity.mousePressed then
	    entity:mousePressed(x, y, button)
	end
    end
end

function menu_state:mousereleased(x, y, button)

end
