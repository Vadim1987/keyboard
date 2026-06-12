-- Mini-game 3: Hunt the falling objects. Characters fall from
-- the top; the child types each before it reaches the ground.
-- Full canvas (no keyboard, no indicators). The notch sets the
-- fall speed (-2..+2); the wave length (1..3) adapts by streak
-- (huntadapt.lua). Keys the child misses or fumbles (catches
-- only after a wrong press) come back more often until pressed
-- cleanly a few times. Input compares physical key constants
-- (Caps/Shift/case ignored). A missed wave flashes red.

HUNT = {
  chars = { },
  typed = 0,
  fumbled = false,
  y = 0,
  fall = 5,
  phase = "fall",
  anim = 0,
  length = 1,
  cstreak = 0,
  mstreak = 0,
  review = { },
  count = 0
}

-- Game-owned, higher-pitched chime for a catch -- brighter than
-- the Choose/Find chime, to convey speed (11.5 supports
-- setPitch). Created once when the game loads.
HUNT_CHIME = love.audio.newSource(
  "assets/sounds/correct.ogg", "static")
HUNT_CHIME:setPitch(1.35)

function huntChime()
  love.audio.stop(HUNT_CHIME)
  love.audio.play(HUNT_CHIME)
end

function huntCfg()
  return HUNT_NOTCH[notchGet("hunt")]
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
  if next(HUNT.review) and love.math.random() < 0.7 then
    return love.math.random(len)
  end
  return 0
end

-- A wave of distinct letters, at most one drawn from review.
function huntBuildWave(len)
  local chars = { }
  local used = { }
  local slot = huntReviewSlot(len)
  for i = 1, len do
    if i == slot then
      chars[i] = huntReviewChar(used)
    else
      chars[i] = huntFreshChar(used)
    end
    used[chars[i]] = true
  end
  return chars
end

-- Spawn the next wave. Length is clamped to the current notch's
-- range, so a notch change takes effect here (never mid-fall).
function huntSpawn()
  local cfg = huntCfg()
  HUNT.length = math.max(cfg.lmin,
    math.min(HUNT.length, cfg.lmax))
  HUNT.chars = huntBuildWave(HUNT.length)
  HUNT.typed = 0
  HUNT.fumbled = false
  HUNT.y = HUNT_SPAWN_Y
  HUNT.fall = cfg.fall
  HUNT.phase = "fall"
  HUNT.anim = 0
end

function huntEnter()
  HUNT.length = huntCfg().lmin
  HUNT.cstreak = 0
  HUNT.mstreak = 0
  HUNT.review = { }
  HUNT.count = 0
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

-- The untyped keys of a missed wave go into review.
function huntReviewMissed()
  for i = HUNT.typed + 1, #HUNT.chars do
    HUNT.review[HUNT.chars[i]] = HUNT_CFG.review_hits
  end
end

-- A correct keystroke (first-try mastery, as in Choose/Find):
-- a clean one (no wrong press first) progresses the letter out
-- of review; one typed only after a wrong press marks it hard
-- and (re)adds it.
function huntCorrect(ch)
  if HUNT.fumbled then
    HUNT.review[ch] = HUNT_CFG.review_hits
    HUNT.fumbled = false
  else
    huntReviewHit(ch)
  end
end

-- Streak-based length change; the streak that fired is reset.
function huntAdapt()
  local cfg = huntCfg()
  HUNT.length = huntStreakLength(HUNT.cstreak,
    HUNT.mstreak, HUNT.length, cfg.lmin, cfg.lmax)
  if HUNT.cstreak >= 5 then HUNT.cstreak = 0 end
  if HUNT.mstreak >= 3 then HUNT.mstreak = 0 end
end

function huntCatch()
  huntChime()
  HUNT.count = HUNT.count + 1
  HUNT.cstreak = HUNT.cstreak + 1
  HUNT.mstreak = 0
  huntAdapt()
  HUNT.phase = "caught"
  HUNT.anim = 0
end

function huntMiss()
  huntReviewMissed()
  HUNT.mstreak = HUNT.mstreak + 1
  HUNT.cstreak = 0
  huntAdapt()
  HUNT.phase = "missed"
  HUNT.anim = 0
end

-- Letters land with their bottom on the ground line (not their
-- center), so they sit on the floor instead of sinking through
-- it, leaving the space below the line free for the help hint.
function huntWaveHalf()
  return getGlyphFont(FONT_BIG):getHeight() / 2
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
  if HUNT.phase == "fall" then
    huntTickFall(dt)
  else
    huntTickGap(dt)
  end
end

function huntKeypressed(k)
  if HUNT.phase ~= "fall" then return end
  if k == HUNT.chars[HUNT.typed + 1] then
    HUNT.typed = HUNT.typed + 1
    huntCorrect(k)
    if HUNT.typed >= #HUNT.chars then
      huntCatch()
    end
  elseif not isMod(k) and k ~= "capslock" then
    HUNT.fumbled = true
  end
end

-- The notch's speed change is immediate, including the wave in
-- flight (pressing "slower" eases the current letter at once);
-- the length range still applies only on the next spawn.
function huntOnNotch(delta)
  notchShift("hunt", delta, -2, 2)
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

function huntDrawBackground()
  gfx.setColor(COL_SKY)
  gfx.rectangle("fill", 0, 0, REF_W, REF_H)
  gfx.setColor(COL_GROUND)
  gfx.setLineWidth(2)
  gfx.line(0, HUNT_GROUND_Y, REF_W, HUNT_GROUND_Y)
  gfx.setLineWidth(1)
end

function huntCharColor(i)
  if HUNT.phase == "missed" then return COL_RED end
  if i <= HUNT.typed then return COL_OK end
  return COL_TEXT
end

function huntWaveWidth(font)
  local total = 0
  for _, ch in ipairs(HUNT.chars) do
    total = total + font:getWidth(string.upper(ch))
  end
  return total
end

-- Draw the wave's letters adjacent (natural widths), so a
-- multi-letter wave reads as one short word, not spaced glyphs.
function huntDrawChars(font, a)
  gfx.setFont(font)
  local fy = HUNT.y - font:getHeight() / 2
  local x = (REF_W - huntWaveWidth(font)) / 2
  for i, ch in ipairs(HUNT.chars) do
    local label = string.upper(ch)
    local col = huntCharColor(i)
    gfx.setColor(col[1], col[2], col[3], a)
    gfx.print(label, x, fy)
    x = x + font:getWidth(label)
  end
end

function huntDrawWave()
  local sc, a = huntWaveAnim()
  if a <= 0 then return end
  local font = getGlyphFont(FONT_BIG)
  local cx = REF_W / 2
  gfx.push()
  gfx.translate(cx, HUNT.y)
  gfx.scale(sc, sc)
  gfx.translate(-cx, -HUNT.y)
  huntDrawChars(font, a)
  gfx.pop()
end

function huntDrawCount()
  gfx.setFont(getFont(FONT_COUNT))
  gfx.setColor(COL_DIM)
  gfx.printf(HUNT.count, 20, 16, 200, "left")
end

function huntDraw()
  huntDrawBackground()
  huntDrawWave()
  huntDrawCount()
end

registerScene("hunt", {
  enter = huntEnter,
  update = huntUpdate,
  draw = huntDraw,
  keypressed = huntKeypressed,
  onNotch = huntOnNotch
})
