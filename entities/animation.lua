Class = require 'hump.class'
require 'entities/entity'

Animation = Class{
    __includes = Entity,

    frames = {},

    curFrame = 0,

    init = function(self, x, y, level, basename, numFrames, fps)
        Entity.init(self, x, y, level)

        for frame = 0, numFrames - 1 do
            self.frames[frame] = love.graphics.newImage(string.format(basename, frame))
        end

        self.fps = fps
        self.angle = 0
        self.x = x
        self.y = y
        self.width = self.frames[0]:getWidth();
        self.height = self.frames[0]:getHeight();
        self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.width, self.height)
    end;

    draw = function(self)
        local img = self.frames[math.floor(self.curFrame)]
        if img then
            love.graphics.draw(img, self.quad, self.x, self.y, self.angle, 1, 1, self.width / 2, self.width / 2)
        end
    end;

    update = function(self, dt)
        self.curFrame = self.curFrame + dt * self.fps
    end;
}
