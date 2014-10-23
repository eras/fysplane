Class = require 'hump.class'

-- Entity is the basic building block of all objects in fysplane. All other
-- objects in game that are not part of the background derive from this class.

entity_id = 1

Entity = Class{
    init = function(self, x, y, level)
        self.x = x
        self.y = y
        self.level = level
        self.owner = nil

        self.id = entity_id
        entity_id = entity_id + 1

        self.level.entity_list[self.id] = self
    end;

    setOwner = function(self, owner)
        self.owner = owner
    end;

    getOwner = function(self)
        return self.owner
    end;

    draw = function(self)
    end;

    update = function(self, dt)
    end;

    delete = function(self)
        self.level.entity_list[self.id] = nil
    end;
}
