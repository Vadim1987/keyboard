-- Pure wave-length adaptation for Hunt (streak-based).
-- 5 caught in a row -> +1 (up to lmax); 3 missed in a row -> -1
-- (down to lmin, never below 1). A streak broken by the
-- opposite outcome changes nothing -- the intuitive rule,
-- unlike a rolling-window majority. Caller resets the streak.

function huntStreakLength(cstreak, mstreak, length, lmin, lmax)
  if cstreak >= 5 then
    return math.min(length + 1, lmax)
  end
  if mstreak >= 3 then
    return math.max(length - 1, math.max(1, lmin))
  end
  return length
end
