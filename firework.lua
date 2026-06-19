-- Shared celebration firework: colored sparks from a few burst
-- points, launched outward with gravity and fading out. Reused
-- by the find-key advance screen at a top-notch win. Operates
-- on a scene's own st.fw list, so each scene owns its sparks.

-- Saturated spark colors, no red (blue, cyan, green, violet,
-- gold, magenta), for contrast over the light "Good job!"
-- overlay at a top-notch win.
FW_COLORS = {
  { 0.15, 0.55, 0.95 }, { 0.10, 0.72, 0.78 },
  { 0.20, 0.72, 0.35 }, { 0.60, 0.30, 0.90 },
  { 0.95, 0.62, 0.12 }, { 0.85, 0.28, 0.82 }
}

function fwSpark(st, cx, cy)
  local a = love.math.random() * 2 * math.pi
  local sp = 140 + love.math.random() * 220
  local life = 1.4 + love.math.random() * 1.0
  local i = love.math.random(1, #FW_COLORS)
  st.fw[#st.fw + 1] = {
    x = cx, y = cy,
    vx = math.cos(a) * sp,
    vy = math.sin(a) * sp - 120,
    life = life, max = life, col = FW_COLORS[i]
  }
end

function fwBurst(st, cx, cy)
  for i = 1, 22 do
    fwSpark(st, cx, cy)
  end
end

function fwStart(st)
  st.fw = { }
  fwBurst(st, REF_W * 0.5, REF_H * 0.38)
  fwBurst(st, REF_W * 0.32, REF_H * 0.52)
  fwBurst(st, REF_W * 0.68, REF_H * 0.52)
end

function fwUpdate(st, dt)
  local keep = { }
  for _, p in ipairs(st.fw) do
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.vy = p.vy + 180 * dt
    p.life = p.life - dt
    if p.life > 0 then keep[#keep + 1] = p end
  end
  st.fw = keep
end

function fwDrawSpark(p)
  local a = p.life / p.max
  local c = p.col
  gfx.setColor(c[1], c[2], c[3], a * 0.35)
  gfx.circle("fill", p.x, p.y, 7)
  gfx.setColor(c[1], c[2], c[3], a)
  gfx.circle("fill", p.x, p.y, 4)
end

function fwDraw(st)
  for _, p in ipairs(st.fw) do
    fwDrawSpark(p)
  end
end
