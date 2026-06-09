-- Mini-game menu. A calm numbered list in the fixed spec order,
-- derived structurally from the scenes registered in this
-- build: an id is listed iff its scene is registered, so
-- omit-not-disable is guaranteed by construction. The digit is
-- the id's fixed position in MENU_ORDER. Shift+Esc is ignored
-- here (the menu is the program's top level).

function menuItems()
  local items = { }
  for i, id in ipairs(MENU_ORDER) do
    if sceneAvailable(id) then
      items[#items + 1] = { n = i, id = id }
    end
  end
  return items
end

function menuDrawList()
  gfx.setFont(getFont(FONT_MENU))
  local y = KBAND_Y0 + 30
  for _, it in ipairs(menuItems()) do
    local label = it.n .. ". " .. STR.games[it.id]
    gfx.setColor(COL_TEXT)
    gfx.printf(label, 0, y, REF_W, "center")
    y = y + 50
  end
end

function menuDraw()
  drawBandText(STR.menu_title, HEADER_BAND,
    getFont(FONT_MENU), COL_DIM)
  menuDrawList()
end

function menuKeypressed(k)
  local n = tonumber(k)
  if not n then return end
  local id = MENU_ORDER[n]
  if id and sceneAvailable(id) then
    gotoScene(id)
  end
end

registerScene("menu", {
  draw = menuDraw,
  keypressed = menuKeypressed
})
