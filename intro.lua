-- Intro: the typewriter welcome. A passive demonstration the
-- child only watches: a simulated Caps Lock press, then the
-- fixed Latin heading COMPY types itself letter by letter,
-- lighting each bare letter key (honestly uppercase because
-- the demo shows Caps Lock on). Any key snaps the welcome
-- complete and shows Press Enter; Enter opens the menu.

INTRO = { phase = "caps", t = 0, idx = 0, simcaps = false }

function introEnter()
  INTRO.phase = "caps"
  INTRO.t = 0
  INTRO.idx = 0
  INTRO.simcaps = true
  SOUND.knock()
end

function introFinish()
  INTRO.idx = #WELCOME.heading
  INTRO.phase = "ready"
  INTRO.simcaps = false
end

function introNextLetter()
  INTRO.idx = INTRO.idx + 1
  INTRO.t = 0
  if INTRO.idx > #WELCOME.heading then
    introFinish()
  else
    SOUND.knock()
  end
end

function introTickCaps(dt)
  INTRO.t = INTRO.t + dt
  if INTRO.t >= WELCOME.caps_beat then
    INTRO.phase = "type"
    INTRO.t = 0
    introNextLetter()
  end
end

function introTickType(dt)
  INTRO.t = INTRO.t + dt
  if INTRO.t >= WELCOME.letter_beat then
    introNextLetter()
  end
end

function introUpdate(dt)
  if INTRO.phase == "caps" then
    introTickCaps(dt)
  elseif INTRO.phase == "type" then
    introTickType(dt)
  end
end

function introKeypressed(k)
  if INTRO.phase ~= "ready" then
    introFinish()
    return
  end
  if k == "return" or k == "kpenter" then
    gotoScene("menu")
  end
end

function introSpaced(n)
  local out = { }
  for i = 1, n do
    out[#out + 1] = WELCOME.heading:sub(i, i)
  end
  return table.concat(out, " ")
end

function introDeco()
  local deco = { }
  if INTRO.simcaps then
    deco.capslock = { bg = COL_WARM_DIM }
  end
  if INTRO.phase == "type" then
    local c = WELCOME.heading:sub(INTRO.idx, INTRO.idx)
    deco[string.lower(c)] = {
      bg = COL_WARM, glow = COL_GLOW
    }
  end
  return deco
end

function introDrawStatus()
  if INTRO.phase ~= "ready" then return end
  if WELCOME.line ~= "" then
    local band = { STATUS_Y0, STATUS_Y0 + 26 }
    drawBandText(WELCOME.line, band, UIFONT.status, COL_DIM)
  end
  local pband = { STATUS_Y0 + 28, STATUS_Y1 }
  drawBandText(WELCOME.prompt, pband, UIFONT.status, COL_TEXT)
end

function introDraw()
  drawBandText(introSpaced(INTRO.idx), HEADER_BAND,
    UIFONT.head, COL_TEXT)
  drawKeyboard(introDeco())
  drawIndicators(INTRO.simcaps or CAPS_STATE.on)
  introDrawStatus()
end

registerScene("intro", {
  enter = introEnter,
  update = introUpdate,
  draw = introDraw,
  keypressed = introKeypressed
})
