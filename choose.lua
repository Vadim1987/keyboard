-- Mini-game 1: Choose the same key. The shared keyboard is
-- shown with one key glowing warm and pulsing; the child
-- presses it. The logic is the shared mastery core
-- (cfcore.lua); this file adds only the glowing-key view.
-- Teacher-only asymmetric notches (-2, -1, 0).

CHOOSE = {
  phase = "glow",
  pause = 0,
  pulse = 0,
  burst = nil,
  notch_dirty = false,
  clean = true
}

function chooseEnter()
  cfEnter(CHOOSE, "choose")
end

function chooseUpdate(dt)
  cfUpdate(CHOOSE, "choose", dt)
end

function chooseKeypressed(k)
  cfKeypressed(CHOOSE, "choose", k)
end

function chooseOnNotch(delta)
  cfOnNotch(CHOOSE, "choose", delta)
end

function chooseDone()
  return cfDone(CHOOSE)
end

function chooseGlowDeco()
  local p = 0.5 + 0.5 * math.sin(CHOOSE.pulse * 2 * math.pi)
  return {
    bg = COL_WARM,
    glow = COL_GLOW,
    pulse = 1 + 0.06 * p
  }
end

function chooseDraw()
  local deco = { }
  if CHOOSE.phase == "glow" then
    deco[seqCurrent()] = chooseGlowDeco()
  end
  drawKeyboard(deco)
  if CHOOSE.burst then drawBurst(CHOOSE.burst) end
  drawIndicators(CAPS_STATE.on)
  if chooseDone() then cfDrawDone("choose") end
end

registerScene("choose", {
  enter = chooseEnter,
  update = chooseUpdate,
  draw = chooseDraw,
  keypressed = chooseKeypressed,
  onNotch = chooseOnNotch,
  noHint = chooseDone
})
