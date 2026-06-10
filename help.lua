-- In-game help. A small "Hold Alt+H for help" hint sits along
-- the bottom edge of every mini-game. HOLDING Alt+H shows a
-- calm overlay that vanishes as soon as the keys are
-- released -- an ephemeral peek, never a stuck modal (see
-- the overlay principle in docs/compy-ux-principles.md).
-- Alt+H is the interim help chord (F-keys are blocked on
-- current hardware). A scene may suppress the hint/overlay
-- (its own completion screen) via noHint() -> true.

function helpHeld()
  return INPUT.held.h and INPUT.alt and not INPUT.ctrl
end

-- True while the help overlay is on screen. main pauses the
-- active game while it is, so nothing runs behind it.
function helpOverlayShown()
  if not isGameScene(ACTIVE) then return false end
  local scene = SCENES[ACTIVE]
  if scene and scene.noHint and scene.noHint() then
    return false
  end
  if helpHeld() then return true end
  return false
end

function drawHelpHint()
  local font = getFont(FONT_HINT)
  gfx.setFont(font)
  gfx.setColor(COL_DIM)
  local y = REF_H - font:getHeight() - 8
  gfx.printf(STR.help_hint, 0, y, REF_W, "center")
end

function drawHelpOverlay()
  local text = STR.help[ACTIVE]
  if not text then return end
  gfx.setColor(COL_OVERLAY)
  gfx.rectangle("fill", 0, 0, REF_W, REF_H)
  gfx.setFont(getFont(FONT_HELP))
  gfx.setColor(COL_TEXT)
  gfx.printf(text, 80, 150, REF_W - 160, "center")
end

function drawHelpLayer()
  if not isGameScene(ACTIVE) then return end
  local scene = SCENES[ACTIVE]
  if scene and scene.noHint and scene.noHint() then
    return
  end
  if helpHeld() then
    drawHelpOverlay()
  else
    drawHelpHint()
  end
end
