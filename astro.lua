-- astro.lua

-- Asteroids. Caps ride rocks falling from the top, scattered
-- across the width rather than lined up, and the ship below
-- shoots the one whose key is pressed. Order is free: a press
-- takes any rock still standing, a stray key is a blank shot.
--
-- The gun reloads after EVERY shot and nothing fires while it
-- does, so the game cannot be won by hammering every key. A
-- blank costs longer than a hit, which turns hammering into a
-- permanent reload and makes looking first the cheaper move.
-- The charge shows on the ship as three lamps and a glow, so it
-- is read without words.
--
-- The wave, the gauge, the promote, the progression and the
-- teacher speed are the falling-caps engine's (huntcore.lua).
-- This file owns the scatter, the gun and the scene.

ensureFile("huntcore.lua")
ensureFile("props.lua")

ASTRO_SCENE = { id = "astro", lo = -2, hi = 2, forbid = false,
  ramp = SPACE_RAMP }

-- charge: seconds left before the gun is ready; full: how long
-- the current reload runs, so the lamps fill over it. bolt: the
-- rock being hit and how long the beam still shows. shake: the
-- ship recoiling from a rock that got through.

GUN = { charge = 0, full = ASTRO_RELOAD_HIT, bolt = nil,
  bursts = { }, shake = 0 }

ASTRO_ROCK_R = HUNT_CAP_W * 0.82
ASTRO_ROCK_D = ASTRO_ROCK_R * 2
ASTRO_ROCK_INSET = (ASTRO_ROCK_D - HUNT_CAP_W) / 2
ASTRO_SHIP_Y = ASTRO_GROUND_Y - 4 * ASTRO_SHIP_U

function astroEnter()
  GUN.charge = 0
  GUN.full = ASTRO_RELOAD_HIT
  GUN.bolt = nil
  GUN.bursts = { }
  GUN.shake = 0
  huntEnter(ASTRO_SCENE)
end

-- Rocks are spread one to a sector so they never overlap, and
-- the offset inside a sector comes from the wave count, so each
-- wave falls in its own arrangement. The sector holds the ROCK,
-- which is wider than the cap riding it -- spacing them by cap
-- width would let neighbouring rocks touch.

function astroCapX(i, n)
  local span = (REF_W - 2 * ASTRO_MARGIN) / n
  local jitter = (math.sin(HUNT.count * 3 + i) + 1) / 2
  return ASTRO_MARGIN + (i - 1) * span
    + jitter * (span - ASTRO_ROCK_D) + ASTRO_ROCK_INSET
end

function astroReady()
  return GUN.charge <= 0
end

function astroChargeFrac()
  return 1 - GUN.charge / GUN.full
end

-- Every shot starts a reload; a blank one runs longer.

function astroReload(time)
  GUN.charge = time
  GUN.full = time
end

-- The beam aims at where the rock stood when the trigger went,
-- not at where the wave has drifted to since, so it always
-- points at the rock it struck.

