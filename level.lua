Class = require 'hump.class'
require 'entities/rectangle'
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
        self.background = love.graphics.newImage('resources/graphics/sky.png')
        self.bgCanvas = love.graphics.newCanvas()
        love.graphics.setCanvas(self.bgCanvas)
        love.graphics.draw(self.background)
        love.graphics.setCanvas()

        self.makePlanes = { [1] = function()
                                return Plane(100, 300, INITIAL_PLANE_SPEED, 0,
					     255, 0, 0, -- red
					     self)
                             end,
                            [2] = function()
                                return Plane(love.window.getWidth() - 100 - 100, 300, -INITIAL_PLANE_SPEED, 0,
					     0, 255, 0, -- green
					     self)
                            end }

        self.planes = { [1] = self.makePlanes[1](),
                        [2] = self.makePlanes[2]() }
        self:insertGround()
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
        love.graphics.setColor(draw_base_color)
        love.graphics.draw(self.bgCanvas)
    end;

    updateEntities = function(self, dt)
        self.world:update(dt)

        for key, entity in pairs(self.entity_list) do
            if entity:isinstance(PhysicsEntity) then
	        local jump_window = 70
		local jump_amount = 50
                while entity.body:getX() > love.window.getWidth() + jump_window do
                    entity.body:setX(entity.body:getX() - love.window.getWidth() - jump_window - jump_amount)
                end
                while entity.body:getX() < -jump_window do
                    entity.body:setX(entity.body:getX() + love.window.getWidth() + jump_window + jump_amount)
                end
            end
            entity:update(dt)
        end
    end;

    insertGround = function(self)
        groundImg = love.graphics.newImage('resources/graphics/ground.png')

	Rectangle((love.window.getWidth() - 1600) / 2, love.window.getHeight(),
		  self, "static",
		  0, 1600, 20, 0, groundImg)
    end;
}
