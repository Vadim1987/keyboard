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
-- Larger keycap fonts for the top-band target (Press/Find/Alt).
-- Monospace glyph font so 0/O and l/I/1 read clearly when the
-- child must FIND the key (the keyboard picture stays sans).
KCAP_T_H = 64
KCAP_T_BIG = getGlyphFont(40)
KCAP_T_SMALL = getGlyphFont(26)
kbBuildCells()

-- Effective case of letter keycaps: upper iff Caps XOR Shift.
function capsEffectiveUpper()
  if INPUT.shift then return not CAPS_STATE.on end
  return CAPS_STATE.on
end

function kbLabel(name)
  local l = KB_LABEL[name]
  if l then return l end
  if KB_SHIFTLABEL and INPUT.shift and SHIFT_MAP[name] then
    return SHIFT_MAP[name]
  end
  if #name == 1 then
    if KB_LIVECASE and isAlphaChar(name)
        and not capsEffectiveUpper() then
      return name
    end
    return string.upper(name)
  end
  return name
end

-- Shared keycap renderer. drawKeycap(cell, opts) draws ONE cap
-- at an arbitrary cell { x, y, w, h }: the on-board keys, the
-- top-band target, and Hunt's falling caps all go through it.
-- opts = { label, font, bg, glow, color, radius, scale, alpha }
-- is required; its fields are optional, but a label needs a
-- font. The caller owns cell geometry, layout, and any
-- glow-layering; this draws a single cap.
function kcapColor(c, a)
  gfx.setColor(c[1], c[2], c[3], (c[4] or 1) * a)
end

function kcapLabel(cell, opts, a)
  local label = opts.label
  if not label or label == "" then return end
  local font = opts.font
  gfx.setFont(font)
  kcapColor(opts.color or COL_KEY_LABEL, a)
  local ty = cell.y + (cell.h - font:getHeight()) / 2
  gfx.printf(label, cell.x, ty, cell.w, "center")
end

function kcapOutline(cell, opts, r, a)
  if opts.glow then
    kcapColor(opts.glow, a)
    gfx.setLineWidth(3)
    gfx.rectangle("line", cell.x, cell.y, cell.w, cell.h, r)
    gfx.setLineWidth(1)
  else
    kcapColor(COL_KEY_EDGE, a)
    gfx.rectangle("line", cell.x, cell.y, cell.w, cell.h, r)
  end
end

function kcapFace(cell, opts)
  local r = opts.radius or 5
  local a = opts.alpha or 1
  kcapColor(opts.bg or COL_KEY, a)
  gfx.rectangle("fill", cell.x, cell.y, cell.w, cell.h, r)
  kcapOutline(cell, opts, r, a)
  kcapLabel(cell, opts, a)
end

function drawKeycap(cell, opts)
  local sc = opts.scale or 1
  local cx = cell.x + cell.w / 2
  local cy = cell.y + cell.h / 2
  gfx.push()
  gfx.translate(cx, cy)
  gfx.scale(sc, sc)
  gfx.translate(-cx, -cy)
  kcapFace(cell, opts)
  gfx.pop()
end

-- On-board key: a thin wrapper over drawKeycap. Label and its
-- size follow the live keyboard rules (kbLabel); dec carries
-- the per-key bg/glow and the pulse scale.
function drawKey(cell, dec, sc)
  local label = kbLabel(cell.name)
  local big = #label == 1 or KB_ARROW[cell.name]
  drawKeycap(cell, {
    label = label,
    font = big and KCAP_BIG or KCAP_SMALL,
    bg = (dec and dec.bg) or COL_KEY,
    glow = dec and dec.glow,
    scale = sc
  })
end

-- A highlighted key (pulse or glow) is redrawn on a top layer
-- so it never z-fights with neighbours drawn after it.
function kbRaised(dec)
  return dec and (dec.pulse or dec.glow)
end

-- livecase = letter keycaps follow effective Caps/Shift case.
-- shiftlabel = number/punct keys show their shifted symbol
-- ONLY while a Shift key is held (Alt characters), so the label
-- never lies about current output. Other scenes pass nil.
function drawKeyboard(deco, livecase, shiftlabel)
  KB_LIVECASE = livecase
  KB_SHIFTLABEL = shiftlabel
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

-- Target keycap in the top band (Press/Find/Alt). The keyboard
-- picture below carries any glow; this is the calm "what to
-- press" cap. Space shows "Space"; specials use KB_LABEL.
function kbTargetLabel(name)
  if name == "space" then return "Space" end
  return kbLabel(name)
end

function kbTargetCell(label, font)
  local w = font:getWidth(label) + 28
  if w < KCAP_T_H then w = KCAP_T_H end
  local band = HEADER_Y1 - HEADER_Y0
  local cell = { }
  cell.x = (REF_W - w) / 2
  cell.y = HEADER_Y0 + (band - KCAP_T_H) / 2
  cell.w = w
  cell.h = KCAP_T_H
  return cell
end

-- Draw a top-band target cap from an already-resolved label;
-- big picks the large monospace glyph font (single glyph) over
-- the smaller one (multi-letter labels: Space, Bksp). Shared by
-- the find-key target (by key name) and Alt (by glyph).
function drawTargetCap(label, big)
  local font = big and KCAP_T_BIG or KCAP_T_SMALL
  drawKeycap(kbTargetCell(label, font), {
    label = label, font = font, radius = 8
  })
end

function drawKeycapTarget(name)
  local label = kbTargetLabel(name)
  drawTargetCap(label, #label == 1 or KB_ARROW[name])
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

-- Subtle win-gauge: a vertical thermometer in the right margin
-- (the left edge is clipped on current hardware), filling
-- bottom-up as the set is cleared. Clear of the bottom hints
-- and the lock cluster. Dark ink reads over every pastel.
-- Reused by the round-gauge exercises.
WGAUGE_W = 8

function winGaugeFrac(cleared, total)
  if total <= 0 then return 0 end
  local f = cleared / total
  if f < 0 then return 0 end
  if f > 1 then return 1 end
  return f
end

function drawWinGauge(cleared, total)
  local f = winGaugeFrac(cleared, total)
  local x = REF_W - 16
  local y0 = KBAND_Y0
  local h = KBAND_Y1 - KBAND_Y0
  local c = COL_KEY_LABEL
  gfx.setColor(c[1], c[2], c[3], 0.18)
  gfx.rectangle("fill", x, y0, WGAUGE_W, h, 4)
  gfx.setColor(c[1], c[2], c[3], 0.85)
  gfx.rectangle("fill", x, y0 + h * (1 - f), WGAUGE_W, h * f, 4)
end
