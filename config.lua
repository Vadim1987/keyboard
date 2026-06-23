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
-- Deep "typed" green for the Words phrase strip: keeps contrast
-- on every pastel (including the red top notch), unlike COL_OK.
COL_DONE = { 0.05, 0.32, 0.13 }
COL_RED = { 0.85, 0.30, 0.25 }
-- Soft pink for the brief wrong-key glow (find-key games): a
-- gentle "not that one" marker, less saturated than COL_RED
-- (which Compy reserves for errors) and fainter than the warm
-- target glow.
COL_PINK = { 0.95, 0.52, 0.62, 0.70 }
COL_BURST = { 0.98, 0.50, 0.05 }
COL_OVERLAY = { 0.95, 0.95, 0.92, 0.88 }
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

-- Key sets (LOVE key constants).
KEYSETS = { }
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
-- full_alphabet = every letter (central + remaining), built at
-- load; the Alt exercise reuses it for its lowercase set.
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
  "press", "find", "hunt", "alt", "words"
}

-- Typewriter welcome timing. The heading is a fixed Latin
-- wordmark (not localized); the beats are slow enough that a
-- child sees each key light and its letter appear together.
WELCOME = {
  heading = "COMPY",
  caps_beat = 0.9,
  letter_beat = 0.6
}

-- Press the key, press-count model. Notch -2..+2 grows the key
-- set by physical row; `add` lists the groups a notch adds on
-- top of the lower notches. Each key is untimed.
PRESS_LO = -2
PRESS_HI = 2
PRESS_NOTCH = { }
PRESS_NOTCH[-2] = { add = { "press_space", "home_row" } }
PRESS_NOTCH[-1] = { add = { "bottom_row" } }
PRESS_NOTCH[0] = { add = { "top_row", "press_enter_back" } }
PRESS_NOTCH[1] = { add = { "numbers", "press_tab" } }
PRESS_NOTCH[2] = { add = { "press_punct" } }

-- Press-count learning engine (gauge.lua). G is the review
-- FLOOR: a level needs max(G, its mandatory count) first-try
-- hits, so the gauge always covers every new glyph (the reserve
-- rule) and G only adds review -- correct for any level size,
-- including the 29-key default Press/Find entry. GTOP raises
-- the floor at the top notch. GAUGE_LOWN_BIAS skews selection
-- toward low-press glyphs. All tunable on-device.
PRESS_G = 15
PRESS_GTOP = 25
ALT_G = 30
ALT_GTOP = 45
GAUGE_LOWN_BIAS = 4

