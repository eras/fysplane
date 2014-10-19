Class = require 'hump.class'
require 'entities/entity'
require 'utils'

PhysicsEntity = Class{
    __includes = Entity,

    init = function(self, x, y, level, physics_type, restitution)
        Entity.init(self, x, y, level)
        self.physicsType = physics_type
        self.main_color = main_color
        self.restitution = restitution
        self.deleteLater = false

        self.collisionCategory = 1

        self:initPhysics(self)
    end;

    initPhysics = function(self)
        self.body = love.physics.newBody(self.level.world, self.x, self.y,
                                         self.physicsType)
    end;

    -- This should only be called once the child has created their shapes, maybe
    -- in the child constructor
    -- You can add a density too. I don't know what that means
    attachShape = function(self, density)
        density = density or 1
        self.fixture = love.physics.newFixture(self.body, self.shape, density)
        self.fixture:setRestitution(self.restitution)

        -- Add reference to this object so we can get it in collisions
        self.fixture:setUserData(self)

        -- Set category of this physicsentity to help mask collisions
        self.fixture:setCategory(self.collisionCategory)
    end;

    -- Reimplement
    draw = function(self)
    end;

    -- Only update if physics is not static
    update = function(self, dt)
        if self.deleteLater then
            self:delete()
            return
        end

        if self.physicsType ~= "static" then
            self.x = self.body:getX()
            self.y = self.body:getY()
        end
    end;

    delete = function(self)
        if self.body ~= nil then
            self.body:destroy()
        end

        Entity.delete(self)
    end;

    -- Reimplement
    wasHit = function(self)
    end;


    -- Apply linear impulse with given direction and power
    punch = function(self, angle, power)
        local forces = rad_dist_to_xy(angle, power)
        self.body:applyLinearImpulse(forces[1], forces[2])
    end;
}

