-- Shared hint finger: a Nerd Font FA pointing-down glyph that
-- sweeps toward a key from ~2 keycap heights up -- a prominent,
-- wordless "press this" cue. The scene supplies the target key
-- cell and an animation clock, and owns when to show the finger
-- and which keyboard glows accompany it. First consumer: Alt
-- characters (Shift, then the base key once Shift is held).
HINT_FINGER = "\239\130\167"
HINT_FONT = 52

-- Sweep the finger between just above the key and two keycap
-- heights up, so the pointing gesture reads across the row.
function hintFingerY(cell, t)
  local s = (math.sin(t * 3.5) + 1) / 2
  return cell.y - cell.h * 0.3 - cell.h * 1.7 * s
end

function hintFingerAt(x, y, w)
  gfx.printf(HINT_FINGER, x, y, w, "center")
end

-- A dark finger with a pale halo, so the pointer stays legible
-- over the warm key glow it points at (a warm finger vanished
-- into it) as well as over the pale background.
function hintFinger(cell, t)
  gfx.setFont(getGlyphFont(HINT_FONT))
  local x = cell.x
  local y = hintFingerY(cell, t)
  gfx.setColor(COL_KEY)
  hintFingerAt(x - 2, y, cell.w)
  hintFingerAt(x + 2, y, cell.w)
  hintFingerAt(x, y - 2, cell.w)
  hintFingerAt(x, y + 2, cell.w)
  gfx.setColor(COL_KEY_LABEL)
  hintFingerAt(x, y, cell.w)
end
