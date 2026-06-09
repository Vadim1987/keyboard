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
  replay = "Enter or R → play again",
  help_hint = "Hold Alt+H for help",
  games = {
    choose = "Choose the same key",
    find = "Find the key",
    hunt = "Hunt the falling objects",
    caps = "Big letters",
    shift_caps = "Big letters with Shift",
    shift_symbols = "Symbols with Shift"
  },
  help = {
    choose = "Press the key that glows.\n\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↓  make it easier",
    find = "Find the key shown above, then press it.\n\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↓  make it easier"
  }
}

STR = LOCALE.en
