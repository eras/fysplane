Class = require 'hump.class'
require 'entities/physicsentity'

-- rad per second
local ROTATION_SPEED = math.pi / 2
local HIT_SOUND = love.audio.newSource("resources/audio/PowerUp.wav", "static")

PowerUp = Class{
    __includes = PhysicsEntity,

    init = function(self, x, y, level, lifetime, radius)
        PhysicsEntity.init(self, x, y, level, "static", 0)
        self.angle = 0
        self.age = 0
        self.lifetime = lifetime

        self.shape = love.physics.newCircleShape(radius)
        self.collisionCategory = 2
        PhysicsEntity.attachShape(self, 1)

        -- Don't collide with ammo
        self.fixture:setMask(3)

        self.mode = nil
    end;

    draw = function(self)
        -- Noop, implement in child
    end;

    wasHitBy = function(self, by)
        HIT_SOUND:rewind()
        HIT_SOUND:play()
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
