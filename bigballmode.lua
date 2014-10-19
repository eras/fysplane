Class = require 'hump/class'
require 'powerupmode'
require 'settings'

BigBallMode = Class{
    __include = PowerUpMode,

    init = function(self)
        PowerUpMode.init(self, 10)
    end;

    update = function(self, dt)
        PowerUpMode.update(self, dt)
    end;

    draw = function(self, x, y)
        PowerUpMode.draw(self, x, y)
    end;

    activate = function(self, plane)
        PowerUpMode.activate(self, plane)
        plane.machinegun:setType("bigball")
    end;

    deactivate = function(self)
        PowerUpMode.deactivate(self)
    end;
}