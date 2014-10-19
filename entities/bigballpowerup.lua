Class = require 'hump.class'
require 'entities/powerup'
require 'bigballmode'

local BIGBALLPOWERUP_IMG = love.graphics.newImage("resources/graphics/bigballpowerup.png")
local BIGBALLPOWERUP_QUAD = love.graphics.newQuad(0, 0, 32, 32, 32, 32)

BigBallPowerUp = Class{
    __includes = PowerUp,

    init = function(self, x, y, level)
        PowerUp.init(self, x, y, level, 10, 16)
        self.mode = BigBallMode()
    end;

    draw = function(self)
        love.graphics.draw(BIGBALLPOWERUP_IMG, BIGBALLPOWERUP_QUAD, self.x, self.y, self.angle, 1, 1, 16, 16)
    end;
}
