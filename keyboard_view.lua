-- Parametric Compy keyboard renderer. Reuses the physical key
-- proportions of the original graphics.lua, but fits the
-- keyboard band by a computed scale and origin (no hardcoded
-- 960px path). drawKeyboard(deco) tints/pulses/glows keys via a
-- per-key decoration map; keyRect(name) exposes key geometry.

KB = { scale = 0, x = 0, y = 0, w = 0, h = 0 }
KB.cells = { }
KB.rect = { }

KB_ROWS = { }
KB_ROWS[1] = {
  "escape", "f1", "f2", "f3", "f4", "f5", "f6",
  "f7", "f8", "f9", "f10", "f11", "f12",
  "numlk", "delete"
}
KB_ROWS[2] = {
  "`", "1", "2", "3", "4", "5", "6", "7",
  "8", "9", "0", "-", "backspace"
}
KB_ROWS[3] = {
  "tab", "q", "w", "e", "r", "t", "y",
  "u", "i", "o", "p", "=", "\\"
}
KB_ROWS[4] = {
  "capslock", "a", "s", "d", "f", "g",
  "h", "j", "k", "l", ";", "return"
}
KB_ROWS[5] = {
  "lshift", "\\", "z", "x", "c", "v", "b",
  "n", "m", ",", ".", "/", "up", "rshift"
}
KB_ROWS[6] = {
  "fn", "lctrl", "zzz", "lalt", "pause",
  "space", "menu", "[", "]", "'",
  "left", "down", "right"
}

-- Physical key metrics in millimetres (from graphics.lua).
KB_W_MM = 201.5
KB_STD_W = 15
KB_TOP_W = 12.5
KB_SMALL_W = 11
KB_MED_W = 19
KB_WIDE_W = 23
KB_SPACE_W = 59.5
KB_TOP_H = 11
KB_STD_H = 12.5
KB_GAP_MM = 1.0

-- Per-name width overrides (millimetres).
KB_WMM = { }
KB_WMM.space = KB_SPACE_W
for _, n in ipairs({
  "`", "=", "\\", ";", ",", ".", "/", "up", "rshift"
}) do
  KB_WMM[n] = KB_SMALL_W
end
for _, n in ipairs({ "tab", "lshift" }) do
  KB_WMM[n] = KB_MED_W
end
for _, n in ipairs({ "capslock", "return" }) do
  KB_WMM[n] = KB_WIDE_W
end

-- Display labels for non-character keys.
KB_LABEL = { }
KB_LABEL.escape = "Esc"
KB_LABEL.numlk = "Num"
KB_LABEL.delete = "Del"
KB_LABEL.backspace = "Bksp"
KB_LABEL.tab = "Tab"
KB_LABEL["return"] = "Enter"
KB_LABEL.capslock = "Caps"
KB_LABEL.lshift = "Shift"
KB_LABEL.rshift = "Shift"
KB_LABEL.lctrl = "Ctrl"
KB_LABEL.lalt = "Alt"
KB_LABEL.menu = "Menu"
KB_LABEL.fn = "Fn"
KB_LABEL.zzz = "Zzz"
KB_LABEL.pause = "Pause"
KB_LABEL.space = ""
KB_LABEL.up = "↑"
KB_LABEL.down = "↓"
KB_LABEL.left = "←"
KB_LABEL.right = "→"
for i = 1, 12 do
  KB_LABEL["f" .. i] = "F" .. i
end

-- Single-glyph keys that still want the large keycap font even
-- though their label is multi-byte UTF-8.
KB_ARROW = {
  up = true, down = true, left = true, right = true
}

function kbWidthMM(name, ri)
  local w = KB_WMM[name]
  if w then return w end
  if ri == 1 then return KB_TOP_W end
  if ri == 6 then return KB_SMALL_W end
  return KB_STD_W
end

function kbRowH(ri)
  if ri == 1 then return KB_TOP_H * KB.scale end
  return KB_STD_H * KB.scale
end

function kbComputeScale()
  local total = KB_TOP_H + 5 * KB_STD_H + 5 * KB_GAP_MM
  local sw = 912 / KB_W_MM
  local sh = 340 / total
  KB.scale = math.min(sw, sh)
  KB.w = KB_W_MM * KB.scale
  KB.h = total * KB.scale
  KB.x = (REF_W - KB.w) / 2
  local band = KBAND_Y1 - KBAND_Y0
  KB.y = KBAND_Y0 + (band - KB.h) / 2
end

