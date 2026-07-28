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
  tab_level = "→ next level",
  tab_more = "→ keep going",
  replay = "→ play again",
  help_hint = "Hold Alt+H for help",
  back_hint = "Shift+Esc → menu",
  paused = "Paused",
  games = {
    press = "Press the key",
    find = "Find the key",
    hunt = "Hunt the falling objects",
    alt = "Alt characters",
    words = "Words & phrases",
    bubble = "Blow the bubble",
    skip = "Skip the red ones",
    hide = "Hide and seek"
  },
  help = {
    press = "Press the key that glows.\n\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↑/↓  change difficulty",
    find = "Find the key shown above, then press it.\n\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↑/↓  change difficulty",
    hunt = "Type each falling letter before it lands.\n\n"
      .. "Alt+P  pause\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↑ faster   Ctrl+Alt+↓ slower",
    alt = "Make the letter or symbol shown above.\n\n"
      .. "Hold Shift for capitals and symbols.\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↑/↓  change difficulty",
    words = "Type the word or phrase shown above.\n\n"
      .. "Hold Shift for a capital.\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↑/↓  change difficulty",
    bubble = "Hold the key that glows to blow up the "
      .. "bubble.\nLet go while the bubble fits the ring.\n\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↑/↓  change difficulty",
    skip = "Type the green keys before they land.\n"
      .. "Leave the red ones alone.\n\n"
      .. "Alt+P  pause\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↑ faster   Ctrl+Alt+↓ slower",
    hide = "A key peeks out from behind the crate.\n"
      .. "Press it while you see it, or from memory\n"
      .. "just after it hides.\n\n"
      .. "Shift+Esc  back to the menu\n"
      .. "Ctrl+Alt+↑/↓  change difficulty"
  }
}

STR = LOCALE.en
