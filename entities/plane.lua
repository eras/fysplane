Class = require 'hump.class'
require 'entities/physicsentity'

Plane = Class{
    __includes = PhysicsEntity,

    img = nil,

    init = function(self, x, y, level)
        density = 50
        img = 
        PhysicsEntity.init(self, x, y, level, "dynamic", 0.2)
        self.xsize = 55
        self.ysize = 20
        self.shape = love.physics.newRectangleShape(self.xsize, self.ysize)
        PhysicsEntity.attachShape(self, density)
        self.body:setX(self.x + self.xsize / 2)
        self.body:setY(self.y - self.ysize / 2)
        self.angle = 0

        self.img = love.graphics.newImage("resources/graphics/box-50x50.png");
        self.quad = love.graphics.newQuad(0, 0, self.xsize, self.ysize, self.img:getWidth(), self.img:getHeight())
    end;

    update = function(self)
        PhysicsEntity.update(self, dt)

        self.x, self.y = self.fixture:getBoundingBox()
        self.angle = self.body:getAngle()
    end;

    draw = function(self)
        PhysicsEntity.draw(self)
        if self.img ~= nil then
            love.graphics.draw(self.img, self.quad, self.body:getX(), self.body:getY(), self.angle, 1, 1, self.xsize / 2, self.ysize / 2)
        else
            love.graphics.rectangle("fill", self.x, self.y, self.xsize, self.ysize)
        end
    end;
}

