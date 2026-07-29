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

-- Physical-board cap palette, ported from the original
-- graphics.lua board: black caps, bright-white labels, cyan
-- Fn/Zzz engravings. The caps fit the standard Color[]
-- palette (unlike the paper chrome above).

CAP_BG = Color[Color.black]
CAP_LABEL = Color[Color.white + Color.bright]
CAP_AUX = Color[Color.cyan]

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

-- Fixed menu order (ids). Display labels are localized in
-- locale.lua.

MENU_ORDER = {
  "press", "find", "hunt", "alt", "words", "bubble", "skip",
  "hide", "train", "astro"
}

-- Per-game notch at program start. Unlisted games start at 0.

NOTCH_START = {
  hunt = -2,
  bubble = -2,
  skip = -2,
  hide = -2,
  train = -2,
  astro = -2
}

-- Typewriter welcome timing. The heading is a fixed Latin
-- wordmark (not localized); the beats are slow enough that a
-- child sees each key light and its letter appear together.

WELCOME = {
  heading = "COMPY",
  caps_beat = 0.9,
  letter_beat = 0.6
}

-- Press the key, press-count model. Notch -2..+1 grows the key
-- set by physical row; `add` lists the groups a notch adds on
-- top of the lower notches. Each key is untimed.

PRESS_LO = -2
PRESS_HI = 1
PRESS_NOTCH = { }
PRESS_NOTCH[-2] = { add = { "press_space", "home_row" } }
PRESS_NOTCH[-1] = { add = { "bottom_row" } }
PRESS_NOTCH[0] = { add = { "top_row", "press_enter_back" } }
PRESS_NOTCH[1] = { add = { "numbers", "press_tab" } }

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
-- 12/12/24/30/36) short, since each catch is a multi-key wave
-- (keystrokes-to-win = promote * lmax(lmax+1)/2).

HUNT_NOTCH = { }
HUNT_NOTCH[-2] = { fall = 30.0, lmax = 2, promote = 6 }
HUNT_NOTCH[-1] = { fall = 24.0, lmax = 2, promote = 6 }
HUNT_NOTCH[0] = { fall = 18.0, lmax = 3, promote = 8 }
HUNT_NOTCH[1] = { fall = 14.0, lmax = 3, promote = 10 }
HUNT_NOTCH[2] = { fall = 10.0, lmax = 3, promote = 12 }

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
ALT_PUNCT_C = { "=", "\\", "[", "]", ";", "'", "-" }
ALT_SPACE = { " " }
ALT_SERVICE = { "return", "backspace", "tab" }

-- Glyph groups by name, unioned into the available set.

