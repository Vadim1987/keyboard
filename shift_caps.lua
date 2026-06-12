-- Mini-game 5: Big letters with Shift. Same goal as Caps --
-- capitals -- but made with the momentary Shift CHORD (two keys
-- held together, the child's first chord), not the Caps Lock
-- mode. A capital counts only when produced with Shift HELD, so
-- the lesson can't be shortcut via Caps Lock; if Caps is on it
-- pulses as a turn-off hint (the methods don't stack). Both
-- Shift keys glow while a capital is wanted; the held Shift
-- lights live. +2 gives two-letter capital sequences.

SHIFT_CAPS = {
  phase = "play",
  pause = 0,
  burst = nil,
  pool = { },
  idx = 0,
  target = "",
  typed = 0,
  clean = true,
  miss = 0
}

-- Notch data is shared with Caps (set + hint); shift_caps
-- ignores the mixed-case column; targets are all capitals.
function shiftCapsCfg()
  return CAPS_NOTCH[notchGet("shift_caps")]
end

function shiftCapsShuffle()
  SHIFT_CAPS.pool = { }
  for _, k in ipairs(KEYSETS[shiftCapsCfg().set]) do
    SHIFT_CAPS.pool[#SHIFT_CAPS.pool + 1] = k
  end
  shuffleInPlace(SHIFT_CAPS.pool)
  SHIFT_CAPS.idx = 0
end

function shiftCapsNext()
  SHIFT_CAPS.idx = SHIFT_CAPS.idx + 1
  if SHIFT_CAPS.idx > #SHIFT_CAPS.pool then
    shiftCapsShuffle()
    SHIFT_CAPS.idx = 1
  end
  return SHIFT_CAPS.pool[SHIFT_CAPS.idx]
end

-- One capital per notch; two at +2 (a short capital sequence).
function shiftCapsSpawn()
  local len = 1
  if notchGet("shift_caps") == 2 then len = 2 end
  SHIFT_CAPS.target = ""
  for _ = 1, len do
    SHIFT_CAPS.target = SHIFT_CAPS.target
      .. string.upper(shiftCapsNext())
  end
  SHIFT_CAPS.typed = 0
  SHIFT_CAPS.clean = true
  SHIFT_CAPS.miss = 0
  SHIFT_CAPS.phase = "play"
end

function shiftCapsEnter()
  notchAutoReset("shift_caps")
  shiftCapsShuffle()
  SHIFT_CAPS.burst = nil
  shiftCapsSpawn()
end

-- The next capital still owed in the current target.
function shiftCapsWant()
  return SHIFT_CAPS.target:sub(
    SHIFT_CAPS.typed + 1, SHIFT_CAPS.typed + 1)
end

function shiftCapsAuto(outcome)
  local d = notchAutoResult("shift_caps", -2, 2, outcome,
    CAPS_HINT_COOLDOWN)
  if d ~= 0 then shiftCapsShuffle() end
end

-- Clean = whole target made via Shift first try; struggle = 2+
-- misses (no Shift, a Caps-Lock capital, or a wrong key); a
-- "none" (neither) target breaks both consecutive streaks.
function shiftCapsScore()
  if SHIFT_CAPS.clean then
    shiftCapsAuto("clean")
  elseif SHIFT_CAPS.miss >= 2 then
    shiftCapsAuto("struggle")
  else
    shiftCapsAuto("none")
  end
end

function shiftCapsHit()
  local r = keyRect(string.lower(SHIFT_CAPS.target:sub(-1)))
  if r then
    SHIFT_CAPS.burst = {
      x = r.x + r.w / 2, y = r.y + r.h / 2, t = 0.5
    }
  end
  SOUND.match()
  shiftCapsScore()
  SHIFT_CAPS.phase = "pause"
  SHIFT_CAPS.pause = CF_PAUSE
end

-- Honest case + Shift: accept the wanted capital only when a
-- Shift key is held. A Caps-Lock capital (no Shift) or a
-- lowercase/wrong key is a silent miss; the standing Shift glow
-- and Caps-off pulse are the guidance.
function shiftCapsTextinput(ch)
  if SHIFT_CAPS.phase ~= "play" then return end
  if not isAlphaChar(ch) then return end
  if ch == shiftCapsWant() and INPUT.shift then
    SHIFT_CAPS.typed = SHIFT_CAPS.typed + 1
    if SHIFT_CAPS.typed >= #SHIFT_CAPS.target then
      shiftCapsHit()
    end
    return
  end
  SHIFT_CAPS.clean = false
  SHIFT_CAPS.miss = SHIFT_CAPS.miss + 1
end

function shiftCapsOnNotch(delta)
  local old = notchGet("shift_caps")
  if notchShift("shift_caps", delta, -2, 2) ~= old then
    notchAutoReset("shift_caps")
    shiftCapsShuffle()
  end
end

function shiftCapsUpdate(dt)
  notchAutoTick("shift_caps", dt)
  if SHIFT_CAPS.burst then
    SHIFT_CAPS.burst.t = SHIFT_CAPS.burst.t - dt
    if SHIFT_CAPS.burst.t <= 0 then SHIFT_CAPS.burst = nil end
  end
  if SHIFT_CAPS.phase == "pause" then
    SHIFT_CAPS.pause = SHIFT_CAPS.pause - dt
    if SHIFT_CAPS.pause <= 0 then shiftCapsSpawn() end
  end
end

function shiftCapsHintWanted()
  return shiftCapsCfg().hint ~= "off"
end

-- The Shift keys' decoration: a lit face while Shift is held
-- (live), else a soft "hold me" glow at hinting notches.
function shiftCapsShiftDec()
  if INPUT.shift then return { bg = COL_WARM_DIM } end
  if shiftCapsHintWanted() then
    return { glow = COL_WARM_DIM }
  end
  return nil
end

function shiftCapsDeco()
  local deco = { }
  local sd = shiftCapsShiftDec()
  if sd then
    deco.lshift = sd
    deco.rshift = sd
  end
  if CAPS_STATE.on then
    deco.capslock = { glow = COL_WARM }
  end
  return deco
end

function shiftCapsDraw()
  drawKeyboard(shiftCapsDeco(), true)
  drawBandText(SHIFT_CAPS.target, HEADER_BAND,
    getGlyphFont(FONT_BIG), COL_TEXT)
  if SHIFT_CAPS.burst then drawBurst(SHIFT_CAPS.burst) end
  drawIndicators(CAPS_STATE.on, CAPS_STATE.on)
end

registerScene("shift_caps", {
  enter = shiftCapsEnter,
  update = shiftCapsUpdate,
  draw = shiftCapsDraw,
  textinput = shiftCapsTextinput,
  onNotch = shiftCapsOnNotch
})
