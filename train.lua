-- train.lua

-- Load the train. A cap hovers over the next flatcar; press it
-- and the cap settles onto the deck as cargo while the car
-- rolls in, so the train grows with every key learned. Once
-- TRAIN_CARS are coupled the oldest rolls off the front and
-- the newest takes its place, which reads as a long train
-- without running off the screen.
--
-- Press-count engine (gauge.lua) as in Press, so the key set,
-- the review and the progression live there. This file owns
-- the loading beat and the scene. There is no timer anywhere:
-- the cap waits as long as the child needs, which is what makes
-- this the game for the youngest. Full canvas, no keyboard
-- picture: the hovering cap is the target.

ensureFile("props.lua")

TRAIN = { burst = nil, wrong = nil, fw = { } }
TRAIN_CFG = {
  id = "train",
  notch = PRESS_NOTCH,
  lo = PRESS_LO,
  hi = PRESS_HI,
  g = TRAIN_G,
  gtop = TRAIN_GTOP
}

-- cars: the keys riding the visible flatcars, oldest first.
-- phase: wait (cap hovering) or load (cap settling, car rolling
-- in). t is the time spent loading.

LOAD = { cars = { }, phase = "wait", t = 0 }

-- Car pitch and the deck height are fixed, so they are derived
-- once here rather than per frame.

TRAIN_CAR_W = 16 * TRAIN_U
TRAIN_PITCH = TRAIN_CAR_W + TRAIN_CAR_GAP
TRAIN_LOCO_W = 20 * TRAIN_U
TRAIN_DECK_Y = TRAIN_GROUND_Y - 5.2 * TRAIN_U
TRAIN_CAP_W = TRAIN_CAP_H * KB_STD_W / KB_STD_H
TRAIN_CAP_U = TRAIN_CAP_H / KB_STD_H

-- The train grows to the right of the locomotive.

function trainCarX(i)
  return TRAIN_LOCO_X + TRAIN_LOCO_W + (i - 1) * TRAIN_PITCH
end

-- The slot the next car will occupy: one past the last one, or
-- the last slot itself once the train is full and the row
-- shifts instead of growing.

function trainNextSlot()
  return math.min(#LOAD.cars + 1, TRAIN_CARS)
end

-- An empty train and a still beat: the state every fresh level
-- starts from.

function trainReset()
  LOAD.cars = { }
  LOAD.phase = "wait"
  LOAD.t = 0
end

function trainEnter()
  trainReset()
  fkEnter(TRAIN, TRAIN_CFG)
  skyLevel(TRAIN_CFG)
  pastelSnap()
end

-- Coupling a car: the newest key joins the row, and once the
-- row is full the oldest leaves the front.

function trainCouple(k)
  LOAD.cars[#LOAD.cars + 1] = k
  if TRAIN_CARS < #LOAD.cars then
    table.remove(LOAD.cars, 1)
  end
end

function trainUpdate(dt)
  fkUpdate(TRAIN, TRAIN_CFG, dt)
  if fkDone(TRAIN) then return end
  if LOAD.phase ~= "load" then return end
  LOAD.t = LOAD.t + dt
  if TRAIN_LOAD <= LOAD.t then
    LOAD.phase = "wait"
    LOAD.t = 0
  end
end

function trainHit(k)
  trainCouple(k)
  LOAD.phase = "load"
  LOAD.t = 0
  fkHit(TRAIN, TRAIN_CFG, k)
end

function trainKeypressed(k)
  if fkDone(TRAIN) then
    fkDoneKey(TRAIN, TRAIN_CFG, k)
    return
  end
  if LOAD.phase == "load" then return end
  if k == gaugeCurrent(TRAIN) then
    trainHit(k)
  elseif not isMod(k) and k ~= "capslock" then
    fkWrong(TRAIN, TRAIN_CFG, k)
  end
end

-- A teacher notch change restarts the level, so the train
-- starts over with it.

function trainOnNotch(delta)
  trainReset()
  fkOnNotch(TRAIN, TRAIN_CFG, delta)
  skyLevel(TRAIN_CFG)
end

function trainDone()
  return fkDone(TRAIN)
end

-- Drawing

-- A cap centred on a car deck at x, sitting on it as cargo.

function trainCargoCell(x, y)
  return {
    x = x + (TRAIN_CAR_W - TRAIN_CAP_W) / 2,
    y = y - TRAIN_CAP_H,
    w = TRAIN_CAP_W,
    h = TRAIN_CAP_H
  }
end

function trainDrawCap(x, y, k)
  drawKeycap(trainCargoCell(x, y), {
    name = k,
    unit = TRAIN_CAP_U
  })
end

-- The car being coupled slides in from off the right edge;
-- every other car stands still.

function trainCarOffset(i)
  if LOAD.phase ~= "load" or i ~= #LOAD.cars then
    return 0
  end
  return (1 - LOAD.t / TRAIN_LOAD) * TRAIN_PITCH * 2
end

-- The loaded cars, each with its key riding the deck.

function trainDrawCars()
  for i, k in ipairs(LOAD.cars) do
    local x = trainCarX(i) + trainCarOffset(i)
    drawCar(x, TRAIN_GROUND_Y, TRAIN_U)
    trainDrawCap(x, TRAIN_DECK_Y, k)
  end
end

-- The target hovers over the slot the next car will fill.

function trainDrawTarget()
  trainDrawCap(trainCarX(trainNextSlot()),
    TRAIN_DECK_Y - TRAIN_HOVER, gaugeCurrent(TRAIN))
end

function trainDrawScene()
  drawMeadow(REF_W, REF_H, TRAIN_GROUND_Y)
  drawTrack(0, TRAIN_GROUND_Y - 6, REF_W)
  drawLoco(TRAIN_LOCO_X, TRAIN_GROUND_Y, TRAIN_U)
  drawSmoke(TRAIN_LOCO_X + 5 * TRAIN_U,
    TRAIN_GROUND_Y - 11 * TRAIN_U, love.timer.getTime())
  trainDrawCars()
  if LOAD.phase == "wait" then trainDrawTarget() end
end

function trainDraw()
  if trainDone() then
    fkDrawDoneScreen()
    fwDraw(TRAIN)
    return
  end
  trainDrawScene()
  drawWinGauge(TRAIN.hits, TRAIN.goal)
  fwDraw(TRAIN)
  fkDrawExitHint()
end

registerScene("train", {
  enter = trainEnter,
  update = trainUpdate,
  draw = trainDraw,
  keypressed = trainKeypressed,
  onNotch = trainOnNotch,
  noHint = trainDone
})