-- Hunt the falling objects. Reference-canvas y bounds for the
-- fall, the rolling-window config, and the notch table (notch =
-- fall speed; wave length adapts within the notch's range).
HUNT_SPAWN_Y = 24
HUNT_GROUND_Y = 492

-- Signed wave-length gauge: each catch adds 1, each miss
-- subtracts 1. Per-notch `promote` (reached) grows the wave
-- a length, or at lmax opens the win screen; `demote` (reached
-- above length 1) shrinks it. review_hits = the correct presses
-- to retire a missed key from review; gap = the pause between
-- waves (after a catch or a miss).
HUNT_CFG = {
  review_hits = 1,
  gap = 0.5,
  demote = -3
}

-- Fall times (seconds top-to-bottom), tuned slow for 4-6
-- beginners. The notch sets speed + the length CEILING (lmax) +
-- the gauge `promote` threshold; the floor is always length 1,
-- so a longer wave is earned through the gauge, never forced.
-- The promotes keep catches-to-win (promote * lmax =
-- 12/12/24/30/48) short, since each catch is a multi-key wave
-- (keystrokes-to-win = promote * lmax(lmax+1)/2).
HUNT_NOTCH = { }
HUNT_NOTCH[-2] = { fall = 16.0, lmax = 2, promote = 6 }
HUNT_NOTCH[-1] = { fall = 12.0, lmax = 2, promote = 6 }
HUNT_NOTCH[0] = { fall = 10.0, lmax = 3, promote = 8 }
HUNT_NOTCH[1] = { fall = 7.0, lmax = 3, promote = 10 }
HUNT_NOTCH[2] = { fall = 5.0, lmax = 4, promote = 12 }

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

-- Alt characters. Press-count engine over produced GLYPHS, not
-- physical keys. Five notches add ~15 new glyphs each, growing
-- alphanumeric -> capitals/punctuation, with the non-printing
-- service keys last. Each notch ADDS a glyph group; the
-- available set is the floor..notch union. The non-printing key
-- targets (Backspace/Tab/Enter, matched via keypressed) live in
-- ALT_KEYTARGET (alt.lua); space is a normal produced glyph.
ALT_LO = 0
ALT_HI = 4

-- Lowercase split 15 + 11 (home-row-first order from
-- full_alphabet); capitals split 5 + 14 + 7; digits 4 + 6.
ALT_LOWER_A = { }
ALT_LOWER_B = { }
for i, k in ipairs(KEYSETS.full_alphabet) do
  if i <= 15 then ALT_LOWER_A[#ALT_LOWER_A + 1] = k
  else ALT_LOWER_B[#ALT_LOWER_B + 1] = k end
end
-- Uppercase A-Z (same order), then split 5 + 14 + 7 by notch.
ALT_UPPER = { }
for _, k in ipairs(KEYSETS.full_alphabet) do
  ALT_UPPER[#ALT_UPPER + 1] = string.upper(k)
end
ALT_UPPER_A = { }
ALT_UPPER_B = { }
ALT_UPPER_C = { }
for i, k in ipairs(ALT_UPPER) do
  if i <= 5 then ALT_UPPER_A[#ALT_UPPER_A + 1] = k
  elseif i <= 19 then ALT_UPPER_B[#ALT_UPPER_B + 1] = k
  else ALT_UPPER_C[#ALT_UPPER_C + 1] = k end
end
ALT_DIGITS_A = { "1", "2", "3", "4" }
ALT_DIGITS_B = { "5", "6", "7", "8", "9", "0" }
ALT_PUNCT_A = { ".", ",", "/" }
ALT_PUNCT_B = { "!", "?", ":" }
ALT_SPACE = { " " }
ALT_SERVICE = { "return", "backspace", "tab" }

-- Glyph groups by name, unioned into the available set.
ALT_GROUPS = {
  lower_a = ALT_LOWER_A, lower_b = ALT_LOWER_B,
  digits_a = ALT_DIGITS_A, digits_b = ALT_DIGITS_B,
  upper_a = ALT_UPPER_A, upper_b = ALT_UPPER_B,
  upper_c = ALT_UPPER_C, punct_a = ALT_PUNCT_A,
  punct_b = ALT_PUNCT_B, space = ALT_SPACE,
  service = ALT_SERVICE
}

-- Notch 0..4, start 0. Notches 0-1 are alphanumeric; capitals
-- and punctuation mix in from notch 2; the service keys land at
-- the top. `groups` are ADDED at that notch.
ALT_NOTCH = { }
ALT_NOTCH[0] = { groups = { "lower_a" } }
ALT_NOTCH[1] = { groups = { "lower_b", "digits_a" } }
ALT_NOTCH[2] = {
  groups = { "digits_b", "punct_a", "space", "upper_a" }
}
ALT_NOTCH[3] = { groups = { "upper_b" } }
ALT_NOTCH[4] = {
  groups = { "punct_b", "upper_c", "service" }
}

-- Shift-hint budget. The first ALT_HINT_FIRST Shift-requiring
-- targets of an entry are hinted (the first is forced to be
-- one); the teacher chord (Ctrl+Alt+H) re-arms ALT_HINT_MORE.
ALT_HINT_FIRST = 4
ALT_HINT_MORE = 3

-- SHIFT_MAP: the symbol a base key makes with Shift held. Used
-- by Alt for symbol targets' base keys and by the live-case
-- keyboard's Shift-gated symbol labels.
SHIFT_MAP = {
  ["1"] = "!", ["2"] = "@", ["3"] = "#", ["4"] = "$",
  ["5"] = "%", ["6"] = "^", ["7"] = "&", ["8"] = "*",
  ["9"] = "(", ["0"] = ")", ["`"] = "~", ["-"] = "_",
  ["="] = "+", ["["] = "{", ["]"] = "}", ["\\"] = "|",
  [";"] = ":", ["'"] = "\"", [","] = "<", ["."] = ">",
  ["/"] = "?"
}

-- Words and phrases (Exercise 5). An order-2 character Markov
-- (markov.lua) over a bundled Alice chapter (words_corpus.lua),
-- the table built at first entry. A low order keeps the words
-- playfully unreal. Rung = notch 0..4: each rung sets the word
-- count k (k..kmax), the per-word length range, whether the
-- line is Capitalized (phrase-initial), and whether it carries
-- punctuation. Lines are multi-word at every rung; the gauge
-- fills one notch per word typed cleanly (no learnable token
-- set -- the per-word count is the whole mechanic). WORDS_G is
-- the clean-word goal per rung.
WORDS_LO = 0
WORDS_HI = 4
MARKOV_ORDER = 2
MARKOV_TRIES = 20
MARKOV_CAP = 28
WORDS_RUNGS = { }
WORDS_RUNGS[0] = { k = 3, kmax = 4, lmin = 3, lmax = 6,
  caps = false, punct = false }
WORDS_RUNGS[1] = { k = 4, kmax = 5, lmin = 3, lmax = 6,
  caps = false, punct = false }
WORDS_RUNGS[2] = { k = 4, kmax = 6, lmin = 3, lmax = 7,
  caps = false, punct = false }
WORDS_RUNGS[3] = { k = 5, kmax = 6, lmin = 3, lmax = 7,
  caps = true, punct = false }
WORDS_RUNGS[4] = { k = 5, kmax = 6, lmin = 3, lmax = 7,
  caps = true, punct = true }
WORDS_G = { }
WORDS_G[0] = 12
WORDS_G[1] = 13
WORDS_G[2] = 14
WORDS_G[3] = 15
WORDS_G[4] = 16
-- Phrase strip: a fixed font size smaller than the keycap
-- target glyph (KCAP_T_BIG = 40) but well above editor body
-- text; the generator caps line length to fit REF_W at this
-- size, with a side margin each edge.
WORDS_STRIP_PX = 26
WORDS_STRIP_MARGIN = 36
