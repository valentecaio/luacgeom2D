local Utils = {}

function Utils.deepcopy(orig)
  local orig_type = type(orig)
  local copy

  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
        copy[Utils.deepcopy(orig_key)] = Utils.deepcopy(orig_value)
    end
    setmetatable(copy, Utils.deepcopy(getmetatable(orig)))
  else
    copy = orig
  end
  return copy
end

function Utils.printTable(t, name, indent)
  name = name or ''
  indent = indent or ''
  for k, v in pairs(t) do
    if type(v) == 'table' then
      print(indent .. name .. '.' .. k, v)
      Utils.printTable(v, name .. '.' .. k, indent .. '  ')
    else
      print(indent .. name .. '.' .. k, v)
    end
  end
end

return Utils
