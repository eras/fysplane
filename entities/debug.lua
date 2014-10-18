class = require 'hump.class'

DebugVector = Class {
    init = function(self, x0 , y0, dx, dy)
        self.x0 = x0;
        self.y0 = y0;
        self.dx = dx;
        self.dy = dy;
    end;


    draw = function(self)
        love.graphics.setColor(255, 0, 0)
        love.graphics.line(self.x0, self.y0, self.x0 + self.dx, self.y0 + self.dy);
    end;
}

drawDebugVectors = function(debugVectors) 
    for key, debugVector in pairs(debugVectors) do
        debugVector:draw();
    end
end;
