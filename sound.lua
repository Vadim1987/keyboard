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

-- A correct match in Choose / Find: the warm xylophone chime.
function SOUND.match()
  sfx.correct()
end

-- Finishing a whole run (completion screen). Gentle, not an
-- arcade jingle; the sample is easy to retune here.
function SOUND.gameWin()
  sfx.win()
end
