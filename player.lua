Class = require 'hump/class'
require 'settings'

Player = Class{
    init = function(self, id, name)
        self.id = id
        self.name = name
        self.keys = KEYMAP[self.id]

        print(self.name .. ' (' .. self.id .. ') ready for action!')
    end;

    setPlane = function(self, plane)
        self.plane = plane
    end;

    press = function(self, key)
        for action, keycode in pairs(self.keys) do
            if key == keycode then
                print(self.name .. ' pressed ' .. action .. '!')
            end
        end
    end;

    release = function(self, key)
        for action, keycode in pairs(self.keys) do
            if key == keycode then
                print(self.name .. ' released ' .. action .. '!')
            end
        end
    end;
}