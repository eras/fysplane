Class = require 'hump.class'
require 'entities/physicsentity'
require 'settings'
require 'entities/debug'
Matrix = require 'matrix'
VectorLight = require 'hump/vector-light'
require 'utils'
require 'machinegun'

local function sign(v)
    if v >= 0 then
        return 1
    else
        return -1
    end
end

local lift = function(angle) 
    return 1.68429 * math.exp(-math.pow(angle / math.pi * 180.0 -17.3801, 2.0) / (2.0 * math.pow(15.0, 2.0)))
end

local fwd_frict_coeff = 0.3
local nor_frict_coeff = 2.0
local tail_frict_coeff = 10.4
local turn_speed = 2.0
local wing_lift = 0.1 * 3
local accel_speed = 100.0
local decel_speed = 200.0
local max_motorPower = ENGINE_MAX
local plane_area = 10.0
local head_area = 1.0

Plane = Class{
    __includes = PhysicsEntity,

    frames = {},

    motorPower = 400,

    debugVectors = {},

    turningCw = false,
    turningCcw = false,

    accelerating = false,
    decelerating = false,

    goingRight = true, -- the plane is upside up and going right (or upside down and going left)

    init = function(self, x, y, xDir, yDir, level)
        local density = 50
        PhysicsEntity.init(self, x, y, level, "dynamic", 0.2)
        self.xsize = 4.0 * PIXELS_PER_METER
        self.ysize = 4.3 * PIXELS_PER_METER
        self.shape = love.physics.newRectangleShape(self.xsize, self.ysize)
        PhysicsEntity.attachShape(self, density)
        self.body:setX(self.x + self.xsize / 2)
        self.body:setY(self.y - self.ysize / 2)
        self.body:setLinearVelocity(xDir, yDir)
        self.goingRight = xDir >= 0
        self.body:setAngle(math.atan2(yDir, xDir))
        -- self.body:setMassData(self.xsize / 2, self.ysize / 2, 440 * PIXELS_PER_METER, -1.0)
        -- self.body:setMassData(self.xsize / 2, 0, 430, 158194)
        self.fixture:setFriction(0)
        self.angle = 0

        --x	16	y	17.200000762939	mass	3520	inertia	1942476.875
        --x	0	y	0	mass	860.00006103516	inertia	158194.140625

        -- local x, y, mass, inertia = self.body:getMassData()
        print("x", x, "y", y, "mass", mass, "inertia", inertia)

        for frame = 0,35 do
            self.frames[frame] = love.graphics.newImage(string.format("resources/graphics/plane-%04d.png", frame))
        end
        self.quad = love.graphics.newQuad(0, 0, self.xsize, self.ysize, self.frames[0]:getWidth(), self.frames[0]:getHeight())

        self.machinegun = MachineGun(self, PLANE_DEFAULT_GUN)

        self.health = PLANE_HEALTH
        self.powerupmode = nil
    end;

    receiveDamage = function(self, amount) 
        self.health = math.max(0, self.health - amount);
    end;

    getGunPosition = function(self)
        local x = self.body:getX()
        local y = self.body:getY()

        local pos = rad_dist_to_xy(self.angle, self.xsize / 2)
        return {x + pos[1], y + pos[2]}
    end;

    setPowerUpMode = function(self, powerupmode)
        print("Got powerup!")
        self.powerupmode = powerupmode
        self.powerupmode:activate(self)
    end;

    accelerate = function(self, down)
        self.accelerating = down
    end;

    decelerate = function(self, down)
        self.decelerating = down
    end;

    shoot = function(self, down)
        if down then
            self.machinegun:startShooting()
        else
            self.machinegun:stopShooting()
        end
    end;

    update = function(self, dt)
        self.debugVectors = {}
        PhysicsEntity.update(self, dt)
        self.machinegun:update(dt)


        if self.body:getY() < 0 then
            self.motorPower = 0
        end

        if self.powerupmode ~= nil then
            self.powerupmode:update(dt)
        end

        self.x, self.y = self.fixture:getBoundingBox()
        self.angle = self.body:getAngle()

        local vel_x, vel_y = self.body:getLinearVelocity()
        local abs_vel = VectorLight.len(vel_x, vel_y)

        if self.accelerating then 
            self.motorPower = math.min(max_motorPower, self.motorPower + dt * accel_speed)
        end
        if self.decelerating then
            self.motorPower = math.max(0.0, self.motorPower - dt * accel_speed)
        end

        -- -- local base = 
        -- let base = V.base (V.vec_of_ang (~-(body#get_angle))) in
        local basde = Matrix{{math.cos(-self.angle),
                             math.sin(-self.angle)},
                            {math.cos(-self.angle + math.pi / 2),
                             math.sin(-self.angle + math.pi / 2)}}
        local to_base = function(x, y) 
            local m = Matrix.mul(basde, Matrix{{x}, {y}})
            -- print("to_base", x, y, "->", Matrix.tostring(m), " = ", m[1][1], m[2][1])
            return m
        end

        -- print("-")
        -- print(Matrix.tostring(base))
        
        local fwd_x, fwd_y = VectorLight.rotate(self.angle, 1, 0)
        local normal_x, normal_y = VectorLight.perpendicular(fwd_x, fwd_y)
        local fwd_vel = VectorLight.dot(vel_x, vel_y, fwd_x, fwd_y)
        local normal_vel = VectorLight.dot(vel_x, vel_y, normal_x, normal_y)
        -- print("fwd_vel", fwd_vel, "normal_vel", normal_vel, "vel_x", vel_x, "vel_y", vel_y, "normal_x", normal_x, "normal_y", normal_y)
        table.insert(self.debugVectors, DebugVector("vel", self.body:getX(), self.body:getY(), vel_x, vel_y))
        table.insert(self.debugVectors, DebugVector("fwd", self.body:getX(), self.body:getY(), fwd_x, fwd_y))
        table.insert(self.debugVectors, DebugVector("normal", self.body:getX(), self.body:getY(), normal_x, normal_y))

        local tail_speed = self.body:getAngularVelocity() * math.pi * 2.0 * self.xsize / 2.0
        local tail_vel = to_base(0, tail_speed) -- hmm?! not tail_speed, 0?
        local abs_tail_vel_x, abs_tail_vel_y = VectorLight.add(vel_x, vel_y, tail_vel[1][1], tail_vel[2][1])
        table.insert(self.debugVectors, DebugVector("tail", self.body:getX(), self.body:getY(), tail_vel[1][1], tail_vel[2][1]))
        --print("absolute tail veloicty: ", abs_tail_vel_x, abs_tail_vel_y)

        local head_angle = self.angle

        local rel_force = function(label, force_x, force_y, rel_at_x, rel_at_y)
            -- rdx, rdy = VectorLight.add(rdx, rdy, self.body:getX(), self.body:getY())
            local base_force = to_base(force_x, force_y)
            local base_rel_at = to_base(rel_at_x, rel_at_y)
            base_rel_at_x, base_rel_at_y = VectorLight.add(base_rel_at[1][1], base_rel_at[2][1], self.body:getX(), self.body:getY())
            self.body:applyForce(base_force[1][1], base_force[2][1], base_rel_at_x, base_rel_at_y)

            at_x, at_y = VectorLight.add(base_rel_at_x, base_rel_at_y, base_force[1][1], base_force[2][1])

            --print(at_x, at_y)
            -- print("base matrix", Matrix.tostring(base))
            -- print("force", force_x, force_y)
            -- print("force after transformation", Matrix.tostring(to_base(force_x, force_y)))
            -- print("base_force", base_force[1][1], base_force[2][1])
            -- print("base_force'", Matrix.tostring(base_force))

            table.insert(self.debugVectors, DebugVector(label, base_rel_at_x, base_rel_at_y, base_force[1][1], base_force[2][1]))
        end
        
        local speed_angle
        if abs_vel < 1.0 then
            speed_angle = head_angle
        else
            speed_angle = math.atan2(vel_y, vel_x)
        end

        local air_wing_angle
        local tmp
        tmp = head_angle - speed_angle
        if tmp > math.pi then
            air_wing_angle = tmp - 2.0 * math.pi
        else
            air_wing_angle = tmp
        end

        local lift_coeff = lift(air_wing_angle)

        -- print("lift coeff: ", lift_coeff)

        -- motor
        local dx, dy = VectorLight.rotate(self.angle, self.motorPower * 10.0 * PIXELS_PER_METER, 0)
        self.body:applyForce(dx, dy);
        -- table.insert(self.debugVectors, DebugVector(self.body:getX(), self.body:getY(), dx, dy))

        -- (* self#add_force "fwddrag" *)
        -- (*   (Gg.V2.smul (fwd_frict_coeff *. fwd_vel ** 2.0 *. head_area) (V.unit (negate vel))) *)
        -- (*   (to_base (Gg.V2.v 0.0 0.0)); *)
        local airdrag = -fwd_frict_coeff * math.pow(fwd_vel, 2.0) * head_area
        rel_force("airdrag", airdrag, 0, 0, 0.2 * self.ysize)

        -- Air friction (and drag?) opposes movement towards plane velocity normal also
        -- hdd drag
        local hddrag_x, hddrag_y = VectorLight.mul(nor_frict_coeff * math.pow(normal_vel, 2.0) * plane_area * sign(normal_vel), 0, -1.0)
        local b = to_base(-1.0, 0.0)
        rel_force("hddrag", hddrag_x, hddrag_y, -self.xsize / 2, 0);
        -- self.body:applyForce(hddrag_x, hddrag_y, b[1][1], b[2][1])
        
        local lift_x, lift_y = VectorLight.mul(wing_lift * math.pow(fwd_vel, 2.0) * lift_coeff, 0, -1)
        rel_force("lift", lift_x, lift_y, self.xsize * 0.8, 0)

        local tail_frict = tail_frict_coeff * math.pow(tail_speed, 2.0) * sign(tail_speed)
        rel_force("tf", 0, tail_frict, -self.xsize / 2, 0)

        -- if self.turningCcw then
        --     dx, dy = VectorLight.rotate(self.angle, 0, 50000)
        -- elseif self.turningCw then
        --     dx, dy = VectorLight.rotate(self.angle, 0, -50000)
        -- end
        if self.turningCcw then
            dx, dy = 0, -turn_speed
        elseif self.turningCw then
            dx, dy = 0, turn_speed
        end
        if self.turningCw or self.turningCcw then 
            dx, dy = VectorLight.mul(turn_speed * math.pow(fwd_vel, 2.0) * sign(fwd_vel), dx, dy)
            -- print("dx", dx, "dy", dy, "tail_speed", tail_speed)
            -- self.body:applyForce(dx, dy, self.body:getX() + rdx, self.body:getY() + rdy)
            rel_force("turn", dx, dy, -0.4 * self.xsize, 0);
        end
        -- print(dx, dy)

        -- table.insert(self.debugVectors, DebugVector(self.x + width / 2, self.y + height / 2, 0, -100))
        -- table.insert(self.debugVectors, DebugVector(self.x, self.y, -100, 0))
        -- table.insert(self.debugVectors, DebugVector(self.x + 55, self.y + 10, dx, dy)
    end;

    draw = function(self)
        if self.health > 0 then
            PhysicsEntity.draw(self)
            love.graphics.push()

            if self.goingRight then
                love.graphics.translate(self.body:getX(), self.body:getY())
                love.graphics.scale(-1, 1)
                love.graphics.draw(self.frames[0], self.quad, 0, 0, -self.angle, 1, 1, self.xsize / 2, self.ysize / 2)
            else
                love.graphics.translate(self.body:getX(), self.body:getY())
                love.graphics.scale(-1, -1)
                love.graphics.draw(self.frames[0], self.quad, 0, 0, self.angle, 1, 1, self.xsize / 2, self.ysize / 2)
            end

            love.graphics.pop()
            drawDebug(self.debugVectors)
        end
    end;

    cw = function(self, isTurning)
        self.turningCw = isTurning
    end;

    ccw = function(self, isTurning)
        self.turningCcw = isTurning
    end;
}

