Class = require 'hump/class'
require 'settings'
require 'utils'

local SCOREBOARD_FONT = love.graphics.newFont(16)

Scoreboard = Class{
    init = function(self, x, y, player)
        self.player = player
        self.x = x
        self.y = y
    end;

    draw = function(self)
        if self.player.plane == nil then
            return
        end

        local origWidth = love.graphics.getLineWidth()

        love.graphics.setFont(SCOREBOARD_FONT)
        love.graphics.setColor(128, 57, 75, 255)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", self.x, self.y, SCOREBOARD_WIDTH, SCOREBOARD_HEIGHT)

        love.graphics.print(self.player.name, self.x + SCOREBOARD_MARGIN, self.y + SCOREBOARD_MARGIN)
        love.graphics.print("Score", self.x + SCOREBOARD_MARGIN, self.y + SCOREBOARD_MARGIN + 20)
        love.graphics.printf(self.player.score, self.x + SCOREBOARD_MARGIN, self.y + SCOREBOARD_MARGIN + 20, SCOREBOARD_WIDTH - 2 * SCOREBOARD_MARGIN, "right")

        love.graphics.setLineWidth(origWidth)

        local health_ratio = self.player.plane.health / PLANE_HEALTH
        local start_color = {0, 255, 0}
        local end_color = {255, 0, 0}
        love.graphics.setColor(colorSlide(start_color, end_color, health_ratio))
        love.graphics.rectangle("fill", self.x + SCOREBOARD_MARGIN, self.y + SCOREBOARD_MARGIN + 45, (SCOREBOARD_WIDTH - 2 * SCOREBOARD_MARGIN) * health_ratio, 20)
        love.graphics.setColor({0, 0, 0, 255})
        love.graphics.print("Health", self.x + SCOREBOARD_MARGIN, self.y + SCOREBOARD_MARGIN + 45)

        local engine_ratio = self.player.plane.motorPower / ENGINE_MAX
        local start_color = {0, 255, 0}
        local end_color = {255, 0, 0}
        love.graphics.setColor(colorSlide(start_color, end_color, engine_ratio))
        love.graphics.rectangle("fill", self.x + SCOREBOARD_MARGIN, self.y + SCOREBOARD_MARGIN + 70, (SCOREBOARD_WIDTH - 2 * SCOREBOARD_MARGIN) * engine_ratio, 20)
        love.graphics.setColor({0, 0, 0, 255})
        love.graphics.print("Engine", self.x + SCOREBOARD_MARGIN, self.y + SCOREBOARD_MARGIN + 70)
    end;
}
