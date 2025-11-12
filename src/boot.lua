local Boot = {}
Boot.__index = Boot

function Boot:new()
	local obj = {
		loaded = 0,
		total = 80, -- number of fake frames to load
		progress = 0,
		done = false,
	}
	setmetatable(obj, self)
	return obj
end

function Boot:load()
	-- Normally, here you require libs and load assets
	-- But we delay it to simulate loading
	self.assets = {
		"fire",
		"player",
		"shoot",
		"target",
	}
end

function Boot:update(dt)
	--fake loading
	if self.loaded < self.total then
		self.loaded = self.loaded + 1
		self.progress = self.loaded / self.total
	else
		self.assets_real = {
			fire = love.graphics.newImage("src/assets/smoke.png"),
			target = love.graphics.newImage("src/assets/target.png"),
		}
		self.done = true
		_G.state = "running"
		_G.running = true
	end
end

function Boot:draw()
	love.graphics.clear(0.1, 0.1, 0.1)
	love.graphics.setColor(1, 1, 1)
	local w = 400
	local h = 20
	local x = love.graphics.getWidth() / 2 - w / 2
	local y = love.graphics.getHeight() / 2 - h / 2
	love.graphics.rectangle("line", x, y, w, h)
	love.graphics.rectangle("fill", x, y, w * self.progress, h)
	love.graphics.print("Loading: " .. math.floor(self.progress * 100) .. "%", x + w / 2 - 30, y - 25)
end

return Boot
