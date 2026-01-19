local Bar = require("src.Progressbar")
local Boot = {}
Boot.__index = Boot

function Boot:new(param)
	local obj = {
		x = param.x or 100,
		y = param.y or 100,
		w = param.w or 100,
		h = param.h or 50,
		max = param.max or 100,
		min = param.min or 0,
		text = param.text or "Loading...",
		bg = param.bg or color.green,
	}
	setmetatable(obj, self)
	return obj
end

function Boot:load()
	bar = Bar:new({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		current = self.current or 0,
		bg = self.bg,
	})
	_G.rasterB = love.graphics.newFont("src/assets/RasterForgeRegular-JpBgm.ttf", 50)
	_G.rasterR = love.graphics.newFont("src/assets/RasterForgeRegular-JpBgm.ttf", 14)
	textW = _G.rasterB:getWidth(self.text)
	textH = _G.rasterB:getHeight(self.text)
end

function Boot:update(dt)
	bar.current = bar.current + (dt * 50)
	bar:update(dt)
	if bar.current >= 100 then
		_G.state = "running"
		_G.running = true
	end
end

function Boot:draw()
	bar:draw()
	-- love.graphics.print(love.graphics.getDimensions(), 50, 50)
	love.graphics.setFont(_G.rasterB)
	love.graphics.print(self.text, self.x + (self.w / 2) - (textW / 2), self.y - (textH + 30))
	love.graphics.setFont(_G.rasterR)
end

return Boot
