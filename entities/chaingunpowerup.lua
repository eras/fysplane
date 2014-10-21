Class = require 'hump.class'
require 'entities/powerup'
require 'chaingunmode'

local CHAINGUNPOWERUP_IMG = love.graphics.newImage("resources/graphics/chaingunpowerup.png")
local CHAINGUNPOWERUP_QUAD = love.graphics.newQuad(0, 0, 32, 32, 32, 32)

ChaingunPowerUp = Class{
    __includes = PowerUp,

    init = function(self, x, y, level)
        PowerUp.init(self, x, y, level, 20, 16)
        self.mode = ChaingunMode()
    end;

    draw = function(self)
        love.graphics.draw(CHAINGUNPOWERUP_IMG, CHAINGUNPOWERUP_QUAD, self.x, self.y, self.angle, 1, 1, 16, 16)
    end;
}
