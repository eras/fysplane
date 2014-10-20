Class = require 'hump.class'
require 'entities/physicsentity'
require 'entities/animation'
require 'settings'

local TINYSHOT_SOUND = love.audio.newSource("resources/audio/chaingun.mp3", "static")
local explosionFrames = AnimationFrames("resources/graphics/miniexplosion-%04d.png", 4, 15, false)

TinyShot = Class{
    __includes = Rectangle,

    MAX_LIFETIME = 60 * 5,
    img = nil,
    frame = 0,

    init = function(self, x, y, level)
        local xsize = 0.3 * PIXELS_PER_METER
        local ysize = 0.3 * PIXELS_PER_METER

        Rectangle.init(self, x, y, level, "dynamic", 0.2, xsize, ysize, 1, nil)
        self.body:setBullet(true)
        self.collisionCategory = 3
        self.fixture:setCategory(self.collisionCategory)

        TINYSHOT_SOUND:rewind()
        TINYSHOT_SOUND:play()
    end;

    update = function(self, dt)
        Rectangle.update(self, dt)

        self.frame = self.frame + 1

        if self.frame >= self.MAX_LIFETIME then
            self:delete()
        end
    end;

    wasHitBy = function(self, by)
        Animation(self.body:getX(), self.body:getY(), self.level, explosionFrames)
    end;

    draw = function(self)
        love.graphics.setColor({255, 0, 0, 255})
	local ratio = 1.0 / 2400 * PIXELS_PER_METER
	local velX, velY = self.body:getLinearVelocity()
	love.graphics.line(self.body:getX(), self.body:getY(),
			   self.body:getX() + velX * ratio, self.body:getY() + velY * ratio)
    end;
}

