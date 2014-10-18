Class = require 'hump.class'
require 'entities/physicsentity'
require 'settings'
require 'entities/debug'
VectorLight = require 'hump/vector-light'

Plane = Class{
    __includes = PhysicsEntity,

    img = nil,

    motor_power = 500,

    debugVectors = {},

    turningCw = false,
    turningCcw = false,

    init = function(self, x, y, level)
        local density = 50
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
        debugVectors = {}
        PhysicsEntity.update(self, dt)

        self.x, self.y = self.fixture:getBoundingBox()
        self.angle = self.body:getAngle()

        local dx, dy = VectorLight.rotate(self.angle, self.motor_power * 10.0 * PIXELS_PER_METER, 0)
        self.body:applyForce(dx, dy);
        table.insert(debugVectors, DebugVector(self.body:getX(), self.body:getY(), dx, dy))

        if self.turningCcw then
            dx, dy = VectorLight.rotate(self.angle - math.pi / 2, 1000, 0)
        elseif self.turningCw then
            dx, dy = VectorLight.rotate(self.angle - math.pi / 2, -1000, 0)
        end
        local rdx, rdy = VectorLight.rotate(self.angle, self.xsize / 2, 0)
        self.body:applyForce(dx, dy, self.body:getX() + rdx, self.body:getY() + rdy)
        table.insert(debugVectors, DebugVector(self.body:getX() + rdx, self.body:getY() + rdy, dx, dy))

        -- table.insert(debugVectors, DebugVector(self.x + width / 2, self.y + height / 2, 0, -100))
        -- table.insert(debugVectors, DebugVector(self.x, self.y, -100, 0))
        -- table.insert(debugVectors, DebugVector(self.x + 55, self.y + 10, dx, dy)
    end;

    draw = function(self)
        PhysicsEntity.draw(self)
        love.graphics.draw(self.img, self.quad, self.body:getX(), self.body:getY(), self.angle, 1, 1, self.xsize / 2, self.ysize / 2)
        drawDebugVectors(debugVectors)
    end;
}

