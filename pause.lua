-- Child-invoked pause for the active games: Alt+P toggles a
-- modal freeze. While paused the game gets no updates (state is
-- kept; the child controls resume, no auto-countdown) and a
-- modal overlay shows the resume chord as keycaps (4-6 are
-- non-readers). (UX standard: every active game offers a
-- deliberate pause; reuses the overlay-pause path + keycaps.)

PAUSED = false

function pauseToggle()
  if not isGameScene(ACTIVE) then return end
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
    { label = "Alt", font = font, radius = 8 })
  drawKeycap({ x = x + 90 + gap, y = y, w = 56, h = h },
    { label = "P", font = font, radius = 8 })
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
