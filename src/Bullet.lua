local Bullet = {}
Bullet.__index = Bullet

function Bullet:new(param)
	local obj = {
		x = param.x or 100,
		y = param.y or 100,
		angle = param.angle or math.rad(90),
		world = assert(param.world, "Bullet.new() requires a Windfield world"),
		speed = param.speed or 600,
		size = param.size or 10,
		fill = param.fill or "fill",
	}
	setmetatable(obj, self)
	obj:load()
	return obj
end

function Bullet:load()
	-- Make sure the collision class exists before using it
	if not self.world.collision_classes["Bullet"] then
		self.world:addCollisionClass("Bullet", { ignores = { "Player" } })
	end

	self.body = self.world:newCircleCollider(self.x, self.y, self.size)
	self.body:setCollisionClass("Bullet")
	self.body:setObject(self)
end

function Bullet:update(dt)
	if not self.body then
		return
	end

	if self.body:enter("Asteroid") then
		local collision_data = self.body:getEnterCollisionData("Asteroid")
		local asteroid = collision_data.collider:getObject()
		asteroid:takedamage(300)
		-- asteroid:destroy()
	end
	local vx = math.cos(self.angle) * self.speed
	local vy = math.sin(self.angle) * self.speed
	self.body:setLinearVelocity(vx, vy)

	-- keep coordinates in sync for drawing
	self.x, self.y = self.body:getPosition()
end

function Bullet:draw(color)
	if color then
		love.graphics.setColor(color)
	end
	love.graphics.circle(self.fill, self.x, self.y, self.size)
	love.graphics.setColor(1, 1, 1)
end

function Bullet:destroy()
	if self.body then
		self.body:destroy()
	end
end

return Bullet
