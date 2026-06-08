-- Shared difficulty-notch core. Per-scene notch value, teacher
-- chord shift saturating at the scene's declared bounds, and
-- reset-to-0 at program start. The core does no auto-matching;
-- each game layers its own adapter (here: Choose/Find use the
-- asymmetric -2..0 teacher-only range with no auto-match).

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
