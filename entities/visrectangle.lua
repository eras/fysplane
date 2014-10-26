Class = require 'hump.class'
require 'entities/physicsentity'

-- Rectangle for visualization purposes
VisRectangle = Class{
    __includes = Entity,

    img = nil,

    init = function(self, color, xsize, ysize, img, ...)
	Entity.init(self, ...)
        self.xsize = xsize
        self.ysize = ysize
        self.angle = 0
	self.color = color

        if img ~= nil then
            self.img = img
            self.quad = love.graphics.newQuad(0, 0, self.xsize, self.ysize, self.img:getWidth(), self.img:getHeight())
        end
    end;

    update = function(self, dt)
        Entity.update(self, dt)
    end;

    draw = function(self)
	love.graphics.setColor(self.color)
        if self.img ~= nil then
            love.graphics.draw(self.img, self.quad, self.x, self.y, self.angle, 1, 1, self.xsize / 2, self.ysize / 2)
        else
            love.graphics.push()
            love.graphics.translate(self.x, self.y)
            love.graphics.rotate(self.angle)
            love.graphics.rectangle("fill", -self.xsize / 2, -self.ysize / 2, self.xsize, self.ysize)
            love.graphics.pop()
        end
    end;

    setAngle = function(self, angle)
        self.body:setAngle(deg_to_rad(angle))
    end;
}

