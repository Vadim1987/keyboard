-- props.lua

-- Scenery and props for the games that play on a scene rather
-- than on the keyboard picture. Everything is drawn from
-- primitives: no image assets, so a prop scales to any size,
-- takes its colors from the palette, and costs a handful of
-- draw calls. Shared by Hide and, later, Train and Asteroids.

-- A prop is placed by its bottom-left corner and sized by a
-- unit u, so a caller states position and scale in one call.

-- A scene paints its own sky: the gauge has just set the chrome
-- pastel for the level, and this replaces it with the matching
-- sky. Call it after entering and after a notch change.

function skyLevel(cfg)
  pastelSetTarget(SKY_RAMP[notchGet(cfg.id) - cfg.lo])
end

-- Rolling hills along the ground line: three flattened
-- ellipses, widest first, so the band reads as depth.

function drawHills(w, y)
  gfx.setColor(HILL[1], HILL[2], HILL[3])
  gfx.ellipse("fill", w * 0.25, y, w * 0.3, 34)
  gfx.ellipse("fill", w * 0.62, y, w * 0.26, 26)
  gfx.ellipse("fill", w * 0.88, y, w * 0.22, 30)
end

-- Meadow: hills along the horizon and a ground strip. The sky
-- is left to the pastel background main already paints, so the
-- level still colors the scene and nothing is filled twice.

function drawMeadow(w, h, groundY)
  drawHills(w, groundY)
  gfx.setColor(GROUND[1], GROUND[2], GROUND[3])
  gfx.rectangle("fill", 0, groundY, w, h - groundY)
end

-- Crate planks: the darker boards over the body. Drawn as one
-- helper so the crate itself stays a short block.

function crateBoards(x, y, u)
  gfx.setColor(WOOD_DARK[1], WOOD_DARK[2], WOOD_DARK[3])
  gfx.rectangle("fill", x, y - 10 * u,
    10 * u, 1.3 * u, 0.5 * u)
  gfx.rectangle("fill", x, y - 5.6 * u, 10 * u, 1 * u)
  gfx.rectangle("fill", x, y - 1.3 * u,
    10 * u, 1.3 * u, 0.5 * u)
  gfx.rectangle("fill", x + 4.2 * u, y - 8.7 * u,
    1.6 * u, 3.1 * u)
  gfx.rectangle("fill", x + 4.2 * u, y - 4.6 * u,
    1.6 * u, 3.3 * u)
end

-- A crate, 10u square, standing on (x, y). Its right edge is
-- straight, which is what a cap slides out from behind.

function drawCrate(x, y, u)
  gfx.setColor(WOOD[1], WOOD[2], WOOD[3])
  gfx.rectangle("fill", x, y - 10 * u, 10 * u, 10 * u, 0.5 * u)
  crateBoards(x, y, u)
end

-- A wheel: dark tyre with a light hub.

function propWheel(x, y, r)
  gfx.setColor(IRON[1], IRON[2], IRON[3])
  gfx.circle("fill", x, y, r)
  gfx.setColor(HUB[1], HUB[2], HUB[3])
  gfx.circle("fill", x, y, r * 0.45)
end

-- Track: two rails over evenly spaced sleepers, drawn across a
-- width from (x, y) at the rail top.

function drawSleepers(x, y, w)
  gfx.setColor(SLEEPER[1], SLEEPER[2], SLEEPER[3])
  for i = 0, math.floor(w / SLEEPER_GAP) do
    gfx.rectangle("fill", x + i * SLEEPER_GAP, y,
      SLEEPER_GAP * 0.4, 9, 1)
  end
end

function drawTrack(x, y, w)
  drawSleepers(x, y + 2, w)
  gfx.setColor(RAIL[1], RAIL[2], RAIL[3])
  gfx.rectangle("fill", x, y, w, 3)
  gfx.rectangle("fill", x, y + 9, w, 3)
end

-- Locomotive, 20u long and 11u tall, standing on (x, y).

function locoBoiler(x, y, u)
  gfx.setColor(BOILER[1], BOILER[2], BOILER[3])
  gfx.rectangle("fill", x + 2 * u, y - 7.5 * u,
    10.4 * u, 4.1 * u, 0.6 * u)
  gfx.setColor(IRON[1], IRON[2], IRON[3])
  gfx.rectangle("fill", x + 0.8 * u, y - 6.2 * u,
    1.4 * u, 2.8 * u, 0.3 * u)
end

function locoCab(x, y, u)
  gfx.setColor(CAB[1], CAB[2], CAB[3])
  gfx.rectangle("fill", x + 11.8 * u, y - 10 * u,
    5.8 * u, 6.6 * u, 0.5 * u)
  gfx.setColor(CAB_GLASS[1], CAB_GLASS[2], CAB_GLASS[3])
  gfx.rectangle("fill", x + 13 * u, y - 8.8 * u,
    3.2 * u, 2.7 * u, 0.3 * u)
end

function locoStack(x, y, u)
  gfx.setColor(IRON[1], IRON[2], IRON[3])
  gfx.rectangle("fill", x + 3.6 * u, y - 10.2 * u,
    2.2 * u, 3 * u, 0.3 * u)
  gfx.rectangle("fill", x + 3 * u, y - 10.8 * u,
    3.4 * u, 1.1 * u, 0.4 * u)
end

