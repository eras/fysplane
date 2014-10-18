Class = require 'hump.class'
require 'entities/physicsentity'
require 'settings'
require 'entities/debug'
Matrix = require 'matrix'
VectorLight = require 'hump/vector-light'

local function sign(v)
    if v >= 0 then
        return 1
    else
        return -1
    end
end

local fwd_frict_coeff = 0.2
local nor_frict_coeff = 2.0
local tail_frict_coeff = 0.5
local head_area = 1.0
local plane_area = 10.0
local tail_area = 0.2
local turn_speed = 0.2
local wing_lift = 0.1

Plane = Class{
    __includes = PhysicsEntity,

    img = nil,

    motor_power = 500,

    debugVectors = {},

    turningCw = false,
    turningCcw = false,

    init = function(self, x, y, level)
        local density = 50
        PhysicsEntity.init(self, x, y, level, "dynamic", 0.2)
        self.xsize = 55
        self.ysize = 20
        self.shape = love.physics.newRectangleShape(self.xsize, self.ysize)
        PhysicsEntity.attachShape(self, density)
        self.body:setX(self.x + self.xsize / 2)
        self.body:setY(self.y - self.ysize / 2)
        self.angle = 0

        self.img = love.graphics.newImage("resources/graphics/box-50x50.png");
        self.quad = love.graphics.newQuad(0, 0, self.xsize, self.ysize, self.img:getWidth(), self.img:getHeight()) 
    end;

    update = function(self)
        debugVectors = {}
        PhysicsEntity.update(self, dt)

        self.x, self.y = self.fixture:getBoundingBox()
        self.angle = self.body:getAngle()

        local vel_x, vel_y = self.body:getLinearVelocity()
        local abs_vel = VectorLight.len2(vel_x, vel_y)

        -- -- local base = 
        -- let base = V.base (V.vec_of_ang (~-(body#get_angle))) in
        local base = Matrix{{math.cos(-self.angle), math.sin(-self.angle)}, {math.cos(-self.angle + math.pi / 2), math.sin(-self.angle + math.pi / 2)}}
        local to_base = function(x, y) 
            return Matrix.mul(Matrix{{x}, {y}}, base)
        end
        
        local fwd_x, fwd_y = VectorLight.rotate(self.angle, 1, 0)
        local normal_x, normal_y = VectorLight.rotate(self.angle, 0, 1)
        local normal_unit_x, normal_unit_y = VectorLight.div(VectorLight.len(normal_x, normal_y), normal_x, normal_y)
        local fwd_vel = VectorLight.dot(vel_x, vel_y, fwd_x, fwd_y)
        local normal_vel = VectorLight.dot(vel_x, vel_y, normal_x, normal_y)

        local tail_speed = self.body:getAngularVelocity() * math.pi * 2.0 * self.xsize / 2.0
        local tail_vel = to_base(0, tail_speed) -- hmm?! not tail_speed, 0?
        local abs_tail_vel_x, abs_tail_vel_y = VectorLight.add(vel_x, vel_y, tail_vel[1][1], tail_vel[2][1])
        --print("absolute tail veloicty: ", abs_tail_vel_x, abs_tail_vel_y)

        local head_angle = self.angle

        local rel_force = function(label, force, at)
            self.body:applyForce(force, at)
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

        local lift = function(angle) 
            return 1.68429 * math.exp(-math.pow(angle / math.pi * 180.0 -17.3801, 2.0) / math.pow(2.0*15.0, 2.0))
        end

        local lift_coeff = lift(air_wing_angle)

        -- print("lift coeff: ", lift_coeff)

        -- motor
        local dx, dy = VectorLight.rotate(self.angle, self.motor_power * 10.0 * PIXELS_PER_METER, 0)
        self.body:applyForce(dx, dy);
        -- table.insert(debugVectors, DebugVector(self.body:getX(), self.body:getY(), dx, dy))

        -- Air friction (and drag?) opposes movement towards plane velocity normal also
        -- hdd drag
        local hddrag_x, hddrag_y = VectorLight.mul(nor_frict_coeff * math.pow(normal_vel, 2.0) * sign(normal_vel), -normal_unit_x, -normal_unit_y)
        --        self.body:applyForce()
        local b = to_base(-1.0, 0.0)
        self.body:applyForce(hddrag_x, hddrag_y, b[1][1], b[2][1])
        
        local lift_x, lift_y = VectorLight.mul(wing_lift * math.pow(fwd_vel, 2.0) * lift_coeff, normal_unit_x, normal_unit_y)
        self.body:applyForce(lift_x, lift_y, self.body:getX(), self.body:getY())

        if self.turningCcw then
            dx, dy = VectorLight.rotate(self.angle - math.pi / 2, 1000, 0)
        elseif self.turningCw then
            dx, dy = VectorLight.rotate(self.angle - math.pi / 2, -1000, 0)
        end
        local rdx, rdy = VectorLight.rotate(self.angle, self.xsize / 2, 0)
        self.body:applyForce(dx, dy, self.body:getX() + rdx, self.body:getY() + rdy)
        table.insert(debugVectors, DebugVector(self.body:getX() + rdx, self.body:getY() + rdy, dx, dy))

        -- table.insert(debugVectors, DebugVector(self.x + width / 2, self.y + height / 2, 0, -100))
        -- table.insert(debugVectors, DebugVector(self.x, self.y, -100, 0))
        -- table.insert(debugVectors, DebugVector(self.x + 55, self.y + 10, dx, dy)
    end;

    draw = function(self)
        PhysicsEntity.draw(self)
        love.graphics.draw(self.img, self.quad, self.body:getX(), self.body:getY(), self.angle, 1, 1, self.xsize / 2, self.ysize / 2)
        drawDebugVectors(debugVectors)
    end;
}

