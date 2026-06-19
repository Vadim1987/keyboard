-- All localizable, user-facing text lives here. Gameplay
-- teaches Latin typing, but every message a child or teacher
-- reads is drawn from a per-locale string table. The COMPY
-- heading and the physical keycap labels are NOT here: the
-- heading is a fixed Latin wordmark and the keycaps mirror the
-- physical Compy keyboard.
--
-- STR points at the active locale. Locale detection can later
-- choose a different LOCALE entry; for now it is English.

LOCALE = { }

LOCALE.en = {
  welcome = "Welcome! Watch the keyboard type.",
  prompt = "Press Enter",
  menu_title = "Choose a game",
  good_job = "Good job!",
  tab_next = "Tab → next game",
  tab_menu = "Tab → menu",
  tab_level = "Tab → next level",
  replay = "Enter or R → play again",
  help_hint = "Hold Alt+H for help",
  back_hint = "Shift+Esc → menu",
  games = {
    press = "Press the key",
    find = "Find the key",
    hunt = "Hunt the falling objects",
    caps = "Big letters",
    shift_caps = "Big letters with Shift",
    shift_symbols = "Symbols with Shift"
  },
  help = {
    press = "Press the key that glows.\n\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↑/↓  change difficulty",
    find = "Find the key shown above, then press it.\n\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↓  make it easier",
    hunt = "Type each falling letter before it lands.\n\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↑ faster   Ctrl+Alt+↓ slower",
    caps = "Type the letter shown above.\n\n"
      .. "Press Caps Lock to make capitals.\n"
      .. "Shift+Esc  back to the menu",
    shift_caps = "Make the BIG letter shown above.\n\n"
      .. "Hold Shift and press the letter.\n"
      .. "Shift+Esc  back to the menu",
    shift_symbols = "Make the symbol shown above.\n\n"
      .. "Hold Shift and press its key.\n"
      .. "Shift+Esc  back to the menu"
  }
}

STR = LOCALE.en
