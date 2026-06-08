-- Scene registry and dispatch. Scenes load once at boot and
-- register a table of named handlers; gotoScene flips the
-- active pointer and calls enter() to (re)initialize play
-- state. Scenes are never re-loaded on entry.

SCENES = { }
ACTIVE = nil

MENU_INDEX = { }
for i, id in ipairs(MENU_ORDER) do
  MENU_INDEX[id] = i
end

function registerScene(id, handlers)
  SCENES[id] = handlers
end

function gotoScene(id)
  ACTIVE = id
  local s = SCENES[id]
  if s and s.enter then s.enter() end
end

function isGameScene(id)
  return MENU_INDEX[id] ~= nil
end

function sceneUpdate(dt)
  local s = SCENES[ACTIVE]
  if s and s.update then s.update(dt) end
end

function sceneDraw()
  local s = SCENES[ACTIVE]
  if s and s.draw then s.draw() end
end
