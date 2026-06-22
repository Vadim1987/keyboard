-- Find the key. The same shared find-key scene core as Press
-- (findkey.lua) and the same -2..+2 ladder (PRESS_NOTCH is the
-- source of truth for both, per the spec), but the keyboard is
-- NOT highlighted: the child reads the board and hunts for the
-- key shown as a keycap in the top band. Case and Shift state
-- are ignored -- the correct physical key is accepted however
-- it is pressed. Same chime, burst, gauge, level-up screen, and
-- per-notch pastel as Press; the only difference is no glow.

FIND = { pulse = 0, burst = nil, fw = { } }
FIND_CFG = {
  id = "find",
  notch = PRESS_NOTCH,
  lo = PRESS_LO,
  hi = PRESS_HI,
  g = PRESS_G,
  gtop = PRESS_GTOP
}

function findEnter()
  fkEnter(FIND, FIND_CFG)
end

function findUpdate(dt)
  fkUpdate(FIND, FIND_CFG, dt)
end

function findKeypressed(k)
  fkKeypressed(FIND, FIND_CFG, k)
end

function findOnNotch(delta)
  fkOnNotch(FIND, FIND_CFG, delta)
end

function findDone()
  return fkDone(FIND)
end

-- No keyboard glow: the child must find the key unaided. The
-- shared core draws the keycap target, gauge, and the rest.
function findDraw()
  fkDraw(FIND, FIND_CFG, { })
end

registerScene("find", {
  enter = findEnter,
  update = findUpdate,
  draw = findDraw,
  keypressed = findKeypressed,
  onNotch = findOnNotch,
  noHint = findDone
})