function astroShoot(i)
  local cell = astroCapCell(i, #HUNT.chars)
  GUN.bolt = {
    x = cell.x + HUNT_CAP_W / 2,
    y = cell.y + HUNT_CAP / 2,
    t = ASTRO_BOLT_T
  }
  astroReload(ASTRO_RELOAD_HIT)
end

function astroBlank()
  astroReload(ASTRO_RELOAD_MISS)
end

function astroKeypressed(k)
  if huntDone() then
    huntDoneKey(k)
    return
  end
  if HUNT.phase ~= "fall" then return end
  if not astroReady() then return end
  local i = huntFindCap(k)
  if i then
    astroShoot(i)
    huntTypeCap(i, k)
  elseif not isMod(k) and k ~= "capslock" then
    astroBlank()
    huntWrongPress(k)
  end
end

-- A wave that lands is a breach of the line, not a blow to the
-- saucer: rocks come down across the whole width and only one
-- near the middle could ever strike it. Every rock still
-- standing bursts where it crossed, and the ship rocks from the
-- shock of the line giving way.

function astroBurstAt(i, n)
  local cell = astroCapCell(i, n)
  GUN.bursts[#GUN.bursts + 1] = {
    x = cell.x + HUNT_CAP_W / 2,
    y = cell.y + HUNT_CAP / 2,
    t = BANG_T
  }
end

function astroBreach()
  local n = #HUNT.chars
  for i = 1, n do
    if not HUNT.done[i] then astroBurstAt(i, n) end
  end
  GUN.shake = ASTRO_SHAKE_T
end

function astroTickBursts(dt)
  for i = #GUN.bursts, 1, -1 do
    local b = GUN.bursts[i]
    b.t = b.t - dt
    if b.t <= 0 then table.remove(GUN.bursts, i) end
  end
end

function astroTickGun(dt)
  GUN.charge = math.max(0, GUN.charge - dt)
  GUN.shake = math.max(0, GUN.shake - dt)
  if not GUN.bolt then return end
  GUN.bolt.t = GUN.bolt.t - dt
  if GUN.bolt.t <= 0 then GUN.bolt = nil end
end

-- A rock reaching the ship shoves it; the engine has already
-- booked the miss, so this only reacts to the phase turning.

function astroUpdate(dt)
  local was = HUNT.phase
  huntUpdate(dt)
  if was == "fall" and HUNT.phase == "missed" then
    astroBreach()
  end
  astroTickGun(dt)
  astroTickBursts(dt)
end

function astroOnNotch(delta)
  GUN.bolt = nil
  GUN.bursts = { }
  huntOnNotch(delta)
end

function astroDone()
  return huntDone()
end

-- Drawing

function astroShipX()
  local p = GUN.shake / ASTRO_SHAKE_T
  return REF_W / 2 + math.sin(p * 24) * p * ASTRO_SHAKE_PX
end

function astroCapCell(i, n)
  return {
    x = astroCapX(i, n),
    y = HUNT.y - HUNT_CAP / 2,
    w = HUNT_CAP_W,
    h = HUNT_CAP
  }
end

-- A rock with its cap on top. The rock is drawn from the cap's
-- centre, so the two travel as one.

function astroDrawRock(i, ch, n)
  local cell = astroCapCell(i, n)
  drawRock(cell.x + HUNT_CAP_W / 2, cell.y + HUNT_CAP / 2,
    ASTRO_ROCK_R, i * 2.1)
  drawKeycap(cell, {
    name = ch,
    unit = HUNT_CAP / KB_STD_H,
    color = huntCapColor(i)
  })
end

function astroDrawWave()
  local n = #HUNT.chars
  for i, ch in ipairs(HUNT.chars) do
    if not HUNT.done[i] then astroDrawRock(i, ch, n) end
  end
end

-- The beam from the ship to the rock it struck.

function astroDrawBolt(sx)
  gfx.setColor(BOLT[1], BOLT[2], BOLT[3],
    GUN.bolt.t / ASTRO_BOLT_T)
  gfx.setLineWidth(4)
  gfx.line(sx, ASTRO_SHIP_Y, GUN.bolt.x, GUN.bolt.y)
  gfx.setLineWidth(1)
end

function astroDrawBursts()
  for _, b in ipairs(GUN.bursts) do
    drawBang(b)
  end
end

function astroDrawShip(sx)
  local frac = astroChargeFrac()
  drawCharge(sx, ASTRO_SHIP_Y, ASTRO_SHIP_U, frac)
  drawShip(sx, ASTRO_SHIP_Y, ASTRO_SHIP_U, frac)
end

-- The recoil offset is worked out once and handed to both the
-- ship and the beam, so the two cannot drift apart.

function astroDrawScene()
  local sx = astroShipX()
  drawStars(REF_W, REF_H, ASTRO_STARS)
  astroDrawWave()
  astroDrawBursts()
  if GUN.bolt then astroDrawBolt(sx) end
  astroDrawShip(sx)
end

function astroDraw()
  if astroDone() then
    fkDrawDoneScreen()
    fwDraw(HUNT)
    return
  end
  astroDrawScene()
  drawWinGauge(HUNT.g, huntCfg().promote)
  fwDraw(HUNT)
  fkDrawExitHint()
end

registerScene("astro", {
  enter = astroEnter,
  update = astroUpdate,
  draw = astroDraw,
  keypressed = astroKeypressed,
  onNotch = astroOnNotch,
  noHint = astroDone
})
