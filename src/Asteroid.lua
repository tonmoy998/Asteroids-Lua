local Asteroid = {}
Asteroid.__index = Asteroid

-- Utility: Generate random polygon points
local function generatePolygon(x, y, radius, points)
	local vertices = {}
	local angleStep = (math.pi * 2) / points

	for i = 1, points do
		local r = radius * love.math.random(80, 120) / 100
		local angle = angleStep * i
		local vx = x + math.cos(angle) * r
		local vy = y + math.sin(angle) * r
		table.insert(vertices, vx)
		table.insert(vertices, vy)
	end
	return vertices
end

-- Constructor
function Asteroid:new(param)
	param = param or {}
	local obj = {
		x = param.x or love.graphics.getWidth() / 2,
		y = param.y or love.graphics.getHeight() / 2,
		radius = param.radius or love.math.random(20, 50),
		sides = param.sides or love.math.random(6, 7),
		rotation = param.rotation or 0,
		rotationSpeed = param.rotationSpeed or love.math.random() * 1 - 0.5,
		speed = param.speed or love.math.random(20, 80),
		direction = param.direction or love.math.random() * math.pi * 2,
		color = param.color or { 1, 1, 1 },
		world = param.world or {},
		body = {},
		dead = param.dead or false,
		fill = param.fill or "line",
		health = param.health or 100,
	}
	obj.vertices = generatePolygon(obj.x, obj.y, obj.radius, obj.sides)
	setmetatable(obj, Asteroid)
	obj:load()
	return obj
end

function Asteroid:load()
	if not self.world.collision_classes["Asteroid"] then
		self.world:addCollisionClass("Asteroid")
	end
	self.body = self.world:newPolygonCollider(self.vertices)
	self.body:setCollisionClass("Asteroid")
	self.body:setObject(self)
	self.health = self.body:getMass() * 100
end

function Asteroid:update(dt)
	if self.body and self.health > 0 then
		self.x, self.y = self.body:getPosition()
		if self.health <= 0 then
			self.body:destroy()
		end
	end
end

function Asteroid:draw()
	if self.body then
		love.graphics.setColor(self.color)
		love.graphics.polygon(self.fill, self.body:getWorldPoints(unpack(self.vertices)))
	end
end
-- take damage
function Asteroid:takedamage(value)
	value = value or 30
	self.health = self.health - value
end

-- destroy the body
function Asteroid:destroy()
	if self.body then
		self.body:destroy()
	end
end

return Asteroid
