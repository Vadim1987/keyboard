-- Per-notch pastel background with a calm cross-fade. main
-- draws with BG_CUR; scenes set a target via pastelLevel /
-- pastelClear and pastelTick eases BG_CUR toward it. Ramp and
-- fade time come from config.lua (PASTEL_RAMP, PASTEL_FADE).

BG_CUR = { COL_BG[1], COL_BG[2], COL_BG[3] }
BG_TARGET = { COL_BG[1], COL_BG[2], COL_BG[3] }

function pastelSetTarget(col)
  BG_TARGET[1] = col[1]
  BG_TARGET[2] = col[2]
  BG_TARGET[3] = col[3]
end

-- Default for non-pastel scenes: ease back to the paper bg.
function pastelClear()
  pastelSetTarget(COL_BG)
end

-- Target the ramp color for a level above floor (clamped).
function pastelLevel(level)
  local i = level
  if i < 0 then i = 0 end
  if i > 4 then i = 4 end
  pastelSetTarget(PASTEL_RAMP[i])
end

-- Snap the current color to the target (no fade) on enter.
function pastelSnap()
  BG_CUR[1] = BG_TARGET[1]
  BG_CUR[2] = BG_TARGET[2]
  BG_CUR[3] = BG_TARGET[3]
end

function pastelApproach(a, b, step)
  if a < b then return math.min(b, a + step) end
  return math.max(b, a - step)
end

function pastelTick(dt)
  local step = dt / PASTEL_FADE
  BG_CUR[1] = pastelApproach(BG_CUR[1], BG_TARGET[1], step)
  BG_CUR[2] = pastelApproach(BG_CUR[2], BG_TARGET[2], step)
  BG_CUR[3] = pastelApproach(BG_CUR[3], BG_TARGET[3], step)
end

function pastelDrawBg()
  gfx.clear(BG_CUR[1], BG_CUR[2], BG_CUR[3])
end
