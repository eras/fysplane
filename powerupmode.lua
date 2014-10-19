Class = require 'hump/class'
require 'settings'

PowerUpMode = Class{
    init = function(self, duration)
        self.age = 0
        self.duration = duration
        self.plane = nil
        self.active = false
    end;

    update = function(self, dt)
        if active then
            self.age = self.age + dt
        end

        if self.age >= self.duration then
            self:deactivate()
        end
    end;

    draw = function(self, x, y)
        local age = self.age / self.duration
        local start_color = {0, 255, 0}
        local end_color = {255, 0, 0}
        love.graphics.setColor(colorSlide(start_color, end_color, age_ratio))
        love.graphics.rectangle("fill", self.x, self.y + 60, 50, 5)
    end;

    activate = function(self, plane)
        plane.powerupmode = self
        self.plane = plane
        self.active = true
    end;

    deactivate = function(self)
        self.plane.powerupmode = nil
    end;
}