-- The falling-caps engine. Capital keycaps fall from the top;
-- the child types them, in ANY order, before they land. Full
-- canvas (no keyboard, no indicators). The teacher sets the
-- speed notch (-2..+2), which also sets the wave-length ceiling
-- lmax (2/3) and gauge promote. The child earns wave length via
-- a signed gauge: a catch adds 1, a miss subtracts 1. Reaching
-- +promote grows the wave a length, or AT lmax opens the win
-- screen (Enter = replay from wave 1); reaching -3 shrinks it
-- (never below 1). Background pastel tracks the speed notch.
-- Missed keys return more often (review), and a wrong press
-- books both the key pressed and one it stood in for. Keys
-- compare as physical constants (case ignored): a wrong key
-- bumps, a missed wave flashes red.
--
-- This file is the engine only: it registers no scene. The
-- games built on it -- hunt.lua and skip.lua -- each declare
-- their own scene descriptor and pass it to huntEnter, so
-- neither has to load the other.

HUNT = {
  chars = { },
  done = { },
  forbid = { },
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

-- The engine serves one game at a time, so the running game is
-- state. A game carries its own notch id (so progress is per
-- game), its teacher-notch bounds, and whether its waves mix in
-- forbidden caps. Each game file defines its own descriptor and
-- hands it to huntEnter, which is the only thing that sets this;
-- update and draw never run before a scene has entered.

HUNT_GAME = nil

-- Capital keycaps fall as squares sized from the glyph font, a
-- small gap apart; the cap bottom lands on the ground line.
-- Falling caps are enlarged board caps: height in px, width
-- follows the board letter-cap proportions.
HUNT_CAP = 56
HUNT_CAP_W = math.floor(HUNT_CAP * KB_STD_W / KB_STD_H)
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
  return HUNT_NOTCH[notchGet(HUNT_GAME.id)]
end

-- The pastel ramp level for the current notch (above floor).
-- Paint the background for the current level. A game may bring
-- its own ramp -- Asteroids plays in space, where the chrome
-- pastel would be wrong -- and the rest use the pastel. Called
-- wherever the level or the wave changes, so a scene never has
-- to repaint behind the engine.

function huntPaintSky()
  local ramp = HUNT_GAME.ramp
  if ramp then
    pastelSetTarget(ramp[huntColorLevel()])
  else
    pastelLevel(huntColorLevel())
  end
end

function huntColorLevel()
  return notchGet(HUNT_GAME.id) - HUNT_GAME.lo
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

-- Skip the red ones: mark caps forbidden. One wave never goes
-- all-forbidden -- there is always at least one cap to catch,
-- so a wave is always winnable. A lone cap is never forbidden
-- (nothing to do but wait, which reads as a stall).
function huntShuffledSlots(len)
  local idx = { }
  for i = 1, len do idx[i] = i end
  for i = len, 2, -1 do
    local j = love.math.random(1, i)
    idx[i], idx[j] = idx[j], idx[i]
  end
  return idx
end

function huntMarkForbidden(len)
  local out = { }
  if not HUNT_GAME.forbid or len < 2 then return out end
  local idx = huntShuffledSlots(len)
  for i = 1, love.math.random(1, len - 1) do
    out[idx[i]] = true
  end
  return out
end

-- Apply a deferred teacher-notch reset at the next spawn. The
-- in-flight wave finishes without changing the fresh gauge.
function huntApplyReset()
  if HUNT.reset then
    HUNT.length = 1
    HUNT.g = 0
    HUNT.count = 0
    HUNT.reset = false
  end
end

-- Spawn the next wave. Length is clamped to the current notch's
-- lmax, so a notch change takes effect here (never mid-fall).
-- The background pastel syncs to the current notch.
function huntSpawn()
  local cfg = huntCfg()
  huntApplyReset()
  HUNT.length = math.max(1, math.min(HUNT.length, cfg.lmax))
  HUNT.chars = huntBuildWave(HUNT.length)
  HUNT.forbid = huntMarkForbidden(HUNT.length)
  HUNT.done = { }
  HUNT.bang = nil
  HUNT.typed = 0
  HUNT.fumbled = false
  HUNT.y = HUNT_SPAWN_Y
  HUNT.fall = cfg.fall
  HUNT.phase = "fall"
  HUNT.anim = 0
  huntPaintSky()
end

function huntEnter(game)
  HUNT_GAME = game
  HUNT.length = 1
  HUNT.g = 0
  HUNT.reset = false
  HUNT.review = { }
  HUNT.prev = { }
  HUNT.count = 0
  HUNT.fw = { }
  huntPaintSky()
  pastelSnap()
  huntSpawn()
end

-- One correct press toward retiring a key from review.
function huntReviewHit(ch)
  local n = HUNT.review[ch]
  if not n then return end
  if n <= 1 then
    HUNT.review[ch] = nil
  else
    HUNT.review[ch] = n - 1
  end
end

-- The caps to catch in this wave; forbidden ones do not count,
-- they are there to be left alone.
function huntWanted()
  local n = 0
  for i = 1, #HUNT.chars do
    if not HUNT.forbid[i] then n = n + 1 end
  end
  return n
end

-- A cap still standing and meant to be caught.
function huntPending(i)
  return not HUNT.done[i] and not HUNT.forbid[i]
end

-- The keys still standing when a wave is missed go to review.
-- A forbidden cap is not a miss: it was never to be pressed.
function huntReviewMissed()
  for i, ch in ipairs(HUNT.chars) do
    if huntPending(i) then
      HUNT.review[ch] = HUNT_CFG.review_hits
    end
  end
end

-- First-try mastery, as in Press/Find: a clean press retires
-- the letter from review; once a wave is fumbled nothing in it
-- retires, since the wrong press already booked the review.
function huntCorrect(ch)
  if HUNT.fumbled then return end
  huntReviewHit(ch)
end

-- The leftmost cap still standing: with a free order any
-- standing cap was fair, so this is the one a wrong press
-- stood in for.
function huntStanding()
  for i, ch in ipairs(HUNT.chars) do
    if huntPending(i) then return ch end
  end
  return nil
end

-- The first wrong press of a wave books BOTH keys into review:
-- the one pressed and the one it stood in for. Later wrong
-- presses in the same wave only knock.
function huntWrongPress(k)
  SOUND.reject()
  if HUNT.fumbled then return end
  HUNT.fumbled = true
  HUNT.review[k] = HUNT_CFG.review_hits
  local ch = huntStanding()
  if ch then HUNT.review[ch] = HUNT_CFG.review_hits end
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

-- The top-length win: celebratory tune + firework, then the
-- completion screen (Enter = replay).
function huntWin()
  SOUND.wow()
  fwStart(HUNT)
  HUNT.phase = "done"
end

-- A catch fills the gauge: below lmax, +promote grows the wave;
-- at lmax, +promote opens the win screen.
function huntGaugeCatch()
  if HUNT.reset then return end
  local cfg = huntCfg()
  if HUNT.length < cfg.lmax then
    HUNT.g = HUNT.g + 1
    if HUNT.g >= cfg.promote then huntGrow() end
  elseif HUNT.g < cfg.promote then
    HUNT.g = HUNT.g + 1
    if HUNT.g >= cfg.promote then huntWin() end
  end
end

-- A miss drains the gauge: -demote shrinks the wave (above
-- length 1); at length 1 it floors at demote (no failure).
function huntGaugeMiss()
  if HUNT.reset then return end
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
  if HUNT.phase ~= "done" then huntChime() end
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

function huntTickBang(dt)
  HUNT.bang.t = HUNT.bang.t - dt
  if HUNT.bang.t <= 0 then HUNT.bang = nil end
end

function huntUpdate(dt)
  fwUpdate(HUNT, dt)
  if HUNT.bang then huntTickBang(dt) end
  if HUNT.phase == "done" then return end
  if HUNT.phase == "fall" then
    huntTickFall(dt)
  else
    huntTickGap(dt)
  end
end

function huntDone()
  return HUNT.phase == "done"
end

-- Replay the same notch from wave 1.
function huntReplay()
  HUNT.length = 1
  HUNT.g = 0
  HUNT.count = 0
  HUNT.fw = { }
  huntSpawn()
end

-- Completion-screen keys: Enter|R replays this notch.
function huntDoneKey(k)
  if k == "return" or k == "kpenter" or k == "r" then
    huntReplay()
  end
end

-- A standing cap for this key, or nil. With a free order the
-- leftmost matching cap is taken, so a repeated letter clears
-- left to right.
function huntFindCap(k)
  for i, ch in ipairs(HUNT.chars) do
    if ch == k and not HUNT.done[i] then return i end
  end
  return nil
end

-- A non-final correct key ticks softly; the final one completes
-- the wave (chime or win).
function huntTypeCap(i, k)
  HUNT.done[i] = true
  HUNT.typed = HUNT.typed + 1
  huntCorrect(k)
  if HUNT.typed >= huntWanted() then
    huntCatch()
  else
    SOUND.match()
  end
end

-- Pressing a forbidden cap: the bang at that cap, the key into
-- review, and the wave is lost at once -- leaving it alone was
-- the whole task, so there is nothing left to finish.
function huntBangAt(i)
  HUNT.bang = {
    x = huntCapX(i) + HUNT_CAP_W / 2,
    y = HUNT.y,
    t = BANG_T
  }
  SOUND.reject()
  HUNT.review[HUNT.chars[i]] = HUNT_CFG.review_hits
  huntMiss()
end

function huntKeypressed(k)
  if huntDone() then
    huntDoneKey(k)
    return
  end
  if HUNT.phase ~= "fall" then return end
  local i = huntFindCap(k)
  if i and HUNT.forbid[i] then
    huntBangAt(i)
  elseif i then
    huntTypeCap(i, k)
  elseif not isMod(k) and k ~= "capslock" then
    huntWrongPress(k)
  end
end

-- A notch's speed change is immediate, including the wave in
-- flight. A real change defers the structural reset until the
-- next spawn; a done-screen change resumes play immediately.
function huntOnNotch(delta)
  local old = notchGet(HUNT_GAME.id)
  notchShift(HUNT_GAME.id, delta, HUNT_GAME.lo, HUNT_GAME.hi)
  if notchGet(HUNT_GAME.id) == old then return end
  huntPaintSky()
  if huntDone() then
    huntReplay()
    return
  end
  HUNT.reset = true
  if HUNT.phase == "fall" then
    HUNT.fall = huntCfg().fall
  end
end

-- A couple of quick flashes on a miss (no sound) -- a gentle
-- "that one got away" cue, not a punishment.
function huntMissAlpha()
  if HUNT.anim % 0.25 < 0.13 then return 1 end
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
  if HUNT.phase == "missed" then return COL_RED end
  if HUNT.done[i] then return COL_OK end
  return CAP_LABEL
end

function huntWaveWidth()
  local n = #HUNT.chars
  return n * HUNT_CAP_W + (n - 1) * HUNT_CAP_GAP
end

-- One falling cap: the engraved board cap, enlarged; the
-- state ramp colors the engraving (pending/typed/missed).
-- Skip the red ones marks every cap by class: red around the
-- ones to leave, a fainter green around the ones to catch, so
-- the red reads first in a mixed row. Hunt marks nothing.
function huntCapHalo(i)
  if not HUNT_GAME.forbid then return nil end
  if HUNT.forbid[i] then return SKIP_FORBID_COL end
  return SKIP_WANT_COL
end

function huntDrawCap(i, ch, x, a)
  local cell = { x = x, y = HUNT.y - HUNT_CAP / 2,
    w = HUNT_CAP_W, h = HUNT_CAP }
  drawKeycap(cell, {
    name = ch,
    unit = HUNT_CAP / KB_STD_H,
    color = huntCapColor(i),
    halo = huntCapHalo(i),
    alpha = a
  })
end

-- The left edge of cap i in the row.
function huntCapX(i)
  local x0 = (REF_W - huntWaveWidth()) / 2
  return x0 + (i - 1) * (HUNT_CAP_W + HUNT_CAP_GAP)
end

function huntDrawRow(a)
  for i, ch in ipairs(HUNT.chars) do
    huntDrawCap(i, ch, huntCapX(i), a)
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
    fkDrawDoneScreen()
    fwDraw(HUNT)
    return
  end
  huntDrawGround()
  huntDrawWave()
  if HUNT.bang then drawBang(HUNT.bang) end
  drawWinGauge(HUNT.g, huntCfg().promote)
  huntDrawCount()
  fwDraw(HUNT)
  fkDrawExitHint()
end

