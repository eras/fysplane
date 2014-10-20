Class = require 'hump.class'
require 'entities/entity'

local ARROW_IMG = love.graphics.newImage("resources/graphics/arrow-up.png")
local ARROW_QUAD = love.graphics.newQuad(0, 0, 90, 90, 90, 90)

Arrow = Class {
    __includes = Entity,
    
    init = function(self, x, y, level, r, g, b)
	Entity.init(self, x, y, level)
	self.pointX = 45
	self.pointY = 90
	self.r = r
	self.g = g
	self.b = b
    end;

    setX = function(self, x)
	self.x = x
    end;

    setY = function(self, y)
	self.y = y
    end;

    draw = function(self)
	love.graphics.setColor(self.r, self.g, self.b);
        love.graphics.draw(ARROW_IMG, ARROW_QUAD, self.x + self.pointX, self.y + self.pointY, 0, 1, 1, 90, 90)
    end
}
