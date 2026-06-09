-- Shared key sequence for Choose the same key and Find the key.
-- Walks fixed groups in order; shuffles within each group.

-- pool: keys still to be found on the first try (front = the
-- current target). found: count of first-try successes.
SEQ = { pool = { }, found = 0 }

-- love.math.random is seeded by LÖVE per session (as the mouse
-- game relies on), so the within-group order varies across
-- launches; plain math.random would be identical each run.
function shuffleInPlace(t)
  for i = #t, 2, -1 do
    local j = love.math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

function appendGroup(dst, name)
  local tmp = { }
  for _, k in ipairs(KEYSETS[name]) do
    tmp[#tmp + 1] = k
  end
  shuffleInPlace(tmp)
  for _, k in ipairs(tmp) do
    dst[#dst + 1] = k
  end
end

function buildCFSequence(notch)
  local conf = CF_NOTCH[notch]
  local keys = { }
  for _, g in ipairs(conf.groups) do
    appendGroup(keys, g)
  end
  if notch == 0 and CFG.choose_punct then
    appendGroup(keys, "punctuation")
  end
  return keys
end

function seqResetCF(notch)
  SEQ.pool = buildCFSequence(notch)
  SEQ.found = 0
end

function seqCurrent()
  return SEQ.pool[1]
end

function seqEmpty()
  return #SEQ.pool == 0
end

-- Found on the first try: the key is done, count it.
function seqClear()
  table.remove(SEQ.pool, 1)
  SEQ.found = SEQ.found + 1
end

-- Found, but not on the first try: drop the key back into the
-- pool at a random later spot (never the immediate next) so it
-- returns unpredictably. Not counted.
function seqRequeue()
  local k = table.remove(SEQ.pool, 1)
  local n = #SEQ.pool
  local pos = 1
  if n >= 1 then
    pos = love.math.random(2, n + 1)
  end
  table.insert(SEQ.pool, pos, k)
end
