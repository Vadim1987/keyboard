-- props.lua

-- Scenery and props for the games that play on a scene rather
-- than on the keyboard picture. Everything is drawn from
-- primitives: no image assets, so a prop scales to any size,
-- takes its colors from the palette, and costs a handful of
-- draw calls. Shared by Hide and, later, Train and Asteroids.

-- A prop is placed by its bottom-left corner and sized by a
-- unit u, so a caller states position and scale in one call.

-- Rolling hills along the ground line: three flattened
-- ellipses, widest first, so the band reads as depth.

function drawHills(w, y)
  gfx.setColor(HILL[1], HILL[2], HILL[3])
  gfx.ellipse("fill", w * 0.25, y, w * 0.3, 34)
  gfx.ellipse("fill", w * 0.62, y, w * 0.26, 26)
  gfx.ellipse("fill", w * 0.88, y, w * 0.22, 30)
end

-- Meadow: hills along the horizon and a ground strip. The sky
-- is left to the pastel background main already paints, so the
-- level still colors the scene and nothing is filled twice.

function drawMeadow(w, h, groundY)
  drawHills(w, groundY)
  gfx.setColor(GROUND[1], GROUND[2], GROUND[3])
  gfx.rectangle("fill", 0, groundY, w, h - groundY)
end

-- Crate planks: the darker boards over the body. Drawn as one
-- helper so the crate itself stays a short block.

function crateBoards(x, y, u)
  gfx.setColor(WOOD_DARK[1], WOOD_DARK[2], WOOD_DARK[3])
  gfx.rectangle("fill", x, y - 10 * u,
    10 * u, 1.3 * u, 0.5 * u)
  gfx.rectangle("fill", x, y - 5.6 * u, 10 * u, 1 * u)
  gfx.rectangle("fill", x, y - 1.3 * u,
    10 * u, 1.3 * u, 0.5 * u)
  gfx.rectangle("fill", x + 4.2 * u, y - 8.7 * u,
    1.6 * u, 3.1 * u)
  gfx.rectangle("fill", x + 4.2 * u, y - 4.6 * u,
    1.6 * u, 3.3 * u)
end

-- A crate, 10u square, standing on (x, y). Its right edge is
-- straight, which is what a cap slides out from behind.

function drawCrate(x, y, u)
  gfx.setColor(WOOD[1], WOOD[2], WOOD[3])
  gfx.rectangle("fill", x, y - 10 * u, 10 * u, 10 * u, 0.5 * u)
  crateBoards(x, y, u)
end
