Class = require 'hump.class'
require 'entities/entity'

FixedEntity = Class{
    __includes = Entity,

    init = function(self, x, y, level)
        Entity.init(self, x, y, level)
    end;

    draw = function(self)
        -- Noop, implement in child
    end;

    update = function(self, dt)
        -- Noop, implement in child
    end;
}
