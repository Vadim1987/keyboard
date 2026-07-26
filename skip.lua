-- Skip the red ones. The falling-caps engine (hunt.lua) with
-- mixed waves: caps ringed green are to be typed before they
-- land, caps ringed red are to be left alone. Pressing a red
-- one bangs and loses the wave at once; a wave scores when
-- every green cap is typed and no red one was. The engine,
-- gauge, review, notch and screens are Hunt's -- this scene
-- only names the game and hands the engine its own notch id,
-- so progress in the two games is kept apart.

function skipEnter()
  huntEnter(SKIP_SCENE)
end

registerScene("skip", {
  enter = skipEnter,
  update = huntUpdate,
  draw = huntDraw,
  keypressed = huntKeypressed,
  onNotch = huntOnNotch,
  noHint = huntDone
})
