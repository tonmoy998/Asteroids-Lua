_G.love = require("love")
local wf = require("lib.windfield.windfield")
require("lib.colorise")
local Camera = require("lib.hump.camera")

local debugging = true
local lg = love.graphics

local Player = require("src.Player")
local player = {}

local Bullet = require("src.Bullet")
local bullets = {}

local Asteroid = require("src.Asteroid")
local asteroids = {}

local Boot = require("src.boot")

local fire_timer = 0
local fire_rate = 0.1
_G.running = false
_G.state = "boot" -- menu ,boot , pause , restart
local level = 1

function love.load()
	if _G.state == "boot" then
		boot = Boot:new()
		boot:load()
	end
	-- camera = Camera(player.x, player.y)
	love.mouse.setVisible(false)
	love.window.setFullscreen(true)
	love.graphics.setDefaultFilter("nearest", "nearest")
	mouse_x, mouse_y = 0, 0
	world = wf.newWorld(0, 0, true)
	player = Player:new({
		x = 200,
		y = 100,
		world = world,
		speed = 180,
		particle_img = love.graphics.newImage("src/assets/smoke.png"),
		thrusting = true,
		color = color.cyan,
	})

	player.sound = love.audio.newSource("src/assets/shoot.mp3", "static")
	player.target = love.graphics.newImage("src/assets/target.png")
	targetOffset = 50
	player:load()
	-- world:addCollisionClass("Bullet", { ignores = { "Player" } })
	for i = 1, 10 do
		table.insert(
			asteroids,
			Asteroid:new({
				x = love.math.random(0, love.graphics.getWidth()),
				y = love.math.random(0, love.graphics.getHeight()),
				radius = love.math.random(25, 60),
				world = world,
				fill = "fill",
				color = color.darkgray,
			})
		)
	end
end

function love.update(dt)
	local lk = love.keyboard
	if lk.isDown("escape") then
		love.event.quit()
	end
	if _G.state == "boot" then
		boot:update(dt)
	end
	if wf and not _G.state == "boot" then
		_G.state = "running"
		_G.running = true
	end
	if not wf then
		_G.state = "boot"
		_G.running = false
	end
	if not player then
		_G.state = "boot"
		_G.running = false
	end
	if #asteroids < 0 then
		_G.state = "boot"
		_G.running = false
	end
	if _G.state == "running" and _G.running then
		mouse_x, mouse_y = love.mouse.getPosition()
		player:update(dt)
		world:update(dt)
		local dx, dy = 0, 0
		if lk.isDown("w") then
			dx = 0
			dy = -1
		elseif lk.isDown("s") then
			dx = 0
			dy = 1
		elseif lk.isDown("a") then
			dx = -1
			dy = 0
		elseif lk.isDown("d") then
			dy = 0
			dx = 1
		elseif lk.isDown("space") then
			local angle = math.atan2(mouse_y - player.body:getY(), mouse_x - player.body:getX())
			fire_timer = fire_timer + dt
			if fire_timer >= fire_rate then
				local bullet = Bullet:new({
					x = player.body:getX() + math.cos(player.angle) * player.radius,
					y = player.body:getY() + math.sin(player.angle) * player.radius,
					world = world,
					angle = angle,
					speed = 700,
					size = 5,
				})
				table.insert(bullets, bullet)
				player.sound:play()
				fire_timer = 0
			end
		end
		player:move(dx, dy)

		--Bullets
		for i = #bullets, 1, -1 do
			local b = bullets[i]
			b:update(dt)

			-- Remove bullets if out of screen
			local x, y = b.body:getPosition()
			if x < 0 or x > love.graphics.getWidth() or y < 0 or y > love.graphics.getHeight() then
				-- b.body:destroy()
				b:destroy()
				table.remove(bullets, i)
			end

			if b.body:enter("Asteroid") then
				b:destroy()
				table.remove(bullets, i)
			end
		end

		--Asteroids
		for i, a in ipairs(asteroids) do
			a:update(dt)
			if a.health <= 0 then
				a:destroy()
				table.remove(asteroids, i)
			end
		end

		--camera
		if camera then
			local cx, cy = player.x - camera.x, player.y - camera.y
			camera:move(cx / 2, cy / 2)
		end
	end
end

function love.draw()
	if _G.state == "running" and _G.running then
		if camera then
			camera:attach()
			player:draw()
			world:draw()
			for _, b in ipairs(bullets) do
				b:draw(color.red)
			end
			love.graphics.print(#bullets, 20, 20)
			for _, a in ipairs(asteroids) do
				a:draw()
			end
			camera:detach()
		else
			player:draw()
			if debugging then
				world:draw()
				love.graphics.setColor(color.green)
				love.graphics.rectangle("line", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
				love.graphics.setColor(1, 1, 1)
			end
			for _, b in ipairs(bullets) do
				b:draw(color.red)
			end
			love.graphics.print(#bullets, 20, 20)
			for _, a in ipairs(asteroids) do
				if a then
					a:draw()
				end
			end
			love.graphics.print(lg.getWidth() .. "x" .. lg.getHeight(), 100, 10)
			love.graphics.setColor(color.white)
			love.graphics.draw(player.target, mouse_x - targetOffset, mouse_y - targetOffset, nil, 0.5, 0.5)
			love.graphics.setColor(1, 1, 1)

			local fps = math.floor(love.timer.getFPS())
			love.graphics.print(fps, 40, 40)

			-- love.graphics.print(asteroids[1].health, 70, 70)
			love.graphics.print(#asteroids, 70, 70)
		end
	end
	if _G.state == "boot" and not _G.running then
		boot:draw()
	end
end
