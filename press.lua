-- Press the key. The shared keyboard shows one key glowing
-- warm and pulsing; the child presses it. Round-gauge model
-- (gauge.lua): win a round to reach the advance screen; Tab
-- climbs a notch (advances at the top), Enter|R replays, and
-- it eases down on misses, with a per-notch pastel and pace.
-- The target is also drawn as a keycap in the top band.

PRESS = { pulse = 0, burst = nil, fw = { } }
PRESS_CFG = {
  id = "press",
  notch = PRESS_NOTCH,
  lo = PRESS_LO,
  hi = PRESS_HI
}

-- Firework spark colors: saturated, no red (blue, cyan, green,
-- violet, gold, magenta), for contrast over the light "Good
-- job!" overlay at a top-notch win.
FW_COLORS = {
  { 0.15, 0.55, 0.95 }, { 0.10, 0.72, 0.78 },
  { 0.20, 0.72, 0.35 }, { 0.60, 0.30, 0.90 },
  { 0.95, 0.62, 0.12 }, { 0.85, 0.28, 0.82 }
}

function pressEnter()
  PRESS.pulse = 0
  PRESS.burst = nil
  PRESS.fw = { }
  gaugeEnter(PRESS, PRESS_CFG)
end

function pressUpdate(dt)
  PRESS.pulse = PRESS.pulse + dt
  pressFwUpdate(dt)
  if PRESS.burst then
    PRESS.burst.t = PRESS.burst.t - dt
    if PRESS.burst.t <= 0 then PRESS.burst = nil end
  end
  gaugeTick(PRESS, PRESS_CFG, dt)
end

-- A round win plays win.ogg; a top-notch win plays wow.ogg and
-- launches the firework.
function pressCelebrate()
  if PRESS.event == "levelup" then
    SOUND.win()
  elseif PRESS.event == "win" then
    SOUND.wow()
    pressFwStart()
  end
end

function pressHit(k)
  local r = keyRect(k)
  if r then
    PRESS.burst = { x = r.x + r.w / 2,
      y = r.y + r.h / 2, t = 0.5 }
  end
  SOUND.match()
  gaugeOnCorrect(PRESS, PRESS_CFG)
  pressCelebrate()
end

function pressDone()
  return PRESS.phase == "done"
end

-- Play again from the advance screen: clear the firework and
-- start a fresh round at the current notch.
function pressReplay()
  PRESS.fw = { }
  PRESS.burst = nil
  gaugeReplay(PRESS, PRESS_CFG)
end

-- Tab on the advance screen: below the top notch, step up one
-- notch into a fresh round (the gate up); at the top, move to
-- the next game (or the menu when this is the last game).
function pressAdvance()
  PRESS.fw = { }
  PRESS.burst = nil
  if gaugeAtTop(PRESS_CFG) then
    cfAdvance("press")
  else
    gaugeOnNotch(PRESS, PRESS_CFG, 1)
  end
end

-- The Tab label: step up a level, or (at the top notch) the
-- next game / the menu when this is the last game.
function pressDoneTabLabel()
  if not gaugeAtTop(PRESS_CFG) then
    return STR.tab_level
  end
  if nextGameId("press") then
    return STR.tab_next
  end
  return STR.tab_menu
end

-- Advance-screen keys: Tab steps up (next game/menu at top);
-- Enter|R replays this notch.
function pressDoneKey(k)
  if k == "tab" then
    pressAdvance()
  elseif k == "return" or k == "kpenter" or k == "r" then
    pressReplay()
  end
end

function pressKeypressed(k)
  if pressDone() then
    pressDoneKey(k)
    return
  end
  if not gaugeGlowing(PRESS) then return end
  if k == gaugeCurrent(PRESS) then
    pressHit(k)
  elseif not isMod(k) and k ~= "capslock" then
    gaugeOnWrong(PRESS, PRESS_CFG)
  end
end

