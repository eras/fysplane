class = require 'hump.class'
VectorLight = require 'hump/vector-light'

local scale = 10

local font = love.graphics.newFont(10)

DebugVector = Class {
    init = function(self, label, x0 , y0, dx, dy)
        self.x0 = x0;
        self.y0 = y0;
        self.dx = dx;
        self.dy = dy;
        self.label = label;
    end;


    draw = function(self)
        love.graphics.setColor(255, 0, 0)
        love.graphics.line(self.x0, self.y0, self.x0 + self.dx * scale, self.y0 + self.dy * scale);
        if self.label then
            love.graphics.setColor(0,0,0)
            love.graphics.setFont(font)
            local unit_x, unit_y = VectorLight.div(VectorLight.len(self.dx, self.dy), self.dx, self.dy)
            local dist_x, dist_y = self.dx * scale, self.dy * scale
            local distance = math.min(100, VectorLight.len(dist_x, dist_y))
            dist_x, dist_y = VectorLight.mul(distance, unit_x, unit_y)
            love.graphics.printf(self.label, self.x0 + dist_x, self.y0 + dist_y, 100, "left")
        end
    end;
}

drawDebugVectors = function(debugVectors) 
    for key, debugVector in pairs(debugVectors) do
        debugVector:draw();
    end
end;
