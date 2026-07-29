-- Mini-game menu. A calm numbered list in the fixed spec order,
-- derived structurally from the scenes registered in this
-- build: an id is listed iff its scene is registered, so
-- omit-not-disable is guaranteed by construction. The digit is
-- the id's fixed position in MENU_ORDER. Shift+Esc is ignored
-- here (the menu is the program's top level).

-- The digit that opens an entry. Ten games exhaust the row, so
-- the tenth answers to 0, as numbered lists have always done.

function menuDigit(n)
  if n == 10 then return "0" end
  return "" .. n
end

function menuLabel(it)
  return menuDigit(it.n) .. ". " .. STR.games[it.id]
end

function menuItems()
  local items = { }
  for i, id in ipairs(MENU_ORDER) do
    if sceneAvailable(id) then
      items[#items + 1] = { n = i, id = id }
    end
  end
  return items
end

-- Where entry i sits: down the first column, then the second.

function menuColumnW()
  return REF_W / MENU_COLS
end

function menuSlot(i, rows)
  local col = math.floor((i - 1) / rows)
  local row = (i - 1) % rows
  return col * menuColumnW(), MENU_TOP + row * MENU_STEP
end

function menuDrawList()
  gfx.setFont(getFont(FONT_MENU_ITEM))
  local items = menuItems()
  local rows = math.ceil(#items / MENU_COLS)
  for i, it in ipairs(items) do
    local x, y = menuSlot(i, rows)
    gfx.setColor(COL_TEXT)
    gfx.printf(menuLabel(it), x, y, menuColumnW(), "center")
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
  if n == 0 then n = 10 end
  local id = MENU_ORDER[n]
  if id and sceneAvailable(id) then
    gotoScene(id)
  end
end

registerScene("menu", {
  draw = menuDraw,
  keypressed = menuKeypressed
})
