-- Mini-game 3: Hunt the falling objects. Capital keycaps fall
-- from the top; the child types each before it lands. Full
-- canvas (no keyboard, no indicators). Two independent axes:
-- the win screen climbs a progression notch (-2..+2) that
-- sets the wave-length ceiling lmax (2/3), the gauge promote,
-- and a base fall; the teacher chord scales that fall by a
-- speed step, uniform across all progression levels. The
-- child earns wave length via a signed gauge: a catch adds 1,
-- a miss subtracts 1. Reaching +promote grows the wave a
-- length, or AT lmax opens the win screen (Tab = next level,
-- Enter = replay from wave 1); reaching -3 shrinks it (never
-- below 1). Background pastel tracks the progression notch.
-- Missed or
-- fumbled keys return more often (review). Keys compare as
-- physical constants (case ignored): a wrong key bumps, a
-- missed wave flashes red.

HUNT = {
  chars = { },
  typed = 0,
  fumbled = false,
  y = 0,
  fall = 5,
  phase = "fall",
  anim = 0,
  length = 1,
  g = 0,
  reset = false,
  review = { },
  prev = { },
  count = 0,
  fw = { }
}

-- Advance-screen config; the shared find-key helpers
-- (gaugeAtTop / fkDoneTabLabel / fkGotoNext) read id/lo/hi.
-- Hunt's notch is now player-facing (the win screen climbs it).

HUNT_SCENE = { id = "hunt", lo = -2, hi = 2 }

-- Teacher speed level: an index into HUNT_SPD_MULT, moved by
-- the chord. File-scope so it holds across re-entry and resets
-- to the default only when the program restarts (this file is
-- loaded once).

HUNT_SPD = HUNT_SPD_DEF

-- Capital keycaps fall as squares sized from the glyph font, a
-- small gap apart; the cap bottom lands on the ground line.

HUNT_CAP_FONT = getGlyphFont(FONT_BIG)
HUNT_CAP = HUNT_CAP_FONT:getHeight() + 16
HUNT_CAP_GAP = 6

-- Game-owned catch chime: win.ogg pitched up -- lighter than
-- old correct.ogg, a better match for the toggle ticks, and
-- brighter to convey speed (11.5 has setPitch). Built at load.

HUNT_CHIME = love.audio.newSource(
  "assets/sounds/win.ogg", "static")
HUNT_CHIME:setPitch(1.35)

function huntChime()
  love.audio.stop(HUNT_CHIME)
  love.audio.play(HUNT_CHIME)
end

function huntCfg()
  return HUNT_NOTCH[notchGet("hunt")]
end

-- The pastel ramp level for the current notch (above floor).

function huntColorLevel()
  return notchGet("hunt") - HUNT_SCENE.lo
end

-- The current teacher speed multiplier applied to base fall.

function huntSpeedMult()
  return HUNT_SPD_MULT[HUNT_SPD]
end

-- Step the speed axis, clamped to its range.

function huntSpeedShift(delta)
  local v = HUNT_SPD + delta
  HUNT_SPD = math.max(HUNT_SPD_LO, math.min(HUNT_SPD_HI, v))
end

-- A fresh random letter not already used in this wave.

function huntFreshChar(used)
  local n = #HUNT_CHARS
  local s = love.math.random(n)
  for j = 0, n - 1 do
    local ch = HUNT_CHARS[(s + j - 1) % n + 1]
    if not used[ch] then return ch end
  end
  return HUNT_CHARS[s]
end

-- A review letter not already in the wave (fresh if none).

