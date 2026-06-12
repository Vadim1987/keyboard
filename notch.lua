-- Shared difficulty-notch core. Per-scene notch value, teacher
-- chord shift saturating at the scene's declared bounds, and
-- reset-to-0 at program start. Choose/Find/Hunt drive the notch
-- by teacher chord (and Hunt's streak length); Caps/Shift add
-- the auto-match adapter below (the notch shifts itself).

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

-- Auto-match adapter (Caps/Shift): the notch shifts itself from
-- clean/struggle counts -- 3 clean -> up, 2 struggle -> down --
-- once the cooldown since the last auto-change has elapsed.
-- Counters reset on every notch change (auto or teacher).
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

function notchAutoCount(id, clean)
  local a = NOTCH_AUTO[id]
  if clean then
    a.clean = a.clean + 1
  else
    a.struggle = a.struggle + 1
  end
end

-- Record one attempt (clean true / struggle false); returns the
-- signed notch change applied (0 if none). On a real change the
-- counters reset and the cooldown arms.
function notchAutoResult(id, lo, hi, clean, cooldown)
  notchAutoCount(id, clean)
  local a = NOTCH_AUTO[id]
  if a.cd > 0 then return 0 end
  local d = notchAutoDir(a)
  if d == 0 then return 0 end
  local old = notchGet(id)
  notchShift(id, d, lo, hi)
  notchAutoReset(id)
  if notchGet(id) == old then return 0 end
  NOTCH_AUTO[id].cd = cooldown
  return notchGet(id) - old
end