ALT_GROUPS = {
  lower_a = ALT_LOWER_A, lower_b = ALT_LOWER_B,
  digits_a = ALT_DIGITS_A, digits_b = ALT_DIGITS_B,
  upper_a = ALT_UPPER_A, upper_b = ALT_UPPER_B,
  upper_c = ALT_UPPER_C, punct_a = ALT_PUNCT_A,
  punct_b = ALT_PUNCT_B, punct_c = ALT_PUNCT_C,
  space = ALT_SPACE, service = ALT_SERVICE
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
  groups = { "punct_b", "punct_c", "upper_c", "service" }
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

-- Blow the bubble. The child HOLDS the target key to inflate a
-- bubble over that key and releases while its edge is inside
-- the ring band. RIPE is the fixed time to reach the inner
-- ring; the notch only narrows the window that follows, so a
-- level asks for a finer release, never a different picture.
-- A hold is slower than a press, so the goals are shorter than
-- the Press ones. All tunable on-device.

BUBBLE_G = 10
BUBBLE_GTOP = 14
BUBBLE_RIPE = 1.0

-- Release windows by notch (seconds after RIPE). The ladder is
-- the Press key ladder, so the notch grows the key set and
-- tightens the window together.

BUBBLE_WINDOW = { }
BUBBLE_WINDOW[-2] = 1.2
BUBBLE_WINDOW[-1] = 0.9
BUBBLE_WINDOW[0] = 0.7
BUBBLE_WINDOW[1] = 0.5

-- Bubble geometry (reference px) and effect timings. R0 is the
-- radius at the moment of the press; RIPE_R the inner ring.

BUBBLE_R0 = 8
BUBBLE_RIPE_R = 52
BUBBLE_RATE = (BUBBLE_RIPE_R - BUBBLE_R0) / BUBBLE_RIPE
BUBBLE_FLY_T = 0.45
BUBBLE_FLY_RISE = 70
BUBBLE_POP_T = 0.3
BUBBLE_POP_GROW = 0.6

-- Skip the red ones: the falling caps come in two classes. The
-- forbidden halo is full strength; the wanted one is
-- deliberately fainter (its alpha is baked in), so a red cap
-- reads first in a mixed row.

SKIP_FORBID_COL = COL_RED
SKIP_WANT_COL = { 0.16, 0.60, 0.32, 0.45 }

-- Scenery palette for the prop games (Hide, Train and later
-- Asteroids). Kept beside the chrome palette so every color
-- lives in one file; the props themselves are in props.lua.

-- The sky over a scene reads the level as a time of day rather
-- than as the chrome pastel, which would hang a green or yellow
-- sky over green grass. One step per notch of the Press ladder.

SKY_RAMP = { }
SKY_RAMP[0] = { 0.75, 0.89, 0.97 }
SKY_RAMP[1] = { 0.62, 0.83, 0.95 }
SKY_RAMP[2] = { 0.96, 0.87, 0.70 }
SKY_RAMP[3] = { 0.97, 0.71, 0.53 }

-- Deep space over the Asteroids scene: the same idea one notch
-- wider, from a calm night to a hot nebula. Five steps, since
-- the falling-caps games run the full -2..+2 ladder.

SPACE_RAMP = { }
SPACE_RAMP[0] = { 0.09, 0.11, 0.20 }
SPACE_RAMP[1] = { 0.11, 0.10, 0.24 }
SPACE_RAMP[2] = { 0.17, 0.10, 0.26 }
SPACE_RAMP[3] = { 0.24, 0.10, 0.24 }
SPACE_RAMP[4] = { 0.30, 0.10, 0.18 }

-- Asteroids palette: rock, hull, dome, and the lamps that show
-- the charge. A dark lamp is the gun still reloading.

STAR = { 1, 1, 1 }
ROCK = { 0.54, 0.54, 0.58 }
ROCK_LIT = { 0.65, 0.65, 0.69 }
HULL = { 0.29, 0.56, 0.83 }
DOME = { 0.75, 0.89, 0.98 }
LAMP = { 0.96, 0.77, 0.26 }
LAMP_OFF = { 0.35, 0.33, 0.28 }
BOLT = { 0.95, 0.35, 0.30 }

-- Asteroids. The gun reloads after every shot; a blank costs
-- longer than a hit, so hammering every key keeps the gun cold
-- and looking first is the cheaper move. Times are tuned on
-- device.

ASTRO_RELOAD_HIT = 0.35
ASTRO_RELOAD_MISS = 0.9
ASTRO_BOLT_T = 0.18
ASTRO_SHAKE_T = 0.4
ASTRO_SHAKE_PX = 9

-- Scene geometry in reference pixels. Rocks keep clear of the
-- edges; the ship rides above the floor the engine drops caps
-- to, so a rock that lands has reached it.

ASTRO_MARGIN = 40
ASTRO_GROUND_Y = 486
ASTRO_SHIP_U = 5
ASTRO_STARS = 60

HILL = { 0.55, 0.72, 0.48 }
GROUND = { 0.45, 0.62, 0.38 }
WOOD = { 0.75, 0.54, 0.29 }
WOOD_DARK = { 0.56, 0.37, 0.18 }
IRON = { 0.18, 0.18, 0.18 }
HUB = { 0.79, 0.79, 0.79 }
BOILER = { 0.84, 0.27, 0.27 }
CAB = { 0.24, 0.42, 0.70 }
CAB_GLASS = { 0.75, 0.85, 0.95 }
RAIL = { 0.42, 0.42, 0.45 }
SLEEPER = { 0.47, 0.36, 0.24 }

-- Sleeper pitch: the track is the busiest prop on a scene, so
-- this is the knob if it ever costs too much.

SLEEPER_GAP = 26
SMOKE = { 0.85, 0.85, 0.85 }

-- Hide and seek. A cap slides out from behind a crate, waits,
-- then slides back; the child may press it while it shows or
-- from memory after it has gone. The notch shortens the peek
-- and lengthens the memory window together, so a level asks
-- for more memory and less looking.

HIDE_G = 12
HIDE_GTOP = 18
HIDE_SLIDE = 0.35
HIDE_GAP = 0.6

-- Seconds the cap stays out, by notch.

HIDE_PEEK = { }
HIDE_PEEK[-2] = 2.4
HIDE_PEEK[-1] = 1.8
HIDE_PEEK[0] = 1.3
HIDE_PEEK[1] = 0.9

-- Seconds it can still be pressed after it has hidden.

HIDE_MEMORY = { }
HIDE_MEMORY[-2] = 1.2
HIDE_MEMORY[-1] = 1.6
HIDE_MEMORY[0] = 2.2
HIDE_MEMORY[1] = 2.8

-- Scene geometry in reference pixels. The crate sits on the
-- ground line; the cap slides out to its right, keeping
-- HIDE_LIP hidden so it reads as coming from behind.

HIDE_GROUND_Y = 392
HIDE_CRATE_X = 300
HIDE_CRATE_U = 15
HIDE_CAP_H = 96
HIDE_CAP_LIP = 18

-- Load the train. A cap hovers over the next flatcar; pressing
-- it lowers the cap onto the deck and the car rolls in, so the
-- train grows with every key learned. Type find on the
-- press-count engine, for the youngest players, so there is no
-- timer anywhere: the cap waits as long as the child needs.

TRAIN_G = 10
TRAIN_GTOP = 14
TRAIN_LOAD = 0.4
TRAIN_CARS = 5

-- Scene geometry in reference pixels. The locomotive stands at
-- the left; cars fill in to its right, and once TRAIN_CARS are
-- coupled the oldest rolls off the front, so the train reads as
-- long without running off the screen.

TRAIN_GROUND_Y = 404
TRAIN_U = 6
TRAIN_LOCO_X = 96
TRAIN_CAR_GAP = 14
TRAIN_CAP_H = 60
TRAIN_HOVER = 132
