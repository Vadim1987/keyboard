-- keyboard: the program a 4-6 year-old launches to meet the
-- keyboard. One program: a typewriter intro, a mini-game menu,
-- and the mini-games. main.lua defines the LOVE callbacks once
-- and dispatches to the active scene after reserved-chord
-- handling; scenes are loaded once here at boot.

gfx = love.graphics

dofile("config.lua")
dofile("layout.lua")
dofile("sound.lua")
dofile("sequence.lua")
dofile("keyboard_view.lua")
dofile("indicators.lua")
dofile("notch.lua")
dofile("scene.lua")
dofile("input.lua")
dofile("intro.lua")
dofile("menu.lua")
dofile("choose.lua")

notchInit()
inputInit()
gotoScene("intro")

function love.update(dt)
  sceneUpdate(dt)
end

-- Draw in the 960x540 reference canvas, scaled uniformly and
-- centered to the real resolution. Nothing scrolls.
function love.draw()
  gfx.clear(COL_BG[1], COL_BG[2], COL_BG[3])
  local w, h = gfx.getDimensions()
  local s = math.min(w / REF_W, h / REF_H)
  gfx.push()
  gfx.translate((w - REF_W * s) / 2, (h - REF_H * s) / 2)
  gfx.scale(s, s)
  sceneDraw()
  gfx.pop()
end

function love.keypressed(k)
  appKeypressed(k)
end

function love.keyreleased(k)
  appKeyreleased(k)
end

function love.textinput(t)
  appTextinput(t)
end
