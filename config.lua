-- Keyboard game configuration and shared data tables.
-- Names and sets are copied from the spec data section.

-- Light/paper theme palette (the cross-program standard).
-- Named constants because the 16-color Color[] palette cannot
-- express a paper theme; to be lifted into a shared theme
-- module later.
COL_BG = { 0.93, 0.93, 0.90 }
COL_KEY = { 1.00, 1.00, 0.99 }
COL_KEY_EDGE = { 0.58, 0.58, 0.54 }
COL_KEY_LABEL = { 0.18, 0.18, 0.18 }
COL_WARM = { 1.00, 0.64, 0.10 }
COL_WARM_DIM = { 0.97, 0.85, 0.58 }
COL_GLOW = { 0.95, 0.45, 0.05, 0.75 }
COL_TEXT = { 0.16, 0.16, 0.16 }
COL_DIM = { 0.50, 0.50, 0.48 }
COL_IND_ON = { 0.16, 0.60, 0.32 }
COL_OK = { 0.16, 0.60, 0.32 }
COL_RED = { 0.85, 0.30, 0.25 }
COL_BURST = { 0.98, 0.50, 0.05 }
COL_OVERLAY = { 0.95, 0.95, 0.92, 0.88 }
COL_SKY = { 0.80, 0.88, 0.96 }
COL_GROUND = { 0.55, 0.60, 0.52 }

