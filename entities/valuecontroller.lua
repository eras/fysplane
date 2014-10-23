Class = require 'hump.class'
require 'entities/entity'

ValueController = Class {
    __include = Entity,
    
    init = function(self, fn, level)
	Entity.init(self, 0, 0, level)
	self.fn = fn
	self.onDelete = function() end
	self.t = 0
    end;

    update = function(self, dt)
	self.t = self.t + dt
	self.fn(self.t)
    end;

    draw = function(...)
	Entity.draw(...)
    end;

    delete = function(self, ...)
	self.onDelete()
	Entity.delete(self, ...)
    end;
}
