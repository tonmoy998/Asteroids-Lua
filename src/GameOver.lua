local flux = require("lib.flux")

local GameOver = {}
GameOver.__index = GameOver

function GameOver:load()
	self.text = "Game Over"
	self.alpha = 0 -- screen opacity for blinking
	self.fadeIn = true -- controls direction of fade
	self.timer = 0
end

function GameOver:update(dt)
	flux.update(dt)

	-- Blinking effect (fade in and out continuously)
	self.timer = self.timer + dt
	if self.timer >= 1 then
		self.timer = 0
		self.fadeIn = not self.fadeIn
	end

	if self.fadeIn then
		flux.to(self, 1, { alpha = 1 })
	else
		flux.to(self, 1, { alpha = 0 })
	end
end

function GameOver:draw()
	love.graphics.setFont(_G.rasterB)

	-- Screen blink overlay
	love.graphics.setColor(1, 1, 1, self.alpha)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	-- Draw centered text
	local textW = _G.rasterB:getWidth(self.text)
	local textH = _G.rasterB:getHeight()
	local screenW = love.graphics.getWidth()
	local screenH = love.graphics.getHeight()
	local x = (screenW - textW) / 2
	local y = (screenH - textH) / 2

	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.print(self.text, x, y)
	love.graphics.setColor(1, 1, 1, 1)
end

return GameOver
