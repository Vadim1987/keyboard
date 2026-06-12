-- Input lifecycle and event model.
--
-- The IDE keeps key-repeat enabled and strips the isrepeat flag
-- before calling the game, so repeats are filtered here by
-- edge tracking: a key already in INPUT.held is a repeat and is
-- ignored completely. The game does NOT disable global
-- key-repeat (the runner exposes no project-exit cleanup hook
-- to restore it on Ctrl+Esc force-exit; see Beads
-- compy-keyboard-exit-hook). Text input is enabled to match
-- the IDE default (restoring it on exit is a no-op).
--
-- Held modifier edges are the source of truth for
-- modifier-dependent acceptance and for Caps reconciliation.

INPUT = { held = { }, shift = false, ctrl = false, alt = false }

function inputInit()
  love.keyboard.setTextInput(true)
  INPUT.held = { }
  INPUT.shift = false
  INPUT.ctrl = false
  INPUT.alt = false
end

function modHeld(a, b)
  if INPUT.held[a] or INPUT.held[b] then
    return true
  end
  return false
end

function isMod(k)
  return k == "lshift" or k == "rshift"
    or k == "lctrl" or k == "rctrl"
    or k == "lalt" or k == "ralt"
end

function inputUpdateMods()
  INPUT.shift = modHeld("lshift", "rshift")
  INPUT.ctrl = modHeld("lctrl", "rctrl")
  INPUT.alt = modHeld("lalt", "ralt")
end

function goBack()
  if isGameScene(ACTIVE) then
    gotoScene("menu")
  end
end

function notchAdjust(delta)
  local s = SCENES[ACTIVE]
  if s and s.onNotch then s.onNotch(delta) end
end

-- Reserved chords are handled before scene input, keyed on the
-- non-modifier key so a held Shift during a letter falls
-- through to the scene.
function reservedChord(k)
  if k == "escape" and INPUT.shift and not INPUT.ctrl then
    goBack()
    return true
  end
  if INPUT.ctrl and INPUT.alt and k == "up" then
    notchAdjust(1)
    return true
  end
  if INPUT.ctrl and INPUT.alt and k == "down" then
    notchAdjust(-1)
    return true
  end
  return false
end

function appKeypressed(k)
  -- capslock is exempt from the repeat filter: it is a lock key
  -- whose release may not arrive, which would wedge held[] and
  -- freeze the Caps estimate. Every capslock edge must toggle.
  if INPUT.held[k] and k ~= "capslock" then return end
  dbgLog("KP " .. k)
  INPUT.held[k] = true
  inputUpdateMods()
  if reservedChord(k) then return end
  if k == "h" and INPUT.alt and not INPUT.ctrl then
    -- Alt+H is the held help peek; consume it (do not let H
    -- reach the scene as game input). The overlay is drawn
    -- from the held state while the keys stay down.
    return
  end
  if k == "capslock" then capsToggle() end
  local s = SCENES[ACTIVE]
  if s and s.keypressed then s.keypressed(k) end
end

function appKeyreleased(k)
  dbgLog("KR " .. k)
  INPUT.held[k] = nil
  inputUpdateMods()
  local s = SCENES[ACTIVE]
  if s and s.keyreleased then s.keyreleased(k) end
end

function appTextinput(t)
  dbgLog("TI " .. t .. " sh=" .. tostring(INPUT.shift))
  if isAlphaChar(t) then
    capsReconcile(t, INPUT.shift)
  end
  local s = SCENES[ACTIVE]
  if s and s.textinput then s.textinput(t) end
end
