-- Mini-game 2: Find the key. Same shared mastery core as Choose
-- (cfcore.lua), but the keyboard is NOT highlighted -- instead
-- one large target is shown in the header band and the child
-- hunts for it. The correct physical key is accepted (case and
-- Shift ignored); same chime + burst. At notch -2 the target is
-- larger with the smallest key set.

FIND = {
  phase = "glow",
  pause = 0,
  pulse = 0,
  burst = nil,
  notch_dirty = false,
  clean = true
}

-- Full written names for the non-printing targets.
FIND_TARGET = {
  space = "SPACE",
  ["return"] = "ENTER",
  backspace = "BACKSPACE"
}

function findEnter()
  cfEnter(FIND, "find")
end

function findUpdate(dt)
  cfUpdate(FIND, "find", dt)
end

function findKeypressed(k)
  cfKeypressed(FIND, "find", k)
end

function findOnNotch(delta)
  cfOnNotch(FIND, "find", delta)
end

function findDone()
  return cfDone(FIND)
end

function findTargetText(name)
  local t = FIND_TARGET[name]
  if t then return t end
  return string.upper(name)
end

function findTargetFont()
  if notchGet("find") == -2 then
    return getFont(FONT_TARGET_BIG)
  end
  return getFont(FONT_BIG)
end

function findDrawTarget()
  local name = seqCurrent()
  if not name then return end
  drawBandText(findTargetText(name), HEADER_BAND,
    findTargetFont(), COL_TEXT)
end

function findDraw()
  drawKeyboard({ })
  if not findDone() then findDrawTarget() end
  if FIND.burst then drawBurst(FIND.burst) end
  drawIndicators(CAPS_STATE.on)
  if findDone() then cfDrawDone("find") end
end

registerScene("find", {
  enter = findEnter,
  update = findUpdate,
  draw = findDraw,
  keypressed = findKeypressed,
  onNotch = findOnNotch,
  noHint = findDone
})