-- Per-notch pastel backgrounds: the Compy palette ramp, mild
-- (green) -> serious (red), indexed by level above an
-- exercise's floor. Hex inlined (paper theme, outside Color[]).
-- L0 #63F5C1 L1 #71E6EF L2 #FFF484 L3 #FF936F L4 #FF6666.
PASTEL_RAMP = { }
PASTEL_RAMP[0] = { 99 / 255, 245 / 255, 193 / 255 }
PASTEL_RAMP[1] = { 113 / 255, 230 / 255, 239 / 255 }
PASTEL_RAMP[2] = { 255 / 255, 244 / 255, 132 / 255 }
PASTEL_RAMP[3] = { 255 / 255, 147 / 255, 111 / 255 }
PASTEL_RAMP[4] = { 255 / 255, 102 / 255, 102 / 255 }
PASTEL_FADE = 0.3

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
-- Caps/Shift letter sets. central_common = the central row plus
-- the common letters E T R U I O P C M N; full_alphabet = every
-- letter (central + remaining), built at load.
KEYSETS.central_common = {
  "f", "g", "h", "j", "d", "k", "s", "l", "a",
  "e", "t", "r", "u", "i", "o", "p", "c", "m", "n"
}
KEYSETS.full_alphabet = { }
for _, k in ipairs(KEYSETS.central) do
  KEYSETS.full_alphabet[#KEYSETS.full_alphabet + 1] = k
end
for _, k in ipairs(KEYSETS.remaining_letters) do
  KEYSETS.full_alphabet[#KEYSETS.full_alphabet + 1] = k
end

-- Letter rows by physical position, for the Press/Find ladder
-- (grow by row), plus the special-key groups the ladder adds at
-- specific notches.
KEYSETS.home_row = {
  "a", "s", "d", "f", "g",
  "h", "j", "k", "l"
}
KEYSETS.bottom_row = {
  "z", "x", "c", "v", "b", "n", "m"
}
KEYSETS.top_row = {
  "q", "w", "e", "r", "t",
  "y", "u", "i", "o", "p"
}
KEYSETS.press_space = { "space" }
KEYSETS.press_enter_back = { "return", "backspace" }
KEYSETS.press_tab = { "tab" }
-- Unshifted punctuation minus backtick: the top-notch (+2)
-- rung for the find-key games (the whole keyboard at top).
KEYSETS.press_punct = {
  "-", "=", "\\", ";", ",",
  ".", "/", "[", "]", "'"
}

-- Fixed menu order (ids). Display labels are localized in
-- locale.lua.
MENU_ORDER = {
  "press", "find", "hunt",
  "caps", "shift_caps", "shift_symbols"
}

-- Typewriter welcome timing. The heading is a fixed Latin
-- wordmark (not localized); the beats are slow enough that a
-- child sees each key light and its letter appear together.
WELCOME = {
  heading = "COMPY",
  caps_beat = 0.9,
  letter_beat = 0.6
}

-- Choose / Find notch: which key groups are active. The game is
-- untimed, so the notch changes only the key SET, never pacing.
-- CF_PAUSE is one calm beat for the success chime + burst, the
-- same at every notch.
CF_PAUSE = 0.5
CF_NOTCH = { }
CF_NOTCH[-2] = { groups = { "distinctive", "central4" } }
CF_NOTCH[-1] = {
  groups = { "distinctive", "central", "numbers" }
}
CF_NOTCH[0] = {
  groups = {
    "distinctive", "central",
    "numbers", "remaining_letters"
  }
}

-- Press the key, round-gauge model. Notch -2..+2 grows the key
-- set by physical row and sets the inter-target pause (delay
-- after a correct press; each key stays untimed). A round is
-- won by clearing the WHOLE set (every key cleaned on the first
-- try). `add` lists the groups this notch adds on top.
PRESS_LO = -2
PRESS_HI = 2
PRESS_NOTCH = { }
PRESS_NOTCH[-2] = {
  add = { "press_space", "home_row" }, pause = 0.75
}
PRESS_NOTCH[-1] = {
  add = { "bottom_row" }, pause = 0.5
}
PRESS_NOTCH[0] = {
  add = { "top_row", "press_enter_back" }, pause = 0.25
}
PRESS_NOTCH[1] = {
  add = { "numbers", "press_tab" }, pause = 0.25
}
PRESS_NOTCH[2] = {
  add = { "press_punct" }, pause = 0
}

-- Round-gauge: misses in a round that drop the notch by 1. A
-- round ends only by WIN (whole set cleared first-try) or DROP
-- (this many misses). Fumbled keys requeue; the round ends when
-- every key is cleared, not by a fixed count.
GAUGE_MISS_BUDGET = 4

-- Hunt the falling objects. Reference-canvas y bounds for the
-- fall, the rolling-window config, and the notch table (notch =
-- fall speed; wave length adapts within the notch's range).
HUNT_SPAWN_Y = 24
HUNT_GROUND_Y = 492

-- Streak-based length adaptation (5 caught in a row -> +1, 3
-- missed in a row -> -1; see huntadapt.lua). review_hits = the
-- correct presses needed to retire a missed key from review.
HUNT_CFG = {
  review_hits = 3,
  gap = 0.5
}

-- Fall times (seconds top-to-bottom), tuned slow for 4-6
-- beginners. The notch sets speed + the length CEILING (lmax);
-- every notch keeps the floor at 1 (lmin), so a longer wave is
-- earned only by a catch streak, never forced by the notch.
HUNT_NOTCH = { }
HUNT_NOTCH[-2] = { fall = 16.0, lmin = 1, lmax = 1 }
HUNT_NOTCH[-1] = { fall = 12.0, lmin = 1, lmax = 1 }
HUNT_NOTCH[0] = { fall = 10.0, lmin = 1, lmax = 3 }
HUNT_NOTCH[1] = { fall = 7.0, lmin = 1, lmax = 3 }
HUNT_NOTCH[2] = { fall = 5.0, lmin = 1, lmax = 3 }

-- Hunt characters: letters + digits only (no distinctive or
-- punctuation), from central + numbers + remaining_letters.
HUNT_CHARS = { }
for _, k in ipairs(KEYSETS.central) do
  HUNT_CHARS[#HUNT_CHARS + 1] = k
end
for _, k in ipairs(KEYSETS.numbers) do
  HUNT_CHARS[#HUNT_CHARS + 1] = k
end
for _, k in ipairs(KEYSETS.remaining_letters) do
  HUNT_CHARS[#HUNT_CHARS + 1] = k
end

-- Big letters (Caps Lock). Each notch picks a letter set, a
-- case mode (mixed = some lowercase targets too), how strongly
-- the Caps Lock key is hinted, and whether the pause shortens.
-- The notch auto-matches (notch.lua): 3 clean -> up, 2 struggle
-- -> down, >=15 s cooldown. CAPS_HINT_COOLDOWN is that window.
CAPS_HINT_COOLDOWN = 15
CAPS_NOTCH = { }
CAPS_NOTCH[-2] = {
  set = "central4", mixed = false, hint = "always"
}
CAPS_NOTCH[-1] = {
  set = "central_common", mixed = false, hint = "always"
}
CAPS_NOTCH[0] = {
  set = "full_alphabet", mixed = true, hint = "wrong"
}
CAPS_NOTCH[1] = {
  set = "full_alphabet", mixed = true, hint = "off"
}
CAPS_NOTCH[2] = {
  set = "full_alphabet", mixed = true, hint = "off", fast = true
}

-- Symbols with Shift. SHIFT_MAP: the symbol a base key makes
-- with Shift held; used for targets, the base-key hint, and the
-- shifted keycap labels. Caps Lock does not affect these.
SHIFT_MAP = {
  ["1"] = "!", ["2"] = "@", ["3"] = "#", ["4"] = "$",
  ["5"] = "%", ["6"] = "^", ["7"] = "&", ["8"] = "*",
  ["9"] = "(", ["0"] = ")", ["`"] = "~", ["-"] = "_",
  ["="] = "+", ["["] = "{", ["]"] = "}", ["\\"] = "|",
  [";"] = ":", ["'"] = "\"", [","] = "<", ["."] = ">",
  ["/"] = "?"
}

-- Symbol target sets as BASE KEYS (target = SHIFT_MAP[base]).
SYM_SETS = { }
SYM_SETS.intro = { "1", "/" }
SYM_SETS.small = { "1", "/", ",", "." }
SYM_SETS.numbers = {
  "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"
}
SYM_SETS.plus = {
  "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
  "/", "-", "=", ";", ",", ".", "'"
}
SYM_SETS.full = {
  "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
  "`", "-", "=", "\\", ";", "'", ",", ".", "/", "[", "]"
}

-- Notch sets the symbol set + how the base+Shift pair is hinted
-- ("always" / "miss" = only after a wrong try / "off").
SYMBOL_NOTCH = { }
SYMBOL_NOTCH[-2] = { set = "intro", hint = "always" }
SYMBOL_NOTCH[-1] = { set = "small", hint = "always" }
SYMBOL_NOTCH[0] = { set = "numbers", hint = "miss" }
SYMBOL_NOTCH[1] = { set = "plus", hint = "off" }
SYMBOL_NOTCH[2] = { set = "full", hint = "off" }
