-- Mini-game 1: Choose the same key. One key glows warm and
-- pulses; only that key is accepted, every other key is
-- silently ignored. Correct -> warm chime + burst + a calm
-- pause, then the next key in the shared sequence. Teacher-only
-- asymmetric notches (-2, -1, 0); no auto-match.

CHOOSE = {
  phase = "glow",
  pause = 0,
  pulse = 0,
  burst = nil,
  notch_dirty = false,
  done_t = 0
}

function chooseEnter()
  seqResetCF(notchGet("choose"))
  CHOOSE.phase = "glow"
  CHOOSE.pause = 0
  CHOOSE.pulse = 0
  CHOOSE.burst = nil
  CHOOSE.notch_dirty = false
  CHOOSE.done_t = 0
end

function chooseRebuild()
  seqResetCF(notchGet("choose"))
  CHOOSE.phase = "glow"
  CHOOSE.notch_dirty = false
end

-- A notch change rebuilds the sequence for the new groups but
-- preserves the found count (it is not lost progress).
function chooseApplyNotch()
  local keep = SEQ.found
  chooseRebuild()
  SEQ.found = keep
end

function chooseTickPause(dt)
  CHOOSE.pause = CHOOSE.pause - dt
  if CHOOSE.pause > 0 then return end
  if CHOOSE.notch_dirty then
    chooseApplyNotch()
  elseif seqAtEnd() then
    CHOOSE.phase = "done"
    CHOOSE.done_t = 2.0
  else
    SEQ.idx = SEQ.idx + 1
    CHOOSE.phase = "glow"
  end
end

function chooseTickDone(dt)
  CHOOSE.done_t = CHOOSE.done_t - dt
  if CHOOSE.done_t <= 0 then
    chooseRebuild()
  end
end

function chooseUpdate(dt)
  CHOOSE.pulse = CHOOSE.pulse + dt
  if CHOOSE.burst then
    CHOOSE.burst.t = CHOOSE.burst.t - dt
    if CHOOSE.burst.t <= 0 then CHOOSE.burst = nil end
  end
  if CHOOSE.phase == "pause" then
    chooseTickPause(dt)
  elseif CHOOSE.phase == "done" then
    chooseTickDone(dt)
  end
end

function chooseHit(k)
  SEQ.found = SEQ.found + 1
  local r = keyRect(k)
  CHOOSE.burst = {
    x = r.x + r.w / 2,
    y = r.y + r.h / 2,
    t = 0.5
  }
  SOUND.correct()
  CHOOSE.phase = "pause"
  CHOOSE.pause = CF_NOTCH[notchGet("choose")].pause
end

function chooseKeypressed(k)
  if CHOOSE.phase ~= "glow" then return end
  if k == seqCurrent() then
    chooseHit(k)
  end
end

-- Only a notch that actually changes marks the sequence dirty;
-- a saturated chord at the bounds must not reset progress.
function chooseOnNotch(delta)
  local old = notchGet("choose")
  if notchShift("choose", delta, -2, 0) ~= old then
    CHOOSE.notch_dirty = true
  end
end

function chooseGlowDeco()
  local p = 0.5 + 0.5 * math.sin(CHOOSE.pulse * 2 * math.pi)
  return {
    bg = COL_WARM,
    glow = COL_GLOW,
    pulse = 1 + 0.06 * p
  }
end

function chooseDrawStatus()
  local txt = "Found: " .. SEQ.found
  if CHOOSE.phase == "done" then
    txt = "Well done!    " .. SEQ.found
  end
  gfx.setFont(UIFONT.status)
  gfx.setColor(COL_DIM)
  gfx.printf(txt, 40, STATUS_Y0 + 4, 360, "left")
end

function chooseDraw()
  local deco = { }
  if CHOOSE.phase == "glow" then
    deco[seqCurrent()] = chooseGlowDeco()
  end
  drawKeyboard(deco)
  if CHOOSE.burst then drawBurst(CHOOSE.burst) end
  drawIndicators(CAPS_STATE.on)
  chooseDrawStatus()
end

registerScene("choose", {
  enter = chooseEnter,
  update = chooseUpdate,
  draw = chooseDraw,
  keypressed = chooseKeypressed,
  onNotch = chooseOnNotch
})
