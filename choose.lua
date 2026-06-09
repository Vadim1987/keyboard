-- Mini-game 1: Choose the same key. One key glows warm and
-- pulses; only that key is accepted, every other key is
-- silently ignored. Correct -> warm chime + burst + a calm
-- pause, then the next key. A key pressed on the FIRST try
-- clears; pressed after any wrong key, it quietly returns to
-- the pool to come round again later (a mastery loop, invisible
-- to the child). Finishing (pool empty) shows a Good job!
-- screen. Teacher-only asymmetric notches (-2, -1, 0).

CHOOSE = {
  phase = "glow",
  pause = 0,
  pulse = 0,
  burst = nil,
  notch_dirty = false,
  clean = true
}

function chooseEnter()
  seqResetCF(notchGet("choose"))
  CHOOSE.phase = "glow"
  CHOOSE.pause = 0
  CHOOSE.pulse = 0
  CHOOSE.burst = nil
  CHOOSE.notch_dirty = false
  CHOOSE.clean = true
end

function chooseRebuild()
  seqResetCF(notchGet("choose"))
  CHOOSE.phase = "glow"
  CHOOSE.notch_dirty = false
  CHOOSE.clean = true
end

-- A notch change rebuilds the sequence for the new groups but
-- preserves the found count (it is not lost progress).
function chooseApplyNotch()
  local keep = SEQ.found
  chooseRebuild()
  SEQ.found = keep
end

function chooseFinish()
  CHOOSE.phase = "done"
  SOUND.gameWin()
end

function chooseTickPause(dt)
  CHOOSE.pause = CHOOSE.pause - dt
  if CHOOSE.pause > 0 then return end
  if CHOOSE.notch_dirty then
    chooseApplyNotch()
  elseif seqEmpty() then
    chooseFinish()
  else
    CHOOSE.clean = true
    CHOOSE.phase = "glow"
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
  end
end

function chooseHit(k)
  local r = keyRect(k)
  CHOOSE.burst = {
    x = r.x + r.w / 2,
    y = r.y + r.h / 2,
    t = 0.5
  }
  SOUND.match()
  if CHOOSE.clean then
    seqClear()
  else
    seqRequeue()
  end
  CHOOSE.phase = "pause"
  CHOOSE.pause = CF_PAUSE
end

-- After a win, Tab advances forward: to the next built game,
-- or out to the menu when Choose is the last/only game.
function chooseAdvance()
  local nid = nextGameId("choose")
  if nid then
    gotoScene(nid)
  else
    gotoScene("menu")
  end
end

function chooseKeypressed(k)
  if CHOOSE.phase == "done" then
    if k == "tab" then
      chooseAdvance()
    elseif k == "return" or k == "kpenter" or k == "r" then
      chooseRebuild()
    end
    return
  end
  if CHOOSE.phase ~= "glow" then return end
  if k == seqCurrent() then
    chooseHit(k)
  elseif not isMod(k) and k ~= "capslock" then
    -- a wrong key (not a modifier/caps): this target is no
    -- longer a first-try find; it will come round again.
    CHOOSE.clean = false
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

function chooseDone()
  return CHOOSE.phase == "done"
end

function chooseDoneTabLabel()
  if nextGameId("choose") then
    return STR.tab_next
  end
  return STR.tab_menu
end

-- Completion screen: a calm compliment plus a clear choice
-- (Tab to advance/exit, or Enter/R to play again). No count is
-- shown (first-try counting would read as unexplainable).
function chooseDrawDone()
  gfx.setColor(COL_OVERLAY)
  gfx.rectangle("fill", 0, 0, REF_W, REF_H)
  drawBandText(STR.good_job, { 150, 240 },
    getFont(FONT_HEAD), COL_WARM)
  drawBandText(chooseDoneTabLabel(), { 300, 340 },
    getFont(FONT_STATUS), COL_TEXT)
  drawBandText(STR.replay, { 346, 386 },
    getFont(FONT_STATUS), COL_DIM)
end

function chooseDraw()
  local deco = { }
  if CHOOSE.phase == "glow" then
    deco[seqCurrent()] = chooseGlowDeco()
  end
  drawKeyboard(deco)
  if CHOOSE.burst then drawBurst(CHOOSE.burst) end
  drawIndicators(CAPS_STATE.on)
  if chooseDone() then
    chooseDrawDone()
  end
end

registerScene("choose", {
  enter = chooseEnter,
  update = chooseUpdate,
  draw = chooseDraw,
  keypressed = chooseKeypressed,
  onNotch = chooseOnNotch,
  noHint = chooseDone
})
