Class = require 'hump.class'
require 'entities/entity'

Label = Class {
    __include = Entity,
    
    init = function(self, label, font, color, align, xsize, ysize, ...)
	Entity.init(self, ...)
	self.label = label
	self.color = color
	self.font = font
	self.align = align
	self.xsize = xsize
	self.ysize = ysize
	self.onClickFunction = function() end
    end;

    onClick = function(self, fn)
	self.onClickFunction = fn
	return self
    end;

    draw = function(self)
	love.graphics.push()
	love.graphics.setColor(self.color)
	love.graphics.translate(self.x, self.y)
	love.graphics.setFont(self.font)
	local label = self.label
	if type(label) == "function" then
	    label = label()
	end
	love.graphics.printf(label, 0, 0, self.xsize, self.align)
	--love.graphics.rectangle("fill", 0, 0, self.xsize, self.ysize)
	love.graphics.pop()
    end;

    mousePressed = function(self, x, y, button)
	if x >= self.x and y >= self.y and x <= self.x + self.xsize and y <= self.y + self.ysize then
	    self.onClickFunction(button)
	end
    end;
}
