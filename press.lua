-- Press the key. The shared keyboard shows one key glowing warm
-- and pulsing; the child presses it. Round-gauge model
-- (gauge.lua) driven by the shared find-key scene core
-- (findkey.lua): win a round to reach the advance screen; Tab
-- climbs a notch (advances at the top), Enter|R replays, and it
-- eases down on misses, with a per-notch pastel and pace. The
-- target is also drawn as a keycap in the top band. This scene
-- adds only the glowing target key over the shared core.

PRESS = { pulse = 0, burst = nil, fw = { } }
PRESS_CFG = {
  id = "press",
  notch = PRESS_NOTCH,
  lo = PRESS_LO,
  hi = PRESS_HI
}

function pressEnter()
  fkEnter(PRESS, PRESS_CFG)
end

function pressUpdate(dt)
  fkUpdate(PRESS, PRESS_CFG, dt)
end

function pressKeypressed(k)
  fkKeypressed(PRESS, PRESS_CFG, k)
end

function pressOnNotch(delta)
  fkOnNotch(PRESS, PRESS_CFG, delta)
end

function pressDone()
  return fkDone(PRESS)
end

-- The warm pulsing glow on the target key (Press's one visual
-- addition over the shared core).
function pressGlowDeco()
  local p = 0.5 + 0.5 * math.sin(PRESS.pulse * 2 * math.pi)
  return {
    bg = COL_WARM,
    glow = COL_GLOW,
    pulse = 1 + 0.06 * p
  }
end

function pressDraw()
  local deco = { }
  if gaugeGlowing(PRESS) then
    deco[gaugeCurrent(PRESS)] = pressGlowDeco()
  end
  fkDraw(PRESS, PRESS_CFG, deco)
end

registerScene("press", {
  enter = pressEnter,
  update = pressUpdate,
  draw = pressDraw,
  keypressed = pressKeypressed,
  onNotch = pressOnNotch,
  noHint = pressDone
})
