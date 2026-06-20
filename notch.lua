-- Shared difficulty-notch core. Per-scene notch value, teacher
-- chord shift saturating at the scene's declared bounds, and
-- reset-to-0 at program start. Press/Find/Hunt drive the notch
-- by teacher chord; Caps/Shift add the auto-match adapter below
-- (the notch shifts itself).

NOTCH = { }

function notchInit()
  for _, id in ipairs(MENU_ORDER) do
    NOTCH[id] = 0
  end
end

function notchGet(id)
  return NOTCH[id] or 0
end

function notchShift(id, delta, lo, hi)
  local v = (NOTCH[id] or 0) + delta
  if v < lo then v = lo end
  if v > hi then v = hi end
  NOTCH[id] = v
  return v
end

-- Re-entry policy for player-facing-notch games: a climbed
-- notch (>= 0) resets to 0 each fresh entry (a clean climb),
-- but an eased notch (< 0, set by the teacher or reached by
-- struggling) is preserved -- min(notch, 0). Teacher-only-notch
-- games skip this and keep their notch.
function notchEnterReset(id)
  NOTCH[id] = math.min(NOTCH[id] or 0, 0)
end

-- Auto-match adapter (Caps/Shift): the notch shifts itself on
-- CONSECUTIVE streaks -- 3 clean in a row -> up, 2 struggles ->
-- down -- once the cooldown since the last change has elapsed.
-- The opposite outcome breaks a streak; counters also reset on
-- any notch change (auto or teacher). Canonical rule:
-- docs/compy-ux-principles.md "Difficulty Notches".
NOTCH_AUTO = { }

function notchAutoReset(id)
  NOTCH_AUTO[id] = { clean = 0, struggle = 0, cd = 0 }
end

function notchAutoTick(id, dt)
  local a = NOTCH_AUTO[id]
  if a then a.cd = math.max(0, a.cd - dt) end
end

function notchAutoDir(a)
  if a.clean >= 3 then return 1 end
  if a.struggle >= 2 then return -1 end
  return 0
end

-- Streaks are CONSECUTIVE: a clean resets the struggle streak,
-- a struggle resets the clean streak, and a "none" breaks both.
function notchAutoCount(id, outcome)
  local a = NOTCH_AUTO[id]
  if outcome == "clean" then
    a.clean = a.clean + 1
    a.struggle = 0
  elseif outcome == "struggle" then
    a.struggle = a.struggle + 1
    a.clean = 0
  else
    a.clean = 0
    a.struggle = 0
  end
end

-- Record one target's outcome ("clean" / "struggle" / "none").
-- Returns the signed notch change (0 if none); on a real change
-- the counters reset and the cooldown arms (CAPS_HINT_COOLDOWN,
-- the one shared auto-match window).
function notchAutoResult(id, lo, hi, outcome)
  notchAutoCount(id, outcome)
  local a = NOTCH_AUTO[id]
  if a.cd > 0 then return 0 end
  local d = notchAutoDir(a)
  if d == 0 then return 0 end
  local old = notchGet(id)
  notchShift(id, d, lo, hi)
  notchAutoReset(id)
  if notchGet(id) == old then return 0 end
  NOTCH_AUTO[id].cd = CAPS_HINT_COOLDOWN
  return notchGet(id) - old
end
