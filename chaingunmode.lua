Class = require 'hump/class'
require 'powerupmode'
require 'settings'

ChaingunMode = Class{
    __include = PowerUpMode,

    init = function(self)
        PowerUpMode.init(self, 10)
    end;

    update = function(self, dt)
        PowerUpMode.update(self, dt)
    end;

    activate = function(self, plane)
        PowerUpMode.activate(self, plane)
        plane.machinegun:setType("chaingun")
    end;

    deactivate = function(self)
        PowerUpMode.deactivate(self)
        self.plane.machinegun:setType("vickers77")
    end;
}