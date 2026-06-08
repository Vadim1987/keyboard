-- Shared sound palette. Wraps compy.audio with only the
-- blessed, gentle sounds. There is deliberately no wrong sound
-- anywhere in this program.

sfx = compy.audio

SOUND = { }

function SOUND.knock()
  sfx.knock()
end

function SOUND.ping()
  sfx.ping()
end

function SOUND.correct()
  sfx.correct()
end