function huntReviewChar(used)
  local keys = { }
  for ch in pairs(HUNT.review) do
    if not used[ch] then keys[#keys + 1] = ch end
  end
  if #keys == 0 then return huntFreshChar(used) end
  return keys[love.math.random(#keys)]
end

-- Which slot (1..len) shows a review letter, or 0 for none. At
-- most one review letter per wave keeps variety: a hard letter
-- recurs but always in fresh company, never a "TT".

function huntReviewSlot(len)
  if next(HUNT.review) and love.math.random() < 0.5 then
    return love.math.random(len)
  end
  return 0
end

-- A new wave never reuses the previous wave's letters, so a key
-- (including a missed/review one) never repeats back-to-back.

function huntUsedFromPrev()
  local used = { }
  for _, ch in ipairs(HUNT.prev) do
    used[ch] = true
  end
  return used
end

function huntPickChar(isReview, used)
  if isReview then return huntReviewChar(used) end
  return huntFreshChar(used)
end

-- A wave of distinct letters, at most one from review, none
-- repeating the previous wave (HUNT.prev).

function huntBuildWave(len)
  local chars = { }
  local used = huntUsedFromPrev()
  local slot = huntReviewSlot(len)
  for i = 1, len do
    chars[i] = huntPickChar(i == slot, used)
    used[chars[i]] = true
  end
  HUNT.prev = chars
  return chars
end

-- Spawn the next wave. Length is clamped to the current notch's
-- lmax, so a notch change takes effect here (never mid-fall).
-- The background pastel syncs to the current notch.

function huntSpawn()
  local cfg = huntCfg()
  HUNT.length = math.max(1, math.min(HUNT.length, cfg.lmax))
  HUNT.chars = huntBuildWave(HUNT.length)
  HUNT.typed = 0
  HUNT.fumbled = false
  HUNT.y = HUNT_SPAWN_Y
  HUNT.fall = cfg.fall * huntSpeedMult()
  HUNT.phase = "fall"
  HUNT.anim = 0
  pastelLevel(huntColorLevel())
end

function huntEnter()
  notchEnterReset("hunt")
  HUNT.length = 1
  HUNT.g = 0
  HUNT.review = { }
  HUNT.prev = { }
  HUNT.count = 0
  HUNT.fw = { }
  pastelLevel(huntColorLevel())
  pastelSnap()
  huntSpawn()
end

-- One correct press toward retiring a key from review.

function huntReviewHit(ch)
  local n = HUNT.review[ch]
  if not n then 
    return 
  end
  if n <= 1 then
    HUNT.review[ch] = nil
  else
    HUNT.review[ch] = n - 1
  end
end

-- The untyped keys of a missed wave go into review.

function huntReviewMissed()
  for i = HUNT.typed + 1, #HUNT.chars do
    HUNT.review[HUNT.chars[i]] = HUNT_CFG.review_hits
  end
end

-- A correct keystroke (first-try mastery, as in Press/Find): a
-- clean one progresses the letter out of review; one typed only
-- after a wrong press marks it hard and (re)adds it.

function huntCorrect(ch)
  if HUNT.fumbled then
    HUNT.review[ch] = HUNT_CFG.review_hits
    HUNT.fumbled = false
  else
    huntReviewHit(ch)
  end
end

-- Grow / shrink the wave by one length; the gauge resets, and
-- the spawning wave repaints the background.

function huntGrow()
  HUNT.length = HUNT.length + 1
  HUNT.g = 0
end

-- A demote keeps the gauge two-thirds full, so a child who just
-- had a bad streak at a comfortable length climbs back quickly.

function huntShrink()
  HUNT.length = HUNT.length - 1
  HUNT.g = math.floor(huntCfg().promote * 2 / 3)
end

-- The top-length win: the celebratory tune + firework, and the
-- advance screen (Tab = faster notch / Enter = replay).

function huntWin()
  SOUND.wow()
  fwStart(HUNT)
  HUNT.phase = "done"
end

-- A catch fills the gauge: below lmax, +promote grows the wave;
-- at lmax, +promote opens the win screen.

function huntGaugeCatch()
  local cfg = huntCfg()
  if HUNT.length < cfg.lmax then
    HUNT.g = HUNT.g + 1
    if HUNT.g >= cfg.promote then huntGrow() 
    end
  elseif HUNT.g < cfg.promote then
    HUNT.g = HUNT.g + 1
    if HUNT.g >= cfg.promote then huntWin() 
    end
  end
end

-- A miss drains the gauge: -demote shrinks the wave (above
-- length 1); at length 1 it floors at demote (no failure).

function huntGaugeMiss()
  HUNT.g = HUNT.g - 1
  if HUNT.length > 1 then
    if HUNT.g <= HUNT_CFG.demote then huntShrink() end
  elseif HUNT.g < HUNT_CFG.demote then
    HUNT.g = HUNT_CFG.demote
  end
end

-- A non-winning catch plays the bright chime; the winning catch
-- (gauge full at lmax) plays wow + firework instead (huntWin).

function huntCatch()
  HUNT.count = HUNT.count + 1
  HUNT.phase = "caught"
  HUNT.anim = 0
  huntGaugeCatch()
  if HUNT.phase ~= "done" then 
    huntChime() 
  end
end

function huntMiss()
  huntReviewMissed()
  huntGaugeMiss()
  HUNT.phase = "missed"
  HUNT.anim = 0
end

-- Caps land with their bottom on the ground line (not their
-- center), so they sit on the floor instead of sinking through.

function huntWaveHalf()
  return HUNT_CAP / 2
end

function huntTickFall(dt)
  local floor = HUNT_GROUND_Y - huntWaveHalf()
  local span = floor - HUNT_SPAWN_Y
  HUNT.y = HUNT.y + (span / HUNT.fall) * dt
  if HUNT.y >= floor then
    HUNT.y = floor
    huntMiss()
  end
end

function huntTickGap(dt)
  HUNT.anim = HUNT.anim + dt
  if HUNT.anim >= HUNT_CFG.gap then
    huntSpawn()
  end
end

function huntUpdate(dt)
  fwUpdate(HUNT, dt)
  if HUNT.phase == "done" then 
    return 
  end
  if HUNT.phase == "fall" then
    huntTickFall(dt)
  else
    huntTickGap(dt)
  end
end

function huntDone()
  return HUNT.phase == "done"
end

-- Replay the same notch from wave 1; climb steps the notch up
-- first. Both clear the firework and start a fresh wave.

function huntReplay()
  HUNT.length = 1
  HUNT.g = 0
  HUNT.count = 0
  HUNT.fw = { }
  huntSpawn()
end

function huntClimb()
  notchShift("hunt", 1, HUNT_SCENE.lo, HUNT_SCENE.hi)
  huntReplay()
end

-- Advance-screen keys: Tab climbs a notch (next game at top,
-- via the shared helper); Enter|R replays this notch.

function huntDoneKey(k)
  if k == "tab" then
    if gaugeAtTop(HUNT_SCENE) then
      fkGotoNext(HUNT_SCENE)
    else
      huntClimb()
    end
  elseif k == "return" or k == "kpenter" or k == "r" then
    huntReplay()
  end
end

-- A non-final correct key ticks softly; the final one completes
-- the wave (chime or win).

function huntTypeChar(k)
  HUNT.typed = HUNT.typed + 1
  huntCorrect(k)
  if HUNT.typed >= #HUNT.chars then
    huntCatch()
  else
    SOUND.match()
  end
end

function huntKeypressed(k)
  if huntDone() then
    huntDoneKey(k)
    return
  end
  if HUNT.phase ~= "fall" then 
    return 
  end
  if k == HUNT.chars[HUNT.typed + 1] then
    huntTypeChar(k)
  elseif not isMod(k) and k ~= "capslock" then
    SOUND.reject()
    HUNT.fumbled = true
  end
end

-- The teacher chord moves the SPEED axis, not the progression
-- notch. The change is immediate: it re-scales the in-flight
-- wave's fall at once (pressing "slower" eases the current wave
-- now). It never resets the gauge or wave length -- speed is
-- independent of progression. A saturated chord is a no-op.

function huntOnNotch(delta)
  local old = HUNT_SPD
  huntSpeedShift(delta)
  if HUNT_SPD == old then 
    return 
  end
  if HUNT.phase == "fall" then
    HUNT.fall = huntCfg().fall * huntSpeedMult()
  end
end

-- A couple of quick flashes on a miss (no sound) -- a gentle
-- "that one got away" cue, not a punishment.

function huntMissAlpha()
  if HUNT.anim % 0.25 < 0.13 then 
    return 1 
  end
  return 0.2
end

-- Pop on catch (brief scale-up + fade); red flash on miss.

function huntWaveAnim()
  if HUNT.phase == "caught" then
    local p = math.min(HUNT.anim / 0.2, 1)
    return 1 + p * 0.5, 1 - p
  end
  if HUNT.phase == "missed" then
    return 1, huntMissAlpha()
  end
  return 1, 1
end

function huntDrawGround()
  gfx.setColor(COL_GROUND)
  gfx.setLineWidth(2)
  gfx.line(0, HUNT_GROUND_Y, REF_W, HUNT_GROUND_Y)
  gfx.setLineWidth(1)
end

function huntCapColor(i)
  if HUNT.phase == "missed" then 
    return COL_RED 
  end
  if i <= HUNT.typed then 
    return COL_OK 
  end
  return COL_KEY_LABEL
end

function huntWaveWidth()
  local n = #HUNT.chars
  return n * HUNT_CAP + (n - 1) * HUNT_CAP_GAP
end

-- One falling cap, drawn through the shared keycap renderer.

function huntDrawCap(i, ch, x, a)
  local cell = { x = x, y = HUNT.y - HUNT_CAP / 2,
    w = HUNT_CAP, h = HUNT_CAP }
  drawKeycap(cell, {
    label = string.upper(ch),
    font = HUNT_CAP_FONT,
    color = huntCapColor(i),
    radius = 8, alpha = a
  })
end

function huntDrawRow(a)
  local x = (REF_W - huntWaveWidth()) / 2
  for i, ch in ipairs(HUNT.chars) do
    huntDrawCap(i, ch, x, a)
    x = x + HUNT_CAP + HUNT_CAP_GAP
  end
end

-- The whole wave pops (catch) / flashes (miss) as one unit, so
-- the scale + alpha wrap the row rather than each cap.
function huntDrawWave()
  local sc, a = huntWaveAnim()
  if a <= 0 then return end
  local cx = REF_W / 2
  gfx.push()
  gfx.translate(cx, HUNT.y)
  gfx.scale(sc, sc)
  gfx.translate(-cx, -HUNT.y)
  huntDrawRow(a)
  gfx.pop()
end

function huntDrawCount()
  gfx.setFont(getFont(FONT_COUNT))
  gfx.setColor(COL_DIM)
  gfx.printf(HUNT.count, 20, 16, 200, "left")
end

function huntDraw()
  if huntDone() then
    fkDrawDoneScreen(fkDoneTabLabel(nil, HUNT_SCENE))
    fwDraw(HUNT)
    return
  end
  huntDrawGround()
  huntDrawWave()
  drawWinGauge(HUNT.g, huntCfg().promote)
  huntDrawCount()
  fwDraw(HUNT)
  fkDrawExitHint()
end

registerScene("hunt", {
  enter = huntEnter,
  update = huntUpdate,
  draw = huntDraw,
  keypressed = huntKeypressed,
  onNotch = huntOnNotch,
  noHint = huntDone,
  timed = true
})
