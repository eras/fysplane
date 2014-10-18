Class = require 'hump.class'
require 'entities/physicsentity'

Rectangle = Class{
    __includes = PhysicsEntity,

    img = nil,

    init = function(self, x, y, level, physics_type, restitution, xsize, ysize, density, img)
        PhysicsEntity.init(self, x, y, level, physics_type, restitution)
        self.xsize = xsize
        self.ysize = ysize
        self.shape = love.physics.newRectangleShape(self.xsize, self.ysize)
        PhysicsEntity.attachShape(self, density)
        self.body:setX(self.x + self.xsize / 2)
        self.body:setY(self.y - self.ysize / 2)
        self.angle = 0


        if img ~= nil then
            self.img = img
            self.quad = love.graphics.newQuad(0, 0, self.xsize, self.ysize, self.img:getWidth(), self.img:getHeight())
        end
    end;

    update = function(self, dt)
        PhysicsEntity.update(self, dt)

        self.x, self.y = self.fixture:getBoundingBox()
        self.angle = self.body:getAngle()
    end;

    draw = function(self)
        if self.img ~= nil then
            love.graphics.draw(self.img, self.quad, self.body:getX(), self.body:getY(), self.angle, 1, 1, self.xsize / 2, self.ysize / 2)
        else
            love.graphics.push()
            love.graphics.translate(self.body:getX(), self.body:getY())
            love.graphics.rotate(self.angle)
            love.graphics.rectangle("fill", -self.xsize / 2, -self.ysize / 2, self.xsize, self.ysize)
            love.graphics.pop()
        end
    end;

    setAngle = function(self, angle)
        self.body:setAngle(deg_to_rad(angle))
    end;
}