function drawLoco(x, y, u)
  gfx.setColor(IRON[1], IRON[2], IRON[3])
  gfx.rectangle("fill", x + 1.4 * u, y - 3.4 * u,
    16.8 * u, 0.9 * u)
  locoBoiler(x, y, u)
  locoCab(x, y, u)
  locoStack(x, y, u)
  propWheel(x + 14.6 * u, y - 2 * u, 1.8 * u)
  propWheel(x + 5.2 * u, y - 1.8 * u, 1.3 * u)
  propWheel(x + 9.2 * u, y - 1.8 * u, 1.3 * u)
end

-- Flat car, 16u long: a clear deck with low end posts, so a
-- cap set on it reads as cargo.

function drawCar(x, y, u)
  gfx.setColor(IRON[1], IRON[2], IRON[3])
  gfx.rectangle("fill", x + 1.2 * u, y - 3.4 * u,
    13.6 * u, 0.9 * u)
  gfx.setColor(WOOD[1], WOOD[2], WOOD[3])
  gfx.rectangle("fill", x + 1.4 * u, y - 5.2 * u,
    13.2 * u, 1.8 * u, 0.3 * u)
  gfx.setColor(WOOD_DARK[1], WOOD_DARK[2], WOOD_DARK[3])
  gfx.rectangle("fill", x + 1.4 * u, y - 6.8 * u,
    0.9 * u, 1.8 * u, 0.2 * u)
  gfx.rectangle("fill", x + 13.7 * u, y - 6.8 * u,
    0.9 * u, 1.8 * u, 0.2 * u)
  propWheel(x + 4.4 * u, y - 2 * u, 1.3 * u)
  propWheel(x + 11.6 * u, y - 2 * u, 1.3 * u)
end

-- Smoke puffs drifting up and back from the stack. t is the
-- caller's own clock, so the plume never resets.

function smokePuff(x, y, i, t)
  local p = (t * 0.6 + i * 0.33) % 1
  gfx.setColor(SMOKE[1], SMOKE[2], SMOKE[3], 1 - p)
  gfx.circle("fill", x - p * 26, y - p * 40, 3 + p * 9)
end

function drawSmoke(x, y, t)
  for i = 1, 4 do
    smokePuff(x, y, i, t)
  end
end

-- Star field: positions come from the index alone, so the sky
-- is fixed and never shimmers between frames.

function starAt(i, w, h)
  return (i * 73.7) % w, (i * 41.3) % (h * 0.8)
end

function drawStars(w, h, n)
  gfx.setColor(STAR[1], STAR[2], STAR[3])
  for i = 1, n do
    local x, y = starAt(i, w, h)
    gfx.circle("fill", x, y, (i % 3) * 0.4 + 0.7)
  end
end

-- An asteroid: an eight-point polygon whose radii are jittered
-- from a seed, so every rock has its own outline. The lit core
-- is left plain, which is what a cap sits on.

function rockPoints(cx, cy, r, seed)
  local pts = { }
  for i = 0, 7 do
    local a = i * math.pi / 4
    local j = 1 + 0.18 * math.sin(seed + i * 2.4)
    pts[#pts + 1] = cx + math.cos(a) * r * j
    pts[#pts + 1] = cy + math.sin(a) * r * j
  end
  return pts
end

function drawRock(cx, cy, r, seed)
  gfx.setColor(ROCK[1], ROCK[2], ROCK[3])
  gfx.polygon("fill", rockPoints(cx, cy, r, seed))
  gfx.setColor(ROCK_LIT[1], ROCK_LIT[2], ROCK_LIT[3])
  gfx.polygon("fill", rockPoints(cx, cy, r * 0.72, seed))
end

-- The saucer's three lamps ARE the charge meter: they go out on
-- a shot and light again one by one, so a child sees at a
-- glance whether the gun is ready. frac is 0 to 1.

SHIP_LAMPS = 3

function shipLamp(cx, cy, u, i)
  gfx.circle("fill", cx + (i - 2) * 5.5 * u,
    cy + ((i == 2) and 1 or 0.5) * u, 0.75 * u)
end

function shipLamps(cx, cy, u, frac)
  for i = 1, SHIP_LAMPS do
    if frac >= i / SHIP_LAMPS then
      gfx.setColor(LAMP[1], LAMP[2], LAMP[3])
    else
      gfx.setColor(LAMP_OFF[1], LAMP_OFF[2], LAMP_OFF[3])
    end
    shipLamp(cx, cy, u, i)
  end
end

function drawShip(cx, cy, u, frac)
  gfx.setColor(HULL[1], HULL[2], HULL[3])
  gfx.ellipse("fill", cx, cy, 8 * u, 2.2 * u)
  gfx.setColor(DOME[1], DOME[2], DOME[3])
  gfx.ellipse("fill", cx, cy - 2.4 * u, 3.2 * u, 2.4 * u)
  shipLamps(cx, cy, u, frac)
end

-- The charge glow under the hull brightens with the lamps, so
-- readiness reads as brightness as well as a count. Rings are
-- drawn outward first, so the faintest sits behind.

CHARGE_RINGS = 3

function drawCharge(cx, cy, u, frac)
  for i = CHARGE_RINGS, 1, -1 do
    gfx.setColor(DOME[1], DOME[2], DOME[3],
      frac * 0.3 * (1 - (i - 1) / CHARGE_RINGS))
    gfx.ellipse("fill", cx, cy, (8 + i * 1.6) * u,
      (2.2 + i * 1.1) * u)
  end
end
