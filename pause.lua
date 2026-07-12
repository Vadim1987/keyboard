-- Deliberate pause for the TIMED games. (UX standard: a timed
-- game keeps things happening while the child is away, so it
-- offers a pause.) Alt+P toggles a modal freeze on a scene
-- that sets `timed = true` (Hunt); the untimed find-key drills
-- have no timer and no pause. While paused the game gets no
-- updates (state kept; the child controls resume) and a modal
-- overlay shows the resume chord as keycaps for non-readers.

PAUSED = false

-- Only a timed scene pauses; Alt+P is a no-op elsewhere.
function pauseToggle()
  local s = SCENES[ACTIVE]
  if not (s and s.timed) then 
    return 
  end
  PAUSED = not PAUSED
  SOUND.pause()
end

-- Cleared on each scene entry; pause never leaks across games.
function pauseClear()
  PAUSED = false
end

-- The resume chord (Alt + P) as two centered keycaps.
function pauseDrawKeys()
  local font = getFont(FONT_MENU)
  local h = 56
  local y = 292
  local gap = 12
  local x = (REF_W - 90 - 56 - gap) / 2
  drawKeycap({ x = x, y = y, w = 90, h = h },
    { label = "Alt", font = font })
  drawKeycap({ x = x + 90 + gap, y = y, w = 56, h = h },
    { label = "P", font = font })
end

function drawPauseOverlay()
  gfx.setColor(COL_OVERLAY)
  gfx.rectangle("fill", 0, 0, REF_W, REF_H)
  drawBandText(STR.paused, { 150, 230 },
    getFont(FONT_HEAD), COL_TEXT)
  pauseDrawKeys()
  drawBandText(STR.back_hint, { 366, 402 },
    getFont(FONT_STATUS), COL_DIM)
end
