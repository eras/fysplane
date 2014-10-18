Class = require 'hump/class'
require 'settings'

Player = Class{
    init = function(self, id, name)
        self.id = id
        self.name = name
        self.keys = KEYMAP[self.id]
        self.actions = {
            cw = function(down)
                self.plane:cw(down)
            end,
            ccw = function(down)
                self.plane:ccw(down)
            end,
            shoot = function(down)
                self.plane:shoot(down)
            end
        }

        print(self.name .. ' (' .. self.id .. ') ready for action!')
    end;

    setPlane = function(self, plane)
        self.plane = plane
    end;

    press = function(self, key)
        for action, keycode in pairs(self.keys) do
            if key == keycode then
                print(self.name .. ' pressed ' .. action .. '!')
                if self.actions[action] then
                    self.actions[action](true)
                end
            end
        end
    end;

    release = function(self, key)
        for action, keycode in pairs(self.keys) do
            if key == keycode then
                print(self.name .. ' released ' .. action .. '!')
                if self.actions[action] then
                    self.actions[action](false)
                end
            end
        end
    end;
}
