Class = require 'hump/class'
require 'settings'



ComputerPlayer = Class{
    init = function(self, id, name)
        self.id = id
        self.name = name
        self.score = 0
        self.startedFiring = false

        print('Computer player ' .. self.name .. ' (' .. self.id .. ') ready for action!')
    end;

    -- TODO: move to common base
    setPlane = function(self, plane)
        self.plane = plane
        if plane ~= nil then
            plane:setOwner(self)
            self.startedFiring = false
            self.health = 1000
        end
    end;

    -- TODO: move to common base
    getPlane = function(self)
        return self.plane
    end;

    -- TODO: move to common base
    addScore = function(self, score)
        self.score = self.score + score
    end;

    update = function(self, dt)
        if self.plane then
            local ang = self.plane.body:getAngle()
            if not self.startedFiring then
                self.startedFiring = true
                self.plane:shoot(true)
            end
            local wantCw = false
            local wantCcw = false

            if ang > math.pi - math.pi / 2 and
                ang < math.pi + math.pi / 2 then
                local needLift = self.plane.body:getY() > 400
                if needLift then
                    wantCw = true
                elseif ang > math.pi then
                    wantCcw = true
                elseif ang < math.pi then
                    wantCw = true
                end
            end

            print("angle", ang, "wantCw", wantCw, "wantCcw", wantCcw)
            self.plane:cw(wantCw)
            self.plane:ccw(wantCcw)
        end
    end;

    press = function(self, key)
    end;

    release = function(self, key)
    end;
}
