-- Shared sound palette. Maps gentle game EVENTS to compy.audio
-- samples by meaning, so callers say what happened rather than
-- which sample plays (and the mapping can change in one place).
-- There is deliberately no failure or wrong-key sound.

sfx = compy.audio

SOUND = { }

-- Typewriter key tick: the intro's simulated Caps Lock press
-- and each letter of the heading.
function SOUND.typeTick()
  sfx.knock()
end

-- A correct match in the find-key games: a soft toggle blip
-- (correct.ogg grated on repeat; toggle was chosen on device).
function SOUND.match()
  sfx.toggle()
end

-- A round win in the gauge games: win.ogg.
function SOUND.win()
  sfx.win()
end

-- The biggest win, at the top notch: wow.ogg.
function SOUND.wow()
  sfx.wow()
end
