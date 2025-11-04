require("lib.colorise")
local Player = {}
Player.__index = Player

function Player:new(param)
	param = param or {}
	local obj = {
		x = param.x or 100,
		y = param.y or 100,
		world = param.world or nil,
		debug = param.debug or false,
		offsetX = param.offsetX or 0,
		offsetY = param.offsetY or 0,
		img = param.img or nil,
		radius = param.radius or 30,
		angle = math.rad(90),
		fill = param.fill or "line",
		name = param.name or "Player",
		body = {},
		speed = param.speed or 120,
		particle_img = param.particle_img or nil,
		thrusting = param.thrusting or false,
		fire = {},
		color = param.color or { 1, 1, 1 },
	}
	setmetatable(obj, self)
	return obj
end

function Player:load()
	self.world:addCollisionClass(self.name)
	-- self.body = self.world:newRectangleCollider(self.x - 10, self.y - 20, 30, 30)
	self.body = self.world:newCircleCollider(self.x, self.y, self.radius)
	self.body:setCollisionClass(self.name)
	self.body:setFixedRotation(true)
	self.body:setObject(self)

	--particle effect
	if self.thrusting then
		self.fire = love.graphics.newParticleSystem(self.particle_img, 200)
		self.fire:setParticleLifetime(0, 1.20)
		self.fire:setEmissionRate(130)
		self.fire:setSizes(0, 0.25, 0.60)
		self.fire:setSpeed(60, 125)
		self.fire:setSpread(math.rad(0))
		self.fire:setDirection(math.rad(self.angle))
	end
end

function Player:draw()
	if self.img then
		love.graphics.draw(self.img, self.x, self.y)
	end

	if self.angle and self.radius then
		-- Calculate the three points of the triangle
		local x1 = self.x + math.cos(self.angle) * self.radius -- tip
		local y1 = self.y + math.sin(self.angle) * self.radius

		local x2 = self.x + math.cos(self.angle + 2.5) * self.radius -- base left
		local y2 = self.y + math.sin(self.angle + 2.5) * self.radius

		local x3 = self.x + math.cos(self.angle - 2.5) * self.radius -- base right
		local y3 = self.y + math.sin(self.angle - 2.5) * self.radius

		-- Draw the triangle
		if self.color then
			love.graphics.setColor(self.color)
		end
		love.graphics.polygon(self.fill, x1, y1, x2, y2, x3, y3)
		love.graphics.setColor(1, 1, 1)
	end

	if self.fire then
		love.graphics.draw(self.fire)
	end
end

function Player:update(dt)
	local mx, my = love.mouse.getPosition()
	self.x, self.y = self.body:getPosition()
	self.angle = math.atan2(my - self.y, mx - self.x)
	if self.fire then
		self.fire:update(dt)
		self.fire:setPosition(
			self.x - math.cos(self.angle) * self.radius,
			self.y - (math.sin(self.angle) * self.radius * 0.50)
		)
		self.fire:setDirection(self.angle + math.pi)
	end
end

function Player:move(dx, dy)
	self.body:setLinearVelocity(dx * self.speed, dy * self.speed)
end

return Player
