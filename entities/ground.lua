Class = require 'hump.class'
require 'entities/rectangle'

Ground = Class{
    __includes = Rectangle,

    init = function(self, level)
        local groundImg = love.graphics.newImage('resources/graphics/ground.png')
        Rectangle.init(self,
		       (love.window.getWidth() - 1600) / 2, love.window.getHeight(),
		       level, "static",
		       0, 1600, 20, 0, groundImg)
	self.fixture:setRestitution(0)
	self.fixture:setFriction(0.5)
    end;
}
