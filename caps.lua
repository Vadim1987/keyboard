-- Mini-game 4: Big letters (Caps Lock). Like Find, but the
-- target is a CASED letter and the child must PRODUCE it via
-- honest case (textinput is the source of truth). Caps Lock
-- flips the effective mode (keycaps + indicator follow; a soft
-- tick plays). Right letter, wrong case -> a gentle Caps Lock
-- nudge (a directional hint, not an error). Continuous; the
-- notch auto-matches (notch.lua). On-device Caps reconciliation
-- is validated here (Q2).

CAPS = {
  phase = "play",
  pause = 0,
  burst = nil,
  nudge = 0,
  pool = { },
  idx = 0,
  target = nil,
  clean = true,
  wrongcase = 0
}

function capsCfg()
  return CAPS_NOTCH[notchGet("caps")]
end

function capsSet()
  return KEYSETS[capsCfg().set]
end

-- Shuffle the current notch's letters into the target pool.
function capsShuffle()
  CAPS.pool = { }
  for _, k in ipairs(capsSet()) do
    CAPS.pool[#CAPS.pool + 1] = k
  end
  shuffleInPlace(CAPS.pool)
  CAPS.idx = 0
end

-- Capitals-only notches use uppercase; mixed notches pick a
-- random case, so the child also learns to turn Caps Lock off.
function capsCaseOf(letter)
  if capsCfg().mixed and love.math.random() < 0.5 then
    return letter
  end
  return string.upper(letter)
end

function capsSpawn()
  CAPS.idx = CAPS.idx + 1
  if CAPS.idx > #CAPS.pool then
    capsShuffle()
    CAPS.idx = 1
  end
  CAPS.target = capsCaseOf(CAPS.pool[CAPS.idx])
  CAPS.clean = true
  CAPS.wrongcase = 0
  CAPS.phase = "play"
end

function capsEnter()
  notchAutoReset("caps")
  capsShuffle()
  CAPS.burst = nil
  CAPS.nudge = 0
  capsSpawn()
end

-- Auto-match the notch from this target's result; a change
-- reshuffles for the new letter set.
function capsAuto(outcome)
  local d = notchAutoResult("caps", -2, 2, outcome)
  if d ~= 0 then capsShuffle() end
end

-- Clean = correct case on the first letter press; struggle =
-- 2+ wrong-case presses. Anything between is a "none" that
-- breaks both consecutive streaks.
function capsScore()
  if CAPS.clean then
    capsAuto("clean")
  elseif CAPS.wrongcase >= 2 then
    capsAuto("struggle")
  else
    capsAuto("none")
  end
end

function capsHit()
  local r = keyRect(string.lower(CAPS.target))
  if r then
    CAPS.burst = {
      x = r.x + r.w / 2, y = r.y + r.h / 2, t = 0.5
    }
  end
  SOUND.match()
  capsScore()
  CAPS.phase = "pause"
  CAPS.pause = capsCfg().fast and 0.3 or CF_PAUSE
end

function capsTextinput(ch)
  dbgLog("CAP ch=" .. ch .. " tgt=" .. tostring(CAPS.target)
    .. " ph=" .. CAPS.phase)
  if CAPS.phase ~= "play" then return end
  if not isAlphaChar(ch) then return end
  if ch == CAPS.target then
    capsHit()
    return
  end
  CAPS.clean = false
  if string.lower(ch) == string.lower(CAPS.target) then
    CAPS.wrongcase = CAPS.wrongcase + 1
    CAPS.nudge = 0.45
  end
end

-- A soft tick acknowledges the Caps Lock toggle (the toggle of
-- the effective estimate itself happens in input.lua).
function capsKeypressed(k)
  if k == "capslock" then SOUND.typeTick() end
end

function capsOnNotch(delta)
  local old = notchGet("caps")
  if notchShift("caps", delta, -2, 2) ~= old then
    notchAutoReset("caps")
    capsShuffle()
  end
end

function capsUpdate(dt)
  notchAutoTick("caps", dt)
  if CAPS.nudge > 0 then CAPS.nudge = CAPS.nudge - dt end
  if CAPS.burst then
    CAPS.burst.t = CAPS.burst.t - dt
    if CAPS.burst.t <= 0 then CAPS.burst = nil end
  end
  if CAPS.phase == "pause" then
    CAPS.pause = CAPS.pause - dt
    if CAPS.pause <= 0 then capsSpawn() end
  end
end

-- Is the effective mode wrong for the current target's case?
function capsModeWrong()
  if not CAPS.target then return false end
  return capsEffectiveUpper() ~= isUpperChar(CAPS.target)
end

function capsHintWanted()
  if capsCfg().hint == "off" then return false end
  return capsModeWrong()
end

-- The Caps Lock key decoration: a soft hint glow, or a brighter
-- pulse during the wrong-case nudge.
function capsCapsDec()
  if CAPS.nudge > 0 then
    local p = CAPS.nudge / 0.45
    return { glow = COL_WARM, pulse = 1 + 0.10 * p }
  end
  return { glow = COL_WARM_DIM }
end

function capsDeco()
  if not capsHintWanted() and CAPS.nudge <= 0 then
    return { }
  end
  return { capslock = capsCapsDec() }
end

function capsDraw()
  drawKeyboard(capsDeco(), true)
  drawBandText(CAPS.target, HEADER_BAND,
    getGlyphFont(FONT_BIG), COL_TEXT)
  if CAPS.burst then drawBurst(CAPS.burst) end
  drawIndicators(CAPS_STATE.on, CAPS.nudge > 0)
end

registerScene("caps", {
  enter = capsEnter,
  update = capsUpdate,
  draw = capsDraw,
  keypressed = capsKeypressed,
  textinput = capsTextinput,
  onNotch = capsOnNotch
})
