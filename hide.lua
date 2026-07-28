-- hide.lua

-- Hide and seek. A cap slides out from behind a crate, waits,
-- then slides back. The child may press it while it shows, or
-- from memory once it has gone: a press during the memory
-- window scores the same but celebrates louder, because
-- remembering is the harder thing. Letting the window close is
-- a miss and the key comes back.
--
-- Press-count engine (gauge.lua) as in Press, so the key set
-- and the review live there. This file owns the peek cycle and
-- the scene. The notch shortens the peek and lengthens the
-- memory window together, so a level asks for more memory and
-- less looking. Full canvas: no keyboard picture, since the
-- cap behind the crate IS the target and a board below would
-- only repeat it.

ensureFile("props.lua")

HIDE = { burst = nil, wrong = nil, fw = { } }
HIDE_CFG = {
  id = "hide",
  notch = PRESS_NOTCH,
  lo = PRESS_LO,
  hi = PRESS_HI,
  g = HIDE_G,
  gtop = HIDE_GTOP
}

-- phase: out (sliding into view), peek (fully out), in
-- (sliding back), memory (gone, still pressable), gap (a beat
-- between targets). t is the time spent in the phase.

PEEK = { phase = "gap", t = 0 }

-- Cap size and the crate edge it slides from are fixed, so
-- they are derived once here rather than per frame.

HIDE_CAP_W = HIDE_CAP_H * KB_STD_W / KB_STD_H
HIDE_CRATE_R = HIDE_CRATE_X + 10 * HIDE_CRATE_U

function hidePeekTime()
  return HIDE_PEEK[notchGet("hide")]
end

function hideMemoryTime()
  return HIDE_MEMORY[notchGet("hide")]
end

-- How far the cap has slid out, 0 hidden to 1 fully shown.

function hideSlideFrac()
  if PEEK.phase == "peek" then
    return 1
  elseif PEEK.phase == "out" then
    return PEEK.t / HIDE_SLIDE
  elseif PEEK.phase == "in" then
    return 1 - PEEK.t / HIDE_SLIDE
  end
  return 0
end

-- The cap can still be answered while it shows and through the
-- memory window; a gap is dead time between targets.

function hideLive()
  return PEEK.phase ~= "gap"
end

function hideFromMemory()
  return PEEK.phase == "memory"
end

function hideGoto(phase)
  PEEK.phase = phase
  PEEK.t = 0
end

function hideEnter()
  hideGoto("gap")
  fkEnter(HIDE, HIDE_CFG)
  skyLevel(HIDE_CFG)
  pastelSnap()
end

-- Phase ticks. Each returns the phase to enter next, or nil to
-- stay, so the table below reads as the cycle itself.

function hideTickOut()
  if HIDE_SLIDE <= PEEK.t then return "peek" end
end

function hideTickPeek()
  if hidePeekTime() <= PEEK.t then return "in" end
end

function hideTickIn()
  if HIDE_SLIDE <= PEEK.t then return "memory" end
end

-- The window closing with no answer is a miss: the gauge marks
-- the key hard so it returns, and the next target waits out a
-- gap so the child sees the crate settle.

function hideTickMemory()
  if hideMemoryTime() <= PEEK.t then
    SOUND.reject()
    gaugeOnWrong(HIDE, HIDE_CFG)
    return "gap"
  end
end

function hideTickGap()
  if HIDE_GAP <= PEEK.t then return "out" end
end

HIDE_TICK = {
  out = hideTickOut,
  peek = hideTickPeek,
  ["in"] = hideTickIn,
  memory = hideTickMemory,
  gap = hideTickGap
}

function hideUpdate(dt)
  fkUpdate(HIDE, HIDE_CFG, dt)
  if fkDone(HIDE) then return end
  PEEK.t = PEEK.t + dt
  local next = HIDE_TICK[PEEK.phase]()
  if next then hideGoto(next) end
end

-- A hit. Remembering after the cap has gone is the harder
-- thing, so it gets the firework as well as the burst; seeing
-- it and pressing gets the plain burst.

function hideHit(k)
  local recalled = hideFromMemory()
  fkHit(HIDE, HIDE_CFG, k)
  if recalled then fwStart(HIDE) end
  hideGoto("gap")
end

function hideKeypressed(k)
  if fkDone(HIDE) then
    fkDoneKey(HIDE, HIDE_CFG, k)
    return
  end
  if not hideLive() then return end
  if k == gaugeCurrent(HIDE) then
    hideHit(k)
  elseif not isMod(k) and k ~= "capslock" then
    fkWrong(HIDE, HIDE_CFG, k)
  end
end

-- A teacher notch change restarts the level, so the cycle
-- restarts with it.

function hideOnNotch(delta)
  hideGoto("gap")
  fkOnNotch(HIDE, HIDE_CFG, delta)
  skyLevel(HIDE_CFG)
end

function hideDone()
  return fkDone(HIDE)
end

-- Drawing

-- The cap slides right from behind the crate. At frac 0 it sits
-- wholly behind it; at 1 all but HIDE_CAP_LIP is clear, so it
-- still reads as coming from behind rather than standing free.

function hideCapX(frac)
  local travel = HIDE_CAP_W - HIDE_CAP_LIP
  return HIDE_CRATE_R - HIDE_CAP_W + frac * travel
end

function hideCapCell()
  return {
    x = hideCapX(hideSlideFrac()),
    y = HIDE_GROUND_Y - HIDE_CAP_H - HIDE_CRATE_U,
    w = HIDE_CAP_W,
    h = HIDE_CAP_H
  }
end

-- The cap is drawn BEFORE the crate, so the crate covers
-- whatever has not slid clear yet.

function hideDrawCap()
  drawKeycap(hideCapCell(), {
    name = gaugeCurrent(HIDE),
    unit = HIDE_CAP_H / KB_STD_H
  })
end

function hideDrawScene()
  drawMeadow(REF_W, REF_H, HIDE_GROUND_Y)
  hideDrawCap()
  drawCrate(HIDE_CRATE_X, HIDE_GROUND_Y, HIDE_CRATE_U)
end

function hideDraw()
  if hideDone() then
    fkDrawDoneScreen()
    fwDraw(HIDE)
    return
  end
  hideDrawScene()
  drawWinGauge(HIDE.hits, HIDE.goal)
  fwDraw(HIDE)
  fkDrawExitHint()
end

registerScene("hide", {
  enter = hideEnter,
  update = hideUpdate,
  draw = hideDraw,
  keypressed = hideKeypressed,
  onNotch = hideOnNotch,
  noHint = hideDone
})