-- A teacher notch change that lands a fresh round also clears
-- scene-owned visuals (a firework/burst from a just-shown win
-- screen), which the gauge cannot reach.
function pressOnNotch(delta)
  local before = notchGet("press")
  gaugeOnNotch(PRESS, PRESS_CFG, delta)
  if notchGet("press") ~= before then
    PRESS.fw = { }
    PRESS.burst = nil
  end
end

function pressGlowDeco()
  local p = 0.5 + 0.5 * math.sin(PRESS.pulse * 2 * math.pi)
  return {
    bg = COL_WARM,
    glow = COL_GLOW,
    pulse = 1 + 0.06 * p
  }
end

-- Firework: colored sparks from a few burst points, launched
-- outward with gravity, fading out -- a top-notch win.
function pressFwSpark(cx, cy)
  local a = love.math.random() * 2 * math.pi
  local sp = 140 + love.math.random() * 220
  local life = 1.4 + love.math.random() * 1.0
  local i = love.math.random(1, #FW_COLORS)
  PRESS.fw[#PRESS.fw + 1] = {
    x = cx, y = cy,
    vx = math.cos(a) * sp,
    vy = math.sin(a) * sp - 120,
    life = life, max = life, col = FW_COLORS[i]
  }
end

function pressFwBurst(cx, cy)
  for i = 1, 22 do
    pressFwSpark(cx, cy)
  end
end

function pressFwStart()
  PRESS.fw = { }
  pressFwBurst(REF_W * 0.5, REF_H * 0.38)
  pressFwBurst(REF_W * 0.32, REF_H * 0.52)
  pressFwBurst(REF_W * 0.68, REF_H * 0.52)
end

function pressFwUpdate(dt)
  local keep = { }
  for _, p in ipairs(PRESS.fw) do
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.vy = p.vy + 180 * dt
    p.life = p.life - dt
    if p.life > 0 then keep[#keep + 1] = p end
  end
  PRESS.fw = keep
end

function pressDrawSpark(p)
  local a = p.life / p.max
  local c = p.col
  gfx.setColor(c[1], c[2], c[3], a * 0.35)
  gfx.circle("fill", p.x, p.y, 7)
  gfx.setColor(c[1], c[2], c[3], a)
  gfx.circle("fill", p.x, p.y, 4)
end

function pressDrawFw()
  for _, p in ipairs(PRESS.fw) do
    pressDrawSpark(p)
  end
end

-- Subtle exit affordance during play: a light chip behind dark
-- text so Shift+Esc stays legible over any pastel background.
function pressDrawExitHint()
  local font = getFont(FONT_HINT)
  local txt = STR.back_hint
  local y = REF_H - font:getHeight() - 8
  local w = font:getWidth(txt) + 12
  gfx.setColor(COL_KEY[1], COL_KEY[2], COL_KEY[3], 0.7)
  gfx.rectangle("fill", 6, y - 3, w, font:getHeight() + 6, 5)
  gfx.setFont(font)
  gfx.setColor(COL_TEXT)
  gfx.print(txt, 12, y)
end

function pressDraw()
  local glow = gaugeGlowing(PRESS)
  local done = pressDone()
  local deco = { }
  if glow then deco[gaugeCurrent(PRESS)] = pressGlowDeco() end
  drawKeyboard(deco)
  if glow then drawKeycapTarget(gaugeCurrent(PRESS)) end
  if PRESS.burst then drawBurst(PRESS.burst) end
  if not done then drawWinGauge(PRESS.covered, PRESS.total) end
  drawIndicators(CAPS_STATE.on)
  if done then cfDrawDoneScreen(pressDoneTabLabel()) end
  pressDrawFw()
  if not done then pressDrawExitHint() end
end

registerScene("press", {
  enter = pressEnter,
  update = pressUpdate,
  draw = pressDraw,
  keypressed = pressKeypressed,
  onNotch = pressOnNotch,
  noHint = pressDone
})
