Class = require 'hump.class'
require 'entities/physicsentity'
require 'settings'

local VICKERS_SOUND = love.audio.newSource("resources/audio/vickers77.mp3", "static")
local explosionFrames = AnimationFrames("resources/graphics/miniexplosion-%04d.png", 4, 15)

Vickers77 = Class{
    __includes = Rectangle,

    MAX_LIFETIME = 60 * 5,
    img = nil,
    frame = 0,

    init = function(self, x, y, level)
        local xsize = 1 * PIXELS_PER_METER
        local ysize = 0.4 * PIXELS_PER_METER

        self.collisionCategory = 3
        Rectangle.init(self, x, y, level, "dynamic", 0.2, xsize, ysize, 1, nil)
        self.body:setBullet(true)
        self.collisionCategory = 3
        self.fixture:setCategory(self.collisionCategory)

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

    wasHit = function(self)
        Animation(self.body:getX(), self.body:getY(), self.level, explosionFrames)
    end;

    draw = function(self)
        Rectangle.draw(self)
    end;
}

