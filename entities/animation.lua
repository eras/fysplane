Class = require 'hump.class'
require 'entities/entity'

Animation = Class{
    __includes = Entity,

    frames = {},

    curFrame = 0

    init = function(self, x, y, level, basename, numFrames, fps)
        Entity.init(self, x, y, level)

        for frame = 0,numFrames - 1 do
            self.frames[frame] = love.graphics.newImage(string.format(basename, frame))
        end

        self.angle = 0
        self.width = self.frames[0].getWidth();
        self.height = self.frames[0].getHeight();
        self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.width, self.height)
    end;

    draw = function(self)
        if self.health > 0 then
            local img = self.frames[math.floor(curFrame)]
            if img then
                love.graphics.draw(self.frames[0], self.quad, 0, 0, self.angle, 1, 1, self.width / 2, self.width / 2)
            end
        end
    end;

    update = function(self, dt)
        curFrame += dt * fps
    end;
}
