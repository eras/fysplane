Class = require 'hump.class'
require 'entities/physicsentity'
require 'entities/animation'
require 'settings'

local BIGBALL_SOUND = love.audio.newSource("resources/audio/boom9.wav", "static")

BigBall = Class{
    __includes = Rectangle,

    MAX_LIFETIME = 60 * 10,
    img = nil,
    frame = 0,

    init = function(self, x, y, level)
        local xsize = 2.0 * PIXELS_PER_METER
        local ysize = 2.0 * PIXELS_PER_METER

        Rectangle.init(self, x, y, level, "dynamic", 1, xsize, ysize, 50, nil)
        self.body:setBullet(true)
        self.collisionCategory = 3
        self.fixture:setCategory(self.collisionCategory)

        BIGBALL_SOUND:rewind()
        BIGBALL_SOUND:play()
    end;

    update = function(self, dt)
        Rectangle.update(self, dt)

        self.frame = self.frame + 1

        if self.frame >= self.MAX_LIFETIME then
            self:delete()
        end
    end;

    draw = function(self)
        love.graphics.setColor({0, 0, 255, 255})
        Rectangle.draw(self)
    end;
}

