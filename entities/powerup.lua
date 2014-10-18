Class = require 'hump.class'
require 'entities/physicsentity'

-- rad per second
local ROTATION_SPEED = math.pi / 2

PowerUp = Class{
    __includes = PhysicsEntity,

    init = function(self, x, y, level, lifetime, radius)
        PhysicsEntity.init(self, x, y, level, "static", 0)
        self.angle = 0
        self.age = 0
        self.lifetime = lifetime

        self.shape = love.physics.newCircleShape(radius)
        PhysicsEntity.attachShape(self, 1)
    end;

    draw = function(self)
        -- Noop, implement in child
    end;

    update = function(self, dt)
        PhysicsEntity.update(self, dt)
        
        self.angle = self.angle + ROTATION_SPEED * dt

        if self.angle > math.pi * 2 then
            self.angle = self.angle - math.pi * 2
        end

        self.age = self.age + dt
        if self.age > self.lifetime then
            self:delete()
        end
    end;
}
