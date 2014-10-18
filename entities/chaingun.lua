Class = require 'hump.class'
require 'entities/physicsentity'
require 'settings'

CHAINGUN_SOUND = love.audio.newSource("resources/audio/chaingun.mp3", "static")

Chaingun = Class{
    __includes = Rectangle,

    MAX_LIFETIME = 60 * 5,
    img = nil,
    frame = 0,

    init = function(self, x, y, level)
        local xsize = 0.2 * PIXELS_PER_METER
        local ysize = 0.2 * PIXELS_PER_METER

        Rectangle.init(self, x, y, level, "dynamic", 0.2, xsize, ysize, 1000, nil)
        self.body:setBullet(true)

        CHAINGUN_SOUND:rewind()
        CHAINGUN_SOUND:play()
    end;

    update = function(self, dt)
        Rectangle.update(self, dt)

        self.frame = self.frame + 1

        if self.frame >= self.MAX_LIFETIME then
            self:delete()
        end
    end;

    draw = function(self)
        love.graphics.setColor({255, 0, 0, 255})
        Rectangle.draw(self)
    end;
}

