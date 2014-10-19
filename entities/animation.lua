Class = require 'hump.class'
require 'entities/entity'

AnimationFrames = Class {
    frames = {},

    init = function(self, basename, numFrames, fps)
        for frame = 0, numFrames - 1 do
            self.frames[frame] = love.graphics.newImage(string.format(basename, frame))
        end

        self.fps = fps
        self.numFrames = numFrames
        self.width = self.frames[0]:getWidth();
        self.height = self.frames[0]:getHeight();
        self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.width, self.height)
    end
}

Animation = Class{
    __includes = Entity,

    curFrame = 0,

    init = function(self, x, y, level, frames)
        Entity.init(self, x, y, level)

        self.frames = frames
        self.angle = 0
        self.x = x
        self.y = y
    end;

    draw = function(self)
        local img = self.frames.frames[math.floor(self.curFrame)]
        if img then
            love.graphics.setColor(255, 255, 255, 255 * (1.0 - self.curFrame / self.frames.numFrames))
            love.graphics.draw(img, self.frames.quad, self.x, self.y, self.angle, 1, 1, self.frames.width / 2, self.frames.width / 2)
        end
    end;

    update = function(self, dt)
        self.curFrame = self.curFrame + dt * self.frames.fps
    end;
}
