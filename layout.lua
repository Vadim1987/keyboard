-- Screen layout grid and shared UI fonts.
-- All scene geometry is expressed in this 960x540 reference
-- canvas; main.lua scales it uniformly to the real resolution.

REF_W = 960
REF_H = 540

-- Three horizontal bands (reference y coordinates).
HEADER_Y0 = 16
HEADER_Y1 = 104
KBAND_Y0 = 112
KBAND_Y1 = 456
STATUS_Y0 = 464
STATUS_Y1 = 524

-- Band ranges as { y0, y1 } for drawBandText.
HEADER_BAND = { HEADER_Y0, HEADER_Y1 }
STATUS_BAND = { STATUS_Y0, STATUS_Y1 }

FONT_PATH = "assets/fonts/SarasaGothicJ-Bold.ttf"

-- Shared UI fonts, created once at load.
UIFONT = { }
UIFONT.head = gfx.newFont(FONT_PATH, 60)
UIFONT.big = gfx.newFont(FONT_PATH, 72)
UIFONT.menu = gfx.newFont(FONT_PATH, 34)
UIFONT.status = gfx.newFont(FONT_PATH, 24)
UIFONT.count = gfx.newFont(FONT_PATH, 22)

-- Draw text horizontally centered across the reference width,
-- vertically centered in band { y0, y1 }, with font/color.
function drawBandText(text, band, font, color)
  gfx.setFont(font)
  gfx.setColor(color)
  local h = font:getHeight()
  local y = band[1] + (band[2] - band[1] - h) / 2
  gfx.printf(text, 0, y, REF_W, "center")
end
