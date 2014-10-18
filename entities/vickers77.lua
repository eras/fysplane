Class = require 'hump.class'
require 'entities/physicsentity'
require 'settings'

local VICKERS_SOUND = love.audio.newSource("resources/audio/vickers77.mp3", "static")

Vickers77 = Class{
    __includes = Rectangle,

    MAX_LIFETIME = 60 * 5,
    img = nil,
    frame = 0,

    init = function(self, x, y, level)
        local xsize = 0.7 * PIXELS_PER_METER
        local ysize = 0.2 * PIXELS_PER_METER

        Rectangle.init(self, x, y, level, "dynamic", 0.2, xsize, ysize, 1000, nil)
        self.body:setBullet(true)

        VICKERS_SOUND:rewind()
        VICKERS_SOUND:play()
    end;

    update = function(self, dt)
        Rectangle.update(self, dt)

        self.frame = self.frame + 1

        if self.frame >= self.MAX_LIFETIME then
            self:delete()
        end
    end;

    draw = function(self)
        Rectangle.draw(self)
    end;
}

