--[[
Some random utilities that can be useful
]]



-- Calculate XY position from given degrees (not rad!) and distance
-- Returns tuple {X, Y} coordinates
-- Note that either may be negative
function deg_dist_to_xy(degrees, distance)
    local rad = deg_to_rad(degrees)
    return rad_dist_to_xy(rad, distance)
end

function rad_dist_to_xy(radians, distance)
    return {distance * math.cos(radians), distance * math.sin(radians)}
end

-- Convert degrees to radians
function deg_to_rad(degrees)
    return degrees * math.pi / 180
end

function rad_to_deg(radians)
    return radians * 180 / math.pi
end

-- Convert X,Y to rad from horizontal axle (pointing right)
function xy_to_rad(x, y)
    -- Avoid division by 0
    if x == 0 then
        if y >= 0 then
            return math.pi / 2
        else
            return math.pi * 1.5
        end
    else
        local angle = math.atan(math.abs(y) / math.abs(x))

        -- Take into account the quadrant we are in
        if x >= 0 and y < 0 then
            return 2 * math.pi - angle
        elseif x < 0 and y < 0 then
            return math.pi + angle
        elseif x < 0 and y >= 0 then
            return math.pi - angle
        else
            return angle
        end
    end
end

function xy_to_deg(x, y)
    return rad_to_deg(xy_to_rad(x, y))
end

-- Get distance between two points
function distance(x1, y1, x2, y2)
    return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2))
end

-- Get objects within a radius from given coordinates in given level
function getObjectsInRadius(x, y, radius, level, include_player)
    include_player = include_player or false
    local objs = level.world:getBodyList()
    local ret = {}
    for _, body in pairs(objs) do
        if distance(x, y, body:getX(), body:getY()) <= radius then
            if body:getFixtureList()[1]:getUserData() ~= player
                or include_player then
                table.insert(ret, body)
            end
        end
    end

    return ret
end

-- Pick a color from a color slide, from rgb0 (0%) to rgb100 (100%)
function colorSlide(rgb0, rgb100, ratio)
    local red = colorNAKKIVENE(rgb0[1], rgb100[1], ratio)
    local green = colorNAKKIVENE(rgb0[2], rgb100[2], ratio)
    local blue = colorNAKKIVENE(rgb0[3], rgb100[3], ratio)
    return {red, green, blue}
end

function colorNAKKIVENE(color100, color0, ratio)
    return ratio * color100 + (1 - ratio) * color0
end

function getJoystickButtons(j)
    local buttons = {}
    for i = 1, j:getButtonCount(), 1 do
	buttons[#buttons + 1] = j:isDown(i)
    end
    local hatDirs = {"u", "r", "d", "l"}
    for i = 1, j:getHatCount(), 1 do
	local hat = j:getHat(i)
	for j = 1, #hatDirs, 1 do
	    buttons[#buttons + 1] = hatDirs[j] == hat
	end
    end
    return buttons
end

function getJoystickAxis(joystick, info)
    local value = 0
    if info.axis > 0 and joystick:getAxisCount() >= info.axis then
	value = joystick:getAxis(info.axis)
	if info.flipped then
	    value = -value
	end
    end
    return value
end

function getRotation(joystick, player)
    return getJoystickAxis(joystick, AXISMAP[player].rotation[1]) + getJoystickAxis(joystick, AXISMAP[player].rotation[2])	
end

function getThrottle(joystick, player)
    return getJoystickAxis(joystick, AXISMAP[player].throttle[1]) + getJoystickAxis(joystick, AXISMAP[player].throttle[2])
end
