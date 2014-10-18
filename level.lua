Class = require 'hump.class'
require 'entities/rectangle'
require 'entities/plane'
require 'settings'

-- A level manages the level datastructure containing static blocks and level
-- specific data like global physics

-- Reset color to this before drawing each object
draw_base_color = {255, 255, 255, 255}

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

        Plane(100, 100, self)
        Rectangle(70, 250, self, "static", 0.1, 50, 50, 1, love.graphics.newImage("resources/graphics/box-50x50.png"))
        self:insertGround()
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
        love.graphics.draw(self.bgCanvas)

        for key, entity in pairs(self.entity_list) do
            love.graphics.setColor(draw_base_color)
            entity:draw()
        end
        love.graphics.setColor(draw_base_color)
    end;

    updateEntities = function(self, dt)
        self.world:update(dt)

        for key, entity in pairs(self.entity_list) do
            entity:update(dt)
        end
    end;

    insertGround = function(self)
        groundImg = love.graphics.newImage('tiles/grasstop.png')

        for i = 0, love.window.getWidth() / 16 + 1, 1 do
            Rectangle(i * 16, love.window.getHeight(), self, "static", 0, 16, 16, 0, groundImg)
        end
    end;
}
