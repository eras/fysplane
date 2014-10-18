Class = require 'hump.class'
require 'entities/rectangle'
require 'settings'

-- A level manages the level datastructure containing static blocks and level
-- specific data like global physics

-- Reset color to this before drawing each object
draw_base_color = {255, 255, 255, 255}

Level = Class{
    init = function(self)
        self.name = 'Default'
        self.entity_list = {}

        self.backgroundColor = {135, 206, 250, 255}

        self.world = love.physics.newWorld(GRAVITY_X, GRAVITY_Y, true)

        Rectangle(100, 100, self, "dynamic", 0.1, 50, 50, 1, love.graphics.newImage("resources/graphics/box-50x50.png"))
        Rectangle(70, 250, self, "static", 0.1, 50, 50, 1, love.graphics.newImage("resources/graphics/box-50x50.png"))
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

    updateEntities = function(self, dt)
        self.world:update(dt)

        for key, entity in pairs(self.entity_list) do
            entity:update(dt)
        end
    end;
}
