-- keyboard: the program a 4-6 year-old launches to meet the
-- keyboard. One program: a typewriter intro, a mini-game menu,
-- and the mini-games. main.lua defines the LOVE callbacks once
-- and dispatches to the active scene after reserved-chord
-- handling; scenes are loaded once here at boot.

gfx = love.graphics

-- Shared infrastructure plus the two scenes needed at boot
-- (intro, menu). Mini-games are lazy-loaded on first entry.
dofile("config.lua")
dofile("locale.lua")
dofile("layout.lua")
dofile("sound.lua")
dofile("sequence.lua")
dofile("keyboard_view.lua")
dofile("indicators.lua")
dofile("notch.lua")
dofile("scene.lua")
dofile("input.lua")
dofile("help.lua")
dofile("cfcore.lua")
dofile("huntadapt.lua")
dofile("intro.lua")
dofile("menu.lua")

-- Games present in this build (lazy-loaded). Adding a slice
-- registers its file here; the menu picks it up structurally.
SCENE_FILE.choose = "choose.lua"
SCENE_FILE.find = "find.lua"
SCENE_FILE.hunt = "hunt.lua"

notchInit()
inputInit()
gotoScene("intro")

function love.update(dt)
  -- An open help overlay pauses the active game; it resumes
  -- when dismissed (docs/compy-ux-principles.md).
  if helpOverlayShown() then return end
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
  drawHelpLayer()
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
