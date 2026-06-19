-- Shuffle a list in place (Fisher-Yates) with love.math.random,
-- so the order varies per session. Shared by the legacy
-- big-letter / symbol scenes (caps, shift_caps, shift_symbols),
-- which build and shuffle their own target pools; those scenes
-- are retired at the Alt slice. The round-gauge engine shuffles
-- its pool internally (gauge.lua).
function shuffleInPlace(t)
  for i = #t, 2, -1 do
    local j = love.math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end
