-- Keyboard game configuration and shared data tables.
-- Names and sets are copied from the spec data section.

-- Light/paper theme palette (the cross-program standard; see
-- active/ux-standard/). Named constants because the 16-color
-- Color[] palette cannot express a paper theme. To be lifted
-- into a shared theme module by compy-ux-standard.
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

-- Fixed menu order (ids). Display labels are localized in
-- locale.lua.
MENU_ORDER = {
  "choose", "find", "hunt",
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
