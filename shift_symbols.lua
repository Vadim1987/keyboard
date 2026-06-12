-- Mini-game 6: Symbols with Shift. Extends the Shift chord to
-- the symbol layer -- the marks only Shift reaches. A shifted
-- symbol is shown (e.g. ! over 1, ? over /); the child makes it
-- with Shift + the base key. Caps Lock doesn't affect these, so
-- it is ignored here (never hinted). At hinting notches the
-- target's BASE key and a Shift key glow together (the pair to
-- press), and the keys show their shifted labels. Targets are
-- single symbols at every notch.

SHIFT_SYMBOLS = {
  phase = "play",
  pause = 0,
  burst = nil,
  pool = { },
  idx = 0,
  target = "",
  base = "",
  clean = true,
  miss = 0,
  hint = 0
}

function shiftSymCfg()
  return SYMBOL_NOTCH[notchGet("shift_symbols")]
end

function shiftSymShuffle()
  SHIFT_SYMBOLS.pool = { }
  for _, k in ipairs(SYM_SETS[shiftSymCfg().set]) do
    SHIFT_SYMBOLS.pool[#SHIFT_SYMBOLS.pool + 1] = k
  end
  shuffleInPlace(SHIFT_SYMBOLS.pool)
  SHIFT_SYMBOLS.idx = 0
end

function shiftSymSpawn()
  SHIFT_SYMBOLS.idx = SHIFT_SYMBOLS.idx + 1
  if SHIFT_SYMBOLS.idx > #SHIFT_SYMBOLS.pool then
    shiftSymShuffle()
    SHIFT_SYMBOLS.idx = 1
  end
  SHIFT_SYMBOLS.base = SHIFT_SYMBOLS.pool[SHIFT_SYMBOLS.idx]
  SHIFT_SYMBOLS.target = SHIFT_MAP[SHIFT_SYMBOLS.base]
  SHIFT_SYMBOLS.clean = true
  SHIFT_SYMBOLS.miss = 0
  SHIFT_SYMBOLS.phase = "play"
end

function shiftSymEnter()
  notchAutoReset("shift_symbols")
  shiftSymShuffle()
  SHIFT_SYMBOLS.burst = nil
  SHIFT_SYMBOLS.hint = 0
  shiftSymSpawn()
end

function shiftSymAuto(outcome)
  local d = notchAutoResult("shift_symbols", -2, 2, outcome,
    CAPS_HINT_COOLDOWN)
  if d ~= 0 then shiftSymShuffle() end
end

-- Clean = symbol via Shift first try; struggle = 2+ misses;
-- anything between is a "none" that breaks both streaks.
function shiftSymScore()
  if SHIFT_SYMBOLS.clean then
    shiftSymAuto("clean")
  elseif SHIFT_SYMBOLS.miss >= 2 then
    shiftSymAuto("struggle")
  else
    shiftSymAuto("none")
  end
end

function shiftSymHit()
  local r = keyRect(SHIFT_SYMBOLS.base)
  if r then
    SHIFT_SYMBOLS.burst = {
      x = r.x + r.w / 2, y = r.y + r.h / 2, t = 0.5
    }
  end
  SOUND.match()
  shiftSymScore()
  SHIFT_SYMBOLS.phase = "pause"
  SHIFT_SYMBOLS.pause = CF_PAUSE
end

-- Accept the symbol only with Shift held (Caps Lock cannot make
-- it). A wrong char is a silent miss; at notch 0 a miss flashes
-- the base+Shift hint.
function shiftSymTextinput(ch)
  if SHIFT_SYMBOLS.phase ~= "play" then return end
  if ch == SHIFT_SYMBOLS.target and INPUT.shift then
    shiftSymHit()
    return
  end
  SHIFT_SYMBOLS.clean = false
  SHIFT_SYMBOLS.miss = SHIFT_SYMBOLS.miss + 1
  if shiftSymCfg().hint == "miss" then
    SHIFT_SYMBOLS.hint = 0.6
  end
end

function shiftSymOnNotch(delta)
  local old = notchGet("shift_symbols")
  if notchShift("shift_symbols", delta, -2, 2) ~= old then
    notchAutoReset("shift_symbols")
    shiftSymShuffle()
  end
end

function shiftSymUpdate(dt)
  notchAutoTick("shift_symbols", dt)
  if SHIFT_SYMBOLS.hint > 0 then
    SHIFT_SYMBOLS.hint = SHIFT_SYMBOLS.hint - dt
  end
  if SHIFT_SYMBOLS.burst then
    SHIFT_SYMBOLS.burst.t = SHIFT_SYMBOLS.burst.t - dt
    if SHIFT_SYMBOLS.burst.t <= 0 then
      SHIFT_SYMBOLS.burst = nil
    end
  end
  if SHIFT_SYMBOLS.phase == "pause" then
    SHIFT_SYMBOLS.pause = SHIFT_SYMBOLS.pause - dt
    if SHIFT_SYMBOLS.pause <= 0 then shiftSymSpawn() end
  end
end

-- Standing at "always" notches; only after a miss at notch 0.
function shiftSymHintShown()
  local h = shiftSymCfg().hint
  if h == "always" then return true end
  if h == "miss" then return SHIFT_SYMBOLS.hint > 0 end
  return false
end

function shiftSymShiftDec()
  if INPUT.shift then return { bg = COL_WARM_DIM } end
  if shiftSymHintShown() then
    return { glow = COL_WARM_DIM }
  end
  return nil
end

function shiftSymDeco()
  local deco = { }
  local sd = shiftSymShiftDec()
  if sd then
    deco.lshift = sd
    deco.rshift = sd
  end
  if shiftSymHintShown() then
    deco[SHIFT_SYMBOLS.base] = { glow = COL_WARM }
  end
  return deco
end

function shiftSymDraw()
  drawKeyboard(shiftSymDeco(), false, true)
  drawBandText(SHIFT_SYMBOLS.target, HEADER_BAND,
    getGlyphFont(FONT_BIG), COL_TEXT)
  if SHIFT_SYMBOLS.burst then drawBurst(SHIFT_SYMBOLS.burst) end
  drawIndicators(CAPS_STATE.on)
end

registerScene("shift_symbols", {
  enter = shiftSymEnter,
  update = shiftSymUpdate,
  draw = shiftSymDraw,
  textinput = shiftSymTextinput,
  onNotch = shiftSymOnNotch
})
