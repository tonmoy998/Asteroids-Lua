local Bar = {}
Bar.__index = Bar

function Bar:new(param)
	local obj = {
		x = param.x or 100,
		y = param.y or 100,
		w = param.w or 100,
		h = param.h or 30,
		max = param.max or 100,
		min = param.min or 0,
		current = param.current or 50,
		bg = param.bg or color.green,
		border = param.border or color.gray,
		percentage = param.percentage or 100,
	}
	setmetatable(obj, self)
	return obj
end

function Bar:load() end

function Bar:update(dt)
	self.percentage = math.floor((self.current / self.max) * 100)
end

function Bar:draw()
	--draw border
	love.graphics.setColor(self.border)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
	love.graphics.setColor(1, 1, 1)

	--fill color
	love.graphics.setColor(self.bg)
	love.graphics.rectangle("fill", self.x, self.y, self.percentage * (1 / 100) * self.w, self.h)
	love.graphics.setColor(1, 1, 1)
end

return Bar
