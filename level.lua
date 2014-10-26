Class = require 'hump.class'
require 'entities/rectangle'
require 'entities/ground'
require 'entities/plane'
require 'entities/physicsentity'
require 'settings'

-- A level manages the level datastructure containing static blocks and level
-- specific data like global physics

-- Reset color to this before drawing each object
local draw_base_color = {255, 255, 255, 255}

Level = Class{
    init = function(self)
        self.name = 'Default'
        self.entity_list = {}

        self.world = love.physics.newWorld(GRAVITY_X, GRAVITY_Y, true)

        -- Draw background  to canvas so we don't redraw it every time
	self.oldWidth, self.oldHeight = 0, 0
	self:updateBackground()

        self.makePlanes = { [1] = function()
                                return Plane(100, 400, INITIAL_PLANE_SPEED, 0,
					     255, 0, 0, -- red
					     self)
                             end,
                            [2] = function()
                                return Plane(levelWidth() - 100 - 100, 300, -INITIAL_PLANE_SPEED, 0,
					     0, 255, 0, -- green
					     self)
                            end }

        self.planes = { [1] = self.makePlanes[1](),
                        [2] = self.makePlanes[2]() }

	Ground(self);
    end;

    updateBackground = function(self)
	local w, h = levelWidth(), levelHeight()
	if w ~= self.oldWidth or h ~= self.oldHeight then
	    local background = love.graphics.newImage('resources/graphics/sky.png')
	    self.bgCanvas = love.graphics.newCanvas()
	    love.graphics.setCanvas(self.bgCanvas)
	    love.graphics.setColor(255, 255, 255, 255)
	    love.graphics.draw(background, 0, 0, 0,
			       levelWidth() / background:getWidth(),
			       levelHeight() / background:getHeight())
	    love.graphics.setCanvas()
	    
	    self.oldWidth, self.oldHeight = w, h
	end
    end;

    respawnPlayer = function(self, playerIdx)
        self.planes[playerIdx] = self.makePlanes[playerIdx]()
    end;

    getPlane = function(self, playerIdx)
        return self.planes[playerIdx]
    end;

    delete = function(self)
        for key, entity in pairs(self.entity_list) do
            entity:delete()
        end
        self.entity_list = nil
    end;

    activate = function(self)

    end;

    drawEntities = function(self)
        for key, entity in pairs(self.entity_list) do
            love.graphics.setColor(draw_base_color)
            entity:draw()
        end
        love.graphics.setColor(draw_base_color)
    end;

    drawBackground = function(self)
	self:updateBackground()
        love.graphics.setColor(draw_base_color)
        love.graphics.draw(self.bgCanvas)
    end;

    updateEntities = function(self, dt)
        self.world:update(dt)

        for key, entity in pairs(self.entity_list) do
            if entity:isinstance(PhysicsEntity) then
	        local jump_window = 70
		local jump_amount = 50
                while entity.body:getX() > levelWidth() + jump_window do
                    entity.body:setX(entity.body:getX() - levelWidth() - jump_window - jump_amount)
                end
                while entity.body:getX() < -jump_window do
                    entity.body:setX(entity.body:getX() + levelWidth() + jump_window + jump_amount)
                end
            end
            entity:update(dt)
        end
    end;
}
