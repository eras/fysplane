Class = require 'hump.class'
require 'entities/rectangle'
require 'utils'

Ground = Class{
    __includes = Rectangle,

    init = function(self, level)
        local groundImg = love.graphics.newImage('resources/graphics/ground.png')
        Rectangle.init(self,
		       -200, levelHeight(),
		       level, "static",
		       0,
		       levelWidth() + 400, 20, 0, groundImg)
	self.fixture:setRestitution(0)
	self.fixture:setFriction(0.5)
    end;

    update = function(self, dt)
	self.body:setY(levelHeight() - 10)
    end;
}
