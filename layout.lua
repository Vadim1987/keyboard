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

-- Semantic UI font sizes (reference pixels).
FONT_HEAD = 60
FONT_BIG = 72
FONT_MENU = 34
FONT_STATUS = 24
FONT_COUNT = 22
FONT_HELP = 30
FONT_HINT = 20

-- Fonts are created on demand and cached by pixel size, so a
-- size that no scene uses is never rasterized (the device is
-- low-end and font creation is the costly part of boot).
FONTS = { }

function getFont(px)
  local font = FONTS[px]
  if not font then
    font = gfx.newFont(FONT_PATH, px)
    FONTS[px] = font
  end
  return font
end

-- Draw text horizontally centered across the reference width,
-- vertically centered in band { y0, y1 }, with font/color.
function drawBandText(text, band, font, color)
  gfx.setFont(font)
  gfx.setColor(color)
  local h = font:getHeight()
  local y = band[1] + (band[2] - band[1] - h) / 2
  gfx.printf(text, 0, y, REF_W, "center")
end
