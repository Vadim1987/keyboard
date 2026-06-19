-- Shared scene core for the untimed find-key drills (Press the
-- key, Find the key). It drives the round-gauge engine
-- (gauge.lua), the keycap target, the chime + burst, the
-- firework (firework.lua), the completion/advance screen, and
-- the persistent Shift+Esc hint. Each scene owns a state table
-- (st: pulse, burst, fw, plus the gauge fields) and a cfg
-- ({ id, notch, lo, hi }); the only per-scene difference is the
-- keyboard decoration the scene passes to fkDraw (Press glows
-- the target key; Find passes none).

function fkEnter(st, cfg)
  st.pulse = 0
  st.burst = nil
  st.fw = { }
  gaugeEnter(st, cfg)
end

function fkUpdate(st, cfg, dt)
  st.pulse = st.pulse + dt
  fwUpdate(st, dt)
  if st.burst then
    st.burst.t = st.burst.t - dt
    if st.burst.t <= 0 then st.burst = nil end
  end
  gaugeTick(st, cfg, dt)
end

-- A round win plays win.ogg; a top-notch win plays wow.ogg and
-- launches the firework.
function fkCelebrate(st)
  if st.event == "levelup" then
    SOUND.win()
  elseif st.event == "win" then
    SOUND.wow()
    fwStart(st)
  end
end

function fkHit(st, cfg, k)
  local r = keyRect(k)
  if r then
    st.burst = { x = r.x + r.w / 2,
      y = r.y + r.h / 2, t = 0.5 }
  end
  SOUND.match()
  gaugeOnCorrect(st, cfg)
  fkCelebrate(st)
end

function fkDone(st)
  return st.phase == "done"
end

-- Play again from the advance screen: clear the firework and
-- start a fresh round at the current notch.
function fkReplay(st, cfg)
  st.fw = { }
  st.burst = nil
  gaugeReplay(st, cfg)
end

-- At the top notch, the next built game (or the menu when this
-- is the last game).
function fkGotoNext(cfg)
  local nid = nextGameId(cfg.id)
  if nid then
    gotoScene(nid)
  else
    gotoScene("menu")
  end
end

-- Tab on the advance screen: below the top notch, step up one
-- notch into a fresh round (the gate up); at the top, move on.
function fkAdvance(st, cfg)
  st.fw = { }
  st.burst = nil
  if gaugeAtTop(cfg) then
    fkGotoNext(cfg)
  else
    gaugeOnNotch(st, cfg, 1)
  end
end

-- The Tab label: step up a level, or (at the top notch) the
-- next game / the menu when this is the last game.
function fkDoneTabLabel(st, cfg)
  if not gaugeAtTop(cfg) then
    return STR.tab_level
  end
  if nextGameId(cfg.id) then
    return STR.tab_next
  end
  return STR.tab_menu
end

-- Advance-screen keys: Tab steps up (next game/menu at top);
-- Enter|R replays this notch.
function fkDoneKey(st, cfg, k)
  if k == "tab" then
    fkAdvance(st, cfg)
  elseif k == "return" or k == "kpenter" or k == "r" then
    fkReplay(st, cfg)
  end
end

function fkKeypressed(st, cfg, k)
  if fkDone(st) then
    fkDoneKey(st, cfg, k)
    return
  end
  if not gaugeGlowing(st) then return end
  if k == gaugeCurrent(st) then
    fkHit(st, cfg, k)
  elseif not isMod(k) and k ~= "capslock" then
    gaugeOnWrong(st, cfg)
  end
end

-- A teacher notch change that lands a fresh round also clears
-- scene-owned visuals (a firework/burst from a just-shown win
-- screen), which the gauge cannot reach.
function fkOnNotch(st, cfg, delta)
  local before = notchGet(cfg.id)
  gaugeOnNotch(st, cfg, delta)
  if notchGet(cfg.id) ~= before then
    st.fw = { }
    st.burst = nil
  end
end

-- Subtle exit affordance during play: a light chip behind dark
-- text so Shift+Esc stays legible over any pastel background.
-- Anchored left but clear of the clipped left edge (x >= 6).
function fkDrawExitHint()
  local font = getFont(FONT_HINT)
  local txt = STR.back_hint
  local y = REF_H - font:getHeight() - 8
  local w = font:getWidth(txt) + 12
  gfx.setColor(COL_KEY[1], COL_KEY[2], COL_KEY[3], 0.7)
  gfx.rectangle("fill", 6, y - 3, w, font:getHeight() + 6, 5)
  gfx.setFont(font)
  gfx.setColor(COL_TEXT)
  gfx.print(txt, 12, y)
end

-- Shared completion screen: a calm compliment + a clear choice
-- (Tab to advance, Enter/R to replay, Shift+Esc to the menu).
-- tabLabel is caller-supplied (notch-aware).
function fkDrawDoneScreen(tabLabel)
  gfx.setColor(COL_OVERLAY)
  gfx.rectangle("fill", 0, 0, REF_W, REF_H)
  drawBandText(STR.good_job, { 140, 220 },
    getFont(FONT_HEAD), COL_WARM)
  drawBandText(tabLabel, { 286, 322 },
    getFont(FONT_STATUS), COL_TEXT)
  drawBandText(STR.replay, { 326, 362 },
    getFont(FONT_STATUS), COL_DIM)
  drawBandText(STR.back_hint, { 366, 402 },
    getFont(FONT_STATUS), COL_DIM)
end

-- The shared draw skeleton. deco is the per-key keyboard
-- decoration (Press glows the target key; Find passes { }); the
-- keycap target shows while a target is live in either game.
function fkDraw(st, cfg, deco)
  local glow = gaugeGlowing(st)
  local done = fkDone(st)
  drawKeyboard(deco)
  if glow then drawKeycapTarget(gaugeCurrent(st)) end
  if st.burst then drawBurst(st.burst) end
  if not done then drawWinGauge(st.covered, st.total) end
  drawIndicators(CAPS_STATE.on)
  if done then fkDrawDoneScreen(fkDoneTabLabel(st, cfg)) end
  fwDraw(st)
  if not done then fkDrawExitHint() end
end
