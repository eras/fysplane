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
            end,
            accelerate = function(down)
                self.plane:accelerate(down)
            end,
            decelerate = function(down)
                self.plane:decelerate(down)
            end,
            flip = function(down)
                self.plane:flip(down)
            end
        }

        self.score = 0

        print(self.name .. ' (' .. self.id .. ') ready for action!')
    end;

    setPlane = function(self, plane)
        self.plane = plane
        if plane ~= nil then
            plane:setOwner(self)
            self.health = 1000
        end
    end;

    getPlane = function(self)
        return self.plane
    end;

    addScore = function(self, score)
        self.score = self.score + score
    end;

    update = function(self, dt)
    end;

    press = function(self, key)
        for action, keycode in pairs(self.keys) do
            if key == keycode then
                if self.actions[action] and self.plane then
                    self.actions[action](true)
                end
            end
        end
    end;

    release = function(self, key)
        for action, keycode in pairs(self.keys) do
            if key == keycode then
                if self.actions[action] and self.plane then
                    self.actions[action](false)
                end
            end
        end
    end;

    joystick = function(self, ...)
	self.plane:analog(...)
    end
}
