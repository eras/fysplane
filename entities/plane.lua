Class = require 'hump.class'
require 'entities/physicsentity'
require 'settings'
require 'entities/debug'
require 'entities/animation'
require 'entities/ground'
require 'entities/arrow'
Matrix = require 'matrix'
VectorLight = require 'hump/vector-light'
require 'utils'
require 'machinegun'

-- normalizes angle to be between [0 .. 2 pi[
local normalizeAngle = function(angle)
    if angle < 0 then
	angle = -angle
	angle = angle - 2 * math.pi * math.floor(angle / (2 * math.pi))
	angle = math.pi * 2 - angle
    else
	angle = angle - 2 * math.pi * math.floor(angle / (2 * math.pi))
    end
    return angle
end


local CLANG_SFX = {
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #1.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #2.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #3.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #4.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #5.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #6.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #7.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #8.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #9.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #10.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #11.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #12.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #13.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #14.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #15.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #16.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #17.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #18.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #19.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #20.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #21.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #22.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #23.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #24.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #25.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #26.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #27.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #28.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #29.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #30.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #31.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #32.wav"),
    love.audio.newSource("resources/audio/clangs/cast iron clangs - Marker #33.wav")
}

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

local fwd_frict_coeff = 0.1
local fwd_frict_coeff_decelare_multiplier = 3
local nor_frict_coeff = 0.8
local tail_frict_coeff = 0.4
local tail_area = 5.0
local turn_coeff = 500.0
local wing_lift = 0.3
local accel_speed = 400.0
local decel_speed = 400.0
local max_motorPower = ENGINE_MAX
local head_area = 1.0
local plane_area = 10.0
local motor_speed_ratio = 80.0

local out_of_bounds_coeff_multiplier = 10.0

local explosionFrames = AnimationFrames("resources/graphics/explosion-%04d.png", 36, 15, true)

Plane = Class{
    __includes = PhysicsEntity,

    frames = {},

    motorPower = INITIAL_ENGINE_SPEED,

    debugVectors = {},

    turningCw = false,
    turningCcw = false,

    accelerating = false,
    decelerating = false,

    goingRight = true, -- the plane is upside up and going right (or upside down and going left)

    orientationAngle = 0,

    controlX = 0,
    controlY = 0,
    throttleX = 0,
    throttleY = 0,

    kbdShooting = false,
    joyShooting = false,

    init = function(self, x, y, xDir, yDir, r, g, b, level)
        local density = 50
        PhysicsEntity.init(self, x, y, level, "dynamic", 0.2)
	self.r = r
	self.g = g
	self.b = b
        self.level = level
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
        self.body:setMassData(7, 5, 800, 558194.140625)
        self.body:setAngularDamping(0.1)
        self.fixture:setFriction(0.5)
        self.angle = 0

        --x	16	y	17.200000762939	mass	3520	inertia	1942476.875
        --x	0	y	0	mass	860.00006103516	inertia	158194.140625

        local x, y, mass, inertia = self.body:getMassData()
        --print("x", x, "y", y, "mass", mass, "inertia", inertia)

        for frame = 0,35 do
            self.frames[frame] = love.graphics.newImage(string.format("resources/graphics/plane-%04d.png", frame))
        end
        self.quad = love.graphics.newQuad(0, 0, self.xsize, self.ysize, self.frames[0]:getWidth(), self.frames[0]:getHeight())

        self.machinegun = MachineGun(self, PLANE_DEFAULT_GUN)

        self.health = PLANE_HEALTH
        self.powerupmode = nil

	self.outOfBoundsArrow = nil

	self.motorSound = love.audio.newSource("resources/audio/motorsound.wav", "static")

        self.motorSound:rewind()
        self.motorSound:play()
	self.motorSound:setLooping(true)
    end;

    receiveDamage = function(self, amount)
        local oldHealth = self.health
        self.health = math.max(0, self.health - amount);
        if oldHealth > 0 and self.health == 0 then
            self:die()
        end
    end;

    die = function(self)
        self.health = 0
	if self.joyShooting or self.kbdShooting then
	    self.machinegun:stopShooting()
	end
	self.joyShooting = false
	self.kbdShooting = false
        Animation(self.body:getX(), self.body:getY(), self.level, explosionFrames)
        self:getOwner():setPlane(nil)
	self.motorSound:stop()
        self:delete()
    end;

    delete = function(self)
	self.motorSound:stop()
	PhysicsEntity.delete(self)
    end;

    getGunPosition = function(self)
        local x = self.body:getX()
        local y = self.body:getY()

        local pos = rad_dist_to_xy(self.angle, self.xsize)
        return {x + pos[1], y + pos[2]}
    end;

    setPowerUpMode = function(self, powerupmode)
        --print("Got powerup!")
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
        if self.health > 0 then
            if down then
		if not kbdShooting and not joyShooting then
		    self.machinegun:startShooting()
		end
		kbdShooting = true
            else
		kbdShooting = false
		if not kbdShooting and not joyShooting then
		    self.machinegun:stopShooting()
		end
            end
        end
    end;

    wasHitBy = function(self, by)
	if by:isinstance(Ground) then
	    local angle = normalizeAngle(self.body:getAngle())
	    if (self.goingRight and (angle > math.pi * 2 - math.pi / 4 or angle < math.pi / 4)) or
		(not self.goingRight and (angle > math.pi - math.pi / 4 and angle < math.pi + math.pi / 4)) then
		-- don't die this time.
	    else
		self:receiveDamage(1000)
		self:getOwner():addScore(SUICIDE_SCORE)
	    end
	elseif not by:isinstance(Ground) then
	    local i = love.math.random(#CLANG_SFX)
	    CLANG_SFX[i]:play()
	end
    end;

    update = function(self, dt)
        local mass_x, mass_y, mass, inertia = self.body:getMassData()

        self.debug = {}
        PhysicsEntity.update(self, dt)
        self.machinegun:update(dt)

	local dir_coeff;
	if self.goingRight then
	    dir_coeff = 1
	else
	    dir_coeff = -1
	end
	local coeff_multiplier = 1

        local vel_x, vel_y = self.body:getLinearVelocity()
        local abs_vel = VectorLight.len(vel_x, vel_y)

        if self.body:getY() < 0 then
            self.motorPower = 0
	    if vel_y < 0 then
		coeff_multiplier = out_of_bounds_coeff_multiplier
	    end

	    if not self.outOfBoundsArrow then
		self.outOfBoundsArrow = Arrow(0, 0, self.level, self.r, self.g, self.b)
	    end
	    self.outOfBoundsArrow:setX(self.body:getX())
	elseif self.outOfBoundsArrow then
	    self.outOfBoundsArrow:delete()
	    self.outOfBoundsArrow = nil
        end

        if self.powerupmode ~= nil then
            self.powerupmode:update(dt)
        end

        self.x, self.y = self.fixture:getBoundingBox()
        self.angle = self.body:getAngle()

        if self.accelerating then 
            self.motorPower = math.min(max_motorPower, self.motorPower + dt * accel_speed)
        end
        if self.decelerating or self.brake then
            self.motorPower = math.max(0.0, self.motorPower - dt * decel_speed)
        end
	self.motorPower = math.max(0.0, math.min(max_motorPower, self.motorPower + dt * self.throttleY * accel_speed))

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
        table.insert(self.debug, DebugVector("vel", self.body:getX(), self.body:getY(), vel_x, vel_y))
        table.insert(self.debug, DebugVector("fwd", self.body:getX(), self.body:getY(), fwd_x, fwd_y))
        table.insert(self.debug, DebugVector("normal", self.body:getX(), self.body:getY(), normal_x, normal_y))

        local tail_speed = self.body:getAngularVelocity() * math.pi * 2.0 * self.xsize / 2.0 / PIXELS_PER_METER
        -- print("angular velocity", self.body:getAngularVelocity())
        local tail_vel = to_base(0, tail_speed) -- hmm?! not tail_speed, 0?
        local abs_tail_vel_x, abs_tail_vel_y = VectorLight.add(vel_x, vel_y, tail_vel[1][1], tail_vel[2][1])
        -- table.insert(self.debug, DebugVector("tail", self.body:getX(), self.body:getY(), tail_vel[1][1], tail_vel[2][1]))
        --print("absolute tail veloicty: ", abs_tail_vel_x, abs_tail_vel_y)

        local head_angle = self.angle

        local rel_force = function(label, force_x, force_y, rel_at_x, rel_at_y)
            if label == "turn" or
                label == "lift" or
                label == "hddrag" or
                label == "airdrag" or
                label == "tf" or
                label == "motor" then
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

                table.insert(self.debug, DebugVector(label, base_rel_at_x, base_rel_at_y, base_force[1][1], base_force[2][1]))
            end
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

        local lift_coeff = lift(-air_wing_angle) * dir_coeff

        -- print("lift coeff: ", lift_coeff)

        -- motor
        rel_force("motor",
                  self.motorPower * motor_speed_ratio * PIXELS_PER_METER, 0,
                  mass_x + 0.2, mass_y + 0.4)
        --self.body:applyForce(dx, dy);
        -- table.insert(self.debug, DebugVector(self.body:getX(), self.body:getY(), dx, dy))

        -- (* self#add_force "fwddrag" *)
        -- (*   (Gg.V2.smul (fwd_frict_coeff *. fwd_vel ** 2.0 *. head_area) (V.unit (negate vel))) *)
        -- (*   (to_base (Gg.V2.v 0.0 0.0)); *)
        local airdrag = coeff_multiplier * -fwd_frict_coeff * math.pow(fwd_vel, 2.0) * head_area
	if self.decelerating then
	    airdrag = airdrag * fwd_frict_coeff_decelare_multiplier
	end
        rel_force("airdrag", airdrag, 0, 0, 0.2 * self.ysize)

        -- Air friction (and drag?) opposes movement towards plane velocity normal also
        -- hdd drag
        local hddrag_x, hddrag_y = VectorLight.mul(coeff_multiplier * nor_frict_coeff * math.pow(normal_vel, 2.0) * plane_area * sign(normal_vel), 0, -1.0)
        rel_force("hddrag", hddrag_x, hddrag_y, mass_x, mass_y);
        
        local lift_x, lift_y = VectorLight.mul(wing_lift * math.pow(fwd_vel, 2.0) * lift_coeff, 0, -1)
        rel_force("lift", lift_x, lift_y, mass_x, mass_y)

        local tail_frict = tail_area * coeff_multiplier * tail_frict_coeff * math.pow(normal_vel, 2.0) * -sign(normal_vel)
        -- print("tail_speed", tail_speed)
        rel_force("tf", 0, tail_frict, -self.xsize / 2, 0)

        -- if self.turningCcw then
        --     dx, dy = VectorLight.rotate(self.angle, 0, 50000)
        -- elseif self.turningCw then
        --     dx, dy = VectorLight.rotate(self.angle, 0, -50000)
        -- end
	dy = 0
        if self.turningCcw then
            dy = 1
        elseif self.turningCw then
            dy = -1
	else
	    dy = self.controlY
        end
        if dy ~= 0 then 
            dx, dy = VectorLight.mul(fwd_vel * turn_coeff, 0, dy)
            -- dx, dy = VectorLight.mul(turn_coeff * 10000 -- * sign(fwd_vel)
            --                          , dx, dy)
            -- print("dx", dx, "dy", dy, "tail_speed", tail_speed)
            -- self.body:applyForce(dx, dy, self.body:getX() + rdx, self.body:getY() + rdy)
            rel_force("turn", dx, dy, -0.4 * self.xsize, 0);
        end
        -- print(dx, dy)

        -- table.insert(self.debug, DebugVector(self.x + width / 2, self.y + height / 2, 0, -100))
        -- table.insert(self.debug, DebugVector(self.x, self.y, -100, 0))
        -- table.insert(self.debug, DebugVector(self.x + 55, self.y + 10, dx, dy)

        local xy = to_base(mass_x, mass_y)
        local x, y = VectorLight.add(xy[1][1], xy[2][1], self.body:getX(), self.body:getY())
        table.insert(self.debug, DebugCircle("mc", x, y))

	local motorEffort = (self.motorPower / (math.max(fwd_vel, 100) + 1) - 1) / 2 + 1
	self.motorSound:setPitch(motorEffort * self.motorPower / ENGINE_MAX + 0.5)
    end;

    draw = function(self)
        if self.health > 0 then
            PhysicsEntity.draw(self)
            love.graphics.push()

	    love.graphics.setColor(self.r, self.g, self.b);
            if self.goingRight then
                love.graphics.translate(self.body:getX(), self.body:getY())
                love.graphics.scale(-1, 1)
                love.graphics.draw(self.frames[math.floor(self.orientationAngle / 10.0)], self.quad, 0, 0, -self.angle, 1, 1, self.xsize / 2, self.ysize / 2)
            else
                love.graphics.translate(self.body:getX(), self.body:getY())
                love.graphics.scale(-1, -1)
                love.graphics.draw(self.frames[math.floor(self.orientationAngle / 10.0)], self.quad, 0, 0, self.angle, 1, 1, self.xsize / 2, self.ysize / 2)
            end

            love.graphics.pop()

            drawDebug(self.debug)
        end
    end;

    cw = function(self, isTurning)
        self.turningCw = isTurning
    end;

    ccw = function(self, isTurning)
        self.turningCcw = isTurning
    end;

    analog = function(self, controlY, throttleX, throttleY, fire, brake)
        if self.health > 0 then
	    self.controlY = controlY
	    self.throttleX = throttleX
	    self.throttleY = -throttleY
	    self.fire = fire
	    self.brake = brake

            if fire then
		if not kbdShooting and not joyShooting then
		    self.machinegun:startShooting()
		end
		joyShooting = true
            else
		joyShooting = false
		if not kbdShooting and not joyShooting then
		    self.machinegun:stopShooting()
		end
            end
        end
    end;
}

