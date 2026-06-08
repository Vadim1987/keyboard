-- Shared key sequence for Choose the same key and Find the key.
-- Walks fixed groups in order; shuffles within each group.

SEQ = { keys = { }, idx = 0, found = 0 }

function shuffleInPlace(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
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
  SEQ.keys = buildCFSequence(notch)
  SEQ.idx = 1
  SEQ.found = 0
end

function seqCurrent()
  return SEQ.keys[SEQ.idx]
end

function seqAtEnd()
  return SEQ.idx >= #SEQ.keys
end
