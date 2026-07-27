-- Mini-game 3: Hunt the falling objects. Every falling cap is
-- there to be caught -- no forbidden ones -- which makes this
-- the plain form of the falling-caps engine in huntcore.lua.
-- This file only names the game, declares its notch bounds, and
-- registers the scene; the behaviour is all the engine's.

ensureFile("huntcore.lua")

HUNT_SCENE = { id = "hunt", lo = -2, hi = 2, forbid = false }

function huntSceneEnter()
  huntEnter(HUNT_SCENE)
end

registerScene("hunt", {
  enter = huntSceneEnter,
  update = huntUpdate,
  draw = huntDraw,
  keypressed = huntKeypressed,
  onNotch = huntOnNotch,
  noHint = huntDone,
  timed = true
})
