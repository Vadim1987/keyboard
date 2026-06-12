-- keyboard: the program a 4-6 year-old launches to meet the
-- keyboard. One program: a typewriter intro, a mini-game menu,
-- and the mini-games. main.lua defines the LOVE callbacks once
-- and dispatches to the active scene after reserved-chord
-- handling; scenes are loaded once here at boot.

gfx = love.graphics

-- Debug logging. When DEBUG is on, diagnostics go to a log file
-- in the save dir (read via adb), not an on-screen overlay.
-- update/draw also run under pcall, so a thrown frame is logged
-- and recovered (the outer gfx.pop still runs, no stack leak)
-- instead of freezing or crashing, so the app stays runnable
-- while the problem is captured. Set DEBUG = false to ship.
DEBUG = false
DBG_LOG = "keyboard-debug.log"
DBG_FRAME = 0
DBG_LASTERR = nil

function dbgLog(msg)
  if not DEBUG then return end
  local line = DBG_FRAME .. " " .. msg
  print("[KBD] " .. line)
  pcall(love.filesystem.append, DBG_LOG, line .. "\n")
end

-- Log a thrown error once (deduped) so a per-frame throw does
-- not spam the log.
function dbgLogErr(where, err)
  if err == DBG_LASTERR then return end
  DBG_LASTERR = err
  dbgLog(where .. " ERR @ " .. tostring(ACTIVE)
    .. ": " .. tostring(err))
end

-- Reset the log + record the save dir (pcall'd at boot so a
-- restricted filesystem can never block startup).
function dbgBoot()
  love.filesystem.write(DBG_LOG, "=== boot ===\n")
  dbgLog("save dir " .. love.filesystem.getSaveDirectory())
end

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
SCENE_FILE.caps = "caps.lua"
SCENE_FILE.shift_caps = "shift_caps.lua"
SCENE_FILE.shift_symbols = "shift_symbols.lua"

notchInit()
inputInit()
if DEBUG then pcall(dbgBoot) end
gotoScene("intro")

function updateStep(dt)
  -- An open help overlay pauses the active game; it resumes
  -- when dismissed (docs/compy-ux-principles.md).
  if helpOverlayShown() then return end
  sceneUpdate(dt)
end

function love.update(dt)
  DBG_FRAME = DBG_FRAME + 1
  if not DEBUG then return updateStep(dt) end
  local ok, err = pcall(updateStep, dt)
  if not ok then dbgLogErr("UPDATE", err) end
end

-- Draw in the 960x540 reference canvas, scaled uniformly and
-- centered to the real resolution. Nothing scrolls.
function drawStep()
  sceneDraw()
  drawHelpLayer()
end

function love.draw()
  gfx.clear(COL_BG[1], COL_BG[2], COL_BG[3])
  local w, h = gfx.getDimensions()
  local s = math.min(w / REF_W, h / REF_H)
  gfx.push()
  gfx.translate((w - REF_W * s) / 2, (h - REF_H * s) / 2)
  gfx.scale(s, s)
  if not DEBUG then
    drawStep()
  else
    local ok, err = pcall(drawStep)
    if not ok then dbgLogErr("DRAW", err) end
  end
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
