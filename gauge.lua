-- Round-gauge core for the untimed find-key exercises. A round
-- is a race: clear the WHOLE set first-try to WIN; else
-- GAUGE_MISS_BUDGET fumbled targets DROP (-1, silent). A clean
-- key leaves the pool; a fumbled key requeues, so the round
-- ends only by WIN (pool empty) or DROP. A WIN shows the
-- completion/advance screen (phase "done"); the scene reads
-- st.event ("levelup" / "win") to play the sound + firework.
-- The notch changes on Tab (climb), DROP, or a teacher chord,
-- never on the win. cfg holds { id, notch, lo, hi }.

function gaugeAddGroup(out, g)
  for _, k in ipairs(KEYSETS[g]) do
    out[#out + 1] = k
  end
end

function gaugeBuildMaster(st, cfg)
  st.master = { }
  for k = cfg.lo, notchGet(cfg.id) do
    for _, g in ipairs(cfg.notch[k].add) do
      gaugeAddGroup(st.master, g)
    end
  end
end

function gaugeShuffle(t)
  for i = #t, 2, -1 do
    local j = love.math.random(1, i)
    t[i], t[j] = t[j], t[i]
  end
end

function gaugeRefillPool(st)
  st.pool = { }
  for _, k in ipairs(st.master) do
    st.pool[#st.pool + 1] = k
  end
  gaugeShuffle(st.pool)
end

function gaugeResetCounts(st)
  st.covered = 0
  st.misses = 0
  st.clean = true
end

function gaugeStartRound(st, cfg)
  gaugeBuildMaster(st, cfg)
  gaugeRefillPool(st)
  gaugeResetCounts(st)
  st.total = #st.master
end

-- Snap the pastel to the current notch and start a fresh round.
function gaugeEnter(st, cfg)
  st.event = nil
  pastelLevel(notchGet(cfg.id) - cfg.lo)
  pastelSnap()
  gaugeStartRound(st, cfg)
  st.phase = "glow"
  st.pause = 0
end

function gaugeCurrent(st)
  return st.pool[1]
end

function gaugeGlowing(st)
  return st.phase == "glow"
end

function gaugeClearCurrent(st)
  table.remove(st.pool, 1)
end

function gaugeRequeueCurrent(st)
  local k = table.remove(st.pool, 1)
  local n = #st.pool
  local pos = 1
  if n >= 1 then pos = love.math.random(2, n + 1) end
  table.insert(st.pool, pos, k)
end

-- WIN: a round cleared first-try -> the advance screen (phase
-- "done"). Below top -> a level-up cue (win.ogg), and Tab steps
-- up; at top -> the celebratory tune + firework, and Tab moves
-- on. The win never changes the notch (Tab/DROP/teacher do).
function gaugeWin(st, cfg)
  if notchGet(cfg.id) < cfg.hi then
    st.event = "levelup"
  else
    st.event = "win"
  end
  st.phase = "done"
end

function gaugeAtTop(cfg)
  return notchGet(cfg.id) >= cfg.hi
end

-- Play again from the advance screen: a fresh round at the
-- current notch (same notch, so the pastel is unchanged).
function gaugeReplay(st, cfg)
  st.event = nil
  gaugeStartRound(st, cfg)
  st.phase = "glow"
  st.pause = 0
end

-- DROP: silent -1 notch (or stay at the floor), fresh round.
function gaugeDrop(st, cfg)
  if notchGet(cfg.id) > cfg.lo then
    notchShift(cfg.id, -1, cfg.lo, cfg.hi)
    pastelLevel(notchGet(cfg.id) - cfg.lo)
  end
  gaugeStartRound(st, cfg)
  st.event = nil
  st.phase = "glow"
end

function gaugePauseFor(cfg)
  return cfg.notch[notchGet(cfg.id)].pause
end

-- Correct key in glow: cover it (clean) or requeue it
-- (fumbled). Covering the last key WINs (-> advance screen);
-- otherwise pause, then the next target glows.
function gaugeOnCorrect(st, cfg)
  if st.clean then
    st.covered = st.covered + 1
    gaugeClearCurrent(st)
    if #st.pool == 0 then
      gaugeWin(st, cfg)
      return
    end
  else
    gaugeRequeueCurrent(st)
  end
  st.clean = true
  st.phase = "pause"
  st.pause = gaugePauseFor(cfg)
end

-- First wrong key marks a target fumbled (one miss); the
-- miss budget triggers a drop. Extra wrong keys do not count.
function gaugeOnWrong(st, cfg)
  if not st.clean then return end
  st.clean = false
  st.misses = st.misses + 1
  if st.misses >= GAUGE_MISS_BUDGET then
    gaugeDrop(st, cfg)
  end
end

-- Teacher chord: change the notch, fade the pastel, and start a
-- fresh round so the next target is clean (no stale glow).
function gaugeOnNotch(st, cfg, delta)
  local old = notchGet(cfg.id)
  notchShift(cfg.id, delta, cfg.lo, cfg.hi)
  if notchGet(cfg.id) == old then return end
  pastelLevel(notchGet(cfg.id) - cfg.lo)
  gaugeStartRound(st, cfg)
  st.event = nil
  st.pause = 0
  st.phase = "glow"
end

function gaugeTick(st, cfg, dt)
  if st.phase ~= "pause" then return end
  st.pause = st.pause - dt
  if st.pause > 0 then return end
  st.event = nil
  st.phase = "glow"
end