function kbAddCell(cell)
  KB.cells[#KB.cells + 1] = cell
  if not KB.rect[cell.name] then
    KB.rect[cell.name] = cell
  end
end

function kbPlaceRow(ri, y, h, gap)
  local x = KB.x
  for _, name in ipairs(KB_ROWS[ri]) do
    local w = kbWidthMM(name, ri) * KB.scale
    kbAddCell({ name = name, x = x, y = y, w = w, h = h })
    x = x + w + gap
  end
end

function kbRowSum(ri)
  local sum = 0
  for _, name in ipairs(KB_ROWS[ri]) do
    sum = sum + kbWidthMM(name, ri) * KB.scale
  end
  return sum
end

function kbBuildCells()
  local y = KB.y
  for ri = 1, #KB_ROWS do
    local h = kbRowH(ri)
    local row = KB_ROWS[ri]
    local gap = (KB.w - kbRowSum(ri)) / (#row - 1)
    kbPlaceRow(ri, y, h, gap)
    y = y + h + KB_GAP_MM * KB.scale
  end
end

kbComputeScale()
KCAP_BIG = getFont(math.floor(5 * KB.scale))
KCAP_SMALL = getFont(math.floor(2.7 * KB.scale))
kbBuildCells()

-- Effective case of letter keycaps: upper iff Caps XOR Shift.
function capsEffectiveUpper()
  if INPUT.shift then return not CAPS_STATE.on end
  return CAPS_STATE.on
end

function kbLabel(name)
  local l = KB_LABEL[name]
  if l then return l end
  if #name == 1 then
    if KB_LIVECASE and isAlphaChar(name)
        and not capsEffectiveUpper() then
      return name
    end
    return string.upper(name)
  end
  return name
end

function kbDrawLabel(cell)
  local label = kbLabel(cell.name)
  if label == "" then return end
  local big = #label == 1 or KB_ARROW[cell.name]
  local font = KCAP_SMALL
  if big then font = KCAP_BIG end
  gfx.setFont(font)
  gfx.setColor(COL_KEY_LABEL)
  local ty = cell.y + (cell.h - font:getHeight()) / 2
  gfx.printf(label, cell.x, ty, cell.w, "center")
end

function kbKeyOutline(cell, dec)
  local x, y, w, h = cell.x, cell.y, cell.w, cell.h
  if dec and dec.glow then
    gfx.setColor(dec.glow)
    gfx.setLineWidth(3)
    gfx.rectangle("line", x, y, w, h, 5)
    gfx.setLineWidth(1)
  else
    gfx.setColor(COL_KEY_EDGE)
    gfx.rectangle("line", x, y, w, h, 5)
  end
end

function kbKeyFace(cell, bg, dec)
  gfx.setColor(bg)
  gfx.rectangle("fill", cell.x, cell.y, cell.w, cell.h, 5)
  kbKeyOutline(cell, dec)
  kbDrawLabel(cell)
end

function drawKey(cell, dec, sc)
  local bg = COL_KEY
  if dec and dec.bg then bg = dec.bg end
  local cx = cell.x + cell.w / 2
  local cy = cell.y + cell.h / 2
  gfx.push()
  gfx.translate(cx, cy)
  gfx.scale(sc, sc)
  gfx.translate(-cx, -cy)
  kbKeyFace(cell, bg, dec)
  gfx.pop()
end

-- A highlighted key (pulse or glow) is redrawn on a top layer
-- so it never z-fights with neighbours drawn after it.
function kbRaised(dec)
  return dec and (dec.pulse or dec.glow)
end

-- livecase = let letter keycaps follow the effective Caps/Shift
-- case (Caps game only); other scenes pass nil = always upper.
function drawKeyboard(deco, livecase)
  KB_LIVECASE = livecase
  for _, c in ipairs(KB.cells) do
    drawKey(c, deco and deco[c.name], 1)
  end
  for _, c in ipairs(KB.cells) do
    local dec = deco and deco[c.name]
    if kbRaised(dec) then
      drawKey(c, dec, dec.pulse or 1)
    end
  end
end

function keyRect(name)
  return KB.rect[name]
end

-- Expanding-ring success burst, b = { x, y, t } with t in
-- seconds counting down from 0.5.
function drawBurst(b)
  local p = 1 - b.t / 0.5
  local rad = 8 + p * 38
  local a = b.t / 0.5
  gfx.setColor(COL_BURST[1], COL_BURST[2], COL_BURST[3], a)
  gfx.setLineWidth(3)
  gfx.circle("line", b.x, b.y, rad)
  gfx.circle("line", b.x, b.y, rad * 0.55)
  gfx.setLineWidth(1)
end
