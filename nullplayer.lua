Class = require 'hump/class'
require 'settings'
require 'entities/entity'

NullPlayer = Class{
    init = function(self, id, name)
        self.id = id
        self.name = name
        self.score = 0
        print('Null player ready for non-action!')
    end;

    -- TODO: move to common base
    setPlane = function(self, plane)
	self.plane = Entity(0, 0, plane.level)
	self.plane.health = 0
	self.plane.motorPower = 0
	plane:delete()
    end;

    -- TODO: move to common base
    getPlane = function(self)
        return self.plane
    end;

    -- TODO: move to common base
    addScore = function(self, score)
    end;

    update = function(self, dt)
    end;

    press = function(self, key)
    end;

    release = function(self, key)
    end;

    joystick = function(self, ...)
    end;
}
