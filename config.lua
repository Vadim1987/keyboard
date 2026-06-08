-- Keyboard game configuration and shared data tables.
-- Names and sets are copied from the spec data section.

-- Color palette. Named constants because the 16-color Color[]
-- palette lacks the muted background and warm target tones the
-- spec requires (gray/muted blue keys, yellow/orange glow).
COL_BG = { 0.10, 0.12, 0.18, 1 }
COL_KEY = { 0.20, 0.24, 0.33, 1 }
COL_KEY_EDGE = { 0.30, 0.35, 0.46, 1 }
COL_KEY_LABEL = { 0.86, 0.89, 0.96, 1 }
COL_WARM = { 1.00, 0.72, 0.20, 1 }
COL_WARM_DIM = { 0.62, 0.46, 0.16, 1 }
COL_GLOW = { 1.00, 0.85, 0.40, 0.55 }
COL_TEXT = { 0.90, 0.92, 0.97, 1 }
COL_DIM = { 0.42, 0.46, 0.55, 1 }
COL_IND_ON = { 0.42, 0.86, 0.56, 1 }
COL_BURST = { 1.00, 0.85, 0.40 }

-- Behavior flags.
CFG = { choose_punct = false }

-- Key sets (LOVE key constants).
KEYSETS = { }
KEYSETS.distinctive = { "space", "return", "backspace" }
KEYSETS.central4 = { "f", "g", "h", "j" }
KEYSETS.central = {
  "f", "g", "h", "j", "d",
  "k", "s", "l", "a"
}
KEYSETS.numbers = {
  "1", "2", "3", "4", "5",
  "6", "7", "8", "9", "0"
}
KEYSETS.remaining_letters = {
  "q", "w", "e", "r", "t", "y",
  "u", "i", "o", "p", "z", "x",
  "c", "v", "b", "n", "m"
}
KEYSETS.punctuation = {
  "`", "-", "=", "\\", ";", ",",
  ".", "/", "[", "]", "'"
}

-- Fixed menu order and per-id labels.
MENU_ORDER = {
  "choose", "find", "hunt",
  "caps", "shift_caps", "shift_symbols"
}
MENU_LABELS = {
  choose = "Choose the same key",
  find = "Find the key",
  hunt = "Hunt the falling objects",
  caps = "Big letters",
  shift_caps = "Big letters with Shift",
  shift_symbols = "Symbols with Shift"
}

-- Typewriter welcome configuration.
WELCOME = {
  heading = "COMPY",
  caps_beat = 0.1,
  letter_beat = 0.1,
  prompt = "Press Enter",
  line = ""
}

-- Choose / Find notch table: active groups and pause (seconds).
CF_NOTCH = { }
CF_NOTCH[-2] = {
  groups = { "distinctive", "central4" },
  pause = 2.0
}
CF_NOTCH[-1] = {
  groups = { "distinctive", "central", "numbers" },
  pause = 1.2
}
CF_NOTCH[0] = {
  groups = {
    "distinctive", "central",
    "numbers", "remaining_letters"
  },
  pause = 0.5
}
