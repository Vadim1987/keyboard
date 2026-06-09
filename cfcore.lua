-- Shared core for the two matching games, Choose and Find.
-- Both share one first-try mastery loop -- a key found on the
-- first try clears and counts; a key found after a wrong key
-- is requeued to come round again -- plus one completion
-- screen. Each scene owns its own state table (CHOOSE / FIND)
-- with the same fields and supplies only the presentation
-- (Choose glows a key; Find shows a large header target).

function cfReset(st)
  st.phase = "glow"
  st.pause = 0
  st.pulse = 0
  st.burst = nil
  st.notch_dirty = false
  st.clean = true
end

function cfEnter(st, id)
  seqResetCF(notchGet(id))
  cfReset(st)
end

function cfRebuild(st, id)
  seqResetCF(notchGet(id))
  st.phase = "glow"
  st.notch_dirty = false
  st.clean = true
end

-- A notch change rebuilds the pool for the new groups but
-- preserves the found count (it is not lost progress).
function cfApplyNotch(st, id)
  local keep = SEQ.found
  cfRebuild(st, id)
  SEQ.found = keep
end

function cfFinish(st)
  st.phase = "done"
  SOUND.gameWin()
end

function cfTickPause(st, id, dt)
  st.pause = st.pause - dt
  if st.pause > 0 then return end
  if st.notch_dirty then
    cfApplyNotch(st, id)
  elseif seqEmpty() then
    cfFinish(st)
  else
    st.clean = true
    st.phase = "glow"
  end
end

function cfUpdate(st, id, dt)
  st.pulse = st.pulse + dt
  if st.burst then
    st.burst.t = st.burst.t - dt
    if st.burst.t <= 0 then st.burst = nil end
  end
  if st.phase == "pause" then
    cfTickPause(st, id, dt)
  end
end

function cfHit(st, k)
  local r = keyRect(k)
  st.burst = { x = r.x + r.w / 2, y = r.y + r.h / 2, t = 0.5 }
  SOUND.match()
  if st.clean then
    seqClear()
  else
    seqRequeue()
  end
  st.phase = "pause"
  st.pause = CF_PAUSE
end

-- After a win, Tab advances forward: to the next built game, or
-- out to the menu when this is the last game.
function cfAdvance(id)
  local nid = nextGameId(id)
  if nid then
    gotoScene(nid)
  else
    gotoScene("menu")
  end
end

function cfKeypressed(st, id, k)
  if st.phase == "done" then
    if k == "tab" then
      cfAdvance(id)
    elseif k == "return" or k == "kpenter" or k == "r" then
      cfRebuild(st, id)
    end
    return
  end
  if st.phase ~= "glow" then return end
  if k == seqCurrent() then
    cfHit(st, k)
  elseif not isMod(k) and k ~= "capslock" then
    st.clean = false
  end
end

-- Only a notch that actually changes marks the pool dirty; a
-- saturated chord at the bounds must not reset progress.
function cfOnNotch(st, id, delta)
  local old = notchGet(id)
  if notchShift(id, delta, -2, 0) ~= old then
    st.notch_dirty = true
  end
end

function cfDone(st)
  return st.phase == "done"
end

function cfDoneTabLabel(id)
  if nextGameId(id) then
    return STR.tab_next
  end
  return STR.tab_menu
end

-- Shared completion screen: a calm compliment + a clear choice
-- (Tab to advance/exit, or Enter/R to play again). No count.
function cfDrawDone(id)
  gfx.setColor(COL_OVERLAY)
  gfx.rectangle("fill", 0, 0, REF_W, REF_H)
  drawBandText(STR.good_job, { 150, 240 },
    getFont(FONT_HEAD), COL_WARM)
  drawBandText(cfDoneTabLabel(id), { 300, 340 },
    getFont(FONT_STATUS), COL_TEXT)
  drawBandText(STR.replay, { 346, 386 },
    getFont(FONT_STATUS), COL_DIM)
end
