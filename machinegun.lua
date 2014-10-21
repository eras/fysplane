-- A generic machine gun which shoots all kinds of projectiles
Class = require 'hump/class'

require 'entities/vickers77'
require 'entities/tinyshot'
require 'entities/bigball'

GUNS = {
    chaingun = {
        interval = 0.01,
        projectile = TinyShot,
	speed = 50000,
        damage = 5
    },

    bigball = {
        interval = 0.2,
        projectile = BigBall,
	speed = 2000,
        damage = 0
    },

    vickers77 = {
        interval = 0.1,
        projectile = Vickers77,
	speed = 10000,
        damage = 25
    }
}

MachineGun = Class{
    init = function(self, plane, type)
        self:setType(type)

        -- Plane this gun is attached to
        self.plane = plane

        self.shooting = false
    end;

    update = function(self, dt)
        if self.shooting and self.since_last_shot >= self.gun['interval'] then
            self:fire()
            self.since_last_shot = 0
        else
            self.since_last_shot = self.since_last_shot + dt
        end
    end;

    setType = function(self, type)
        self.gun = GUNS[type]
        self.since_last_shot = 0
    end;

    fire = function(self)
        local gunPos = self.plane:getGunPosition()
        local level = self.plane.level

        local shot = self.gun['projectile'](gunPos[1], gunPos[2], level)
        shot:setOwner(self.plane);
        local angle = self.plane.body:getAngle()
        shot.body:setAngle(angle)

        local speeds = rad_dist_to_xy(angle, self.gun['speed'])
        shot.body:setLinearVelocity(speeds[1], speeds[2])
    end;

    startShooting = function(self)
        self.shooting = true
    end;

    stopShooting = function(self)
        self.shooting = false
        self.since_last_shot = 0
    end;
}
