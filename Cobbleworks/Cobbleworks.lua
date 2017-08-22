pipe = peripheral.wrap("bottom")
lp = pipe.getLP()
BUNDLED_OUTPUT = "back"

SLEEP_TIME = 5
MAX_TRESHOLD = 2048
INGREDIENT_TRESHOLD = MAX_TRESHOLD / 2

materials = {
  cobble = {
    sortIndex = 1,
    id = "minecraft:cobblestone",
    data = 0,
    force = true,
    color = colors.red
  },
  stone = {
    sortIndex = 2,
    id = "minecraft:stone",
    data = 0,
    color = colors.green
  },
  sand = {
    sortIndex = 3,
    id = "minecraft:sand",
    data = 0,
    ingredient = "cobble",
    color = colors.brown
  },
  slag = {
    sortIndex = 10,
    id = "ThermalExpansion:material",
    data = 514,
    ingredients = {"sand", "cobble"},
    color = colors.blue
  },
  gravel = {
    sortIndex = 5,
    id = "minecraft:gravel",
    data = 0,
    ingredient = "stone",
    color = colors.purple
  },
  flint = {
    sortIndex = 6,
    id = "minecraft:flint",
    data = 0,
    ingredient = "gravel",
    color = colors.cyan
  },
  silicon = {
    sortIndex = 9,
    id = "EnderIO:itemMaterial",
    data = 0,
    ingredient = "sand",
    color = colors.lightGray
  },
  glass = {
    sortIndex = 4,
    id = "minecraft:glass",
    data = 0,
    ingredient = "sand",
    color = colors.gray
  },
  niter = {
    sortIndex = 12,
    id = "ThermalFoundation:material",
    data = 17,
    ingredient = "sand",
    color = colors.pink
  },
  richSlag = {
    sortIndex = 11,
    id = "ThermalExpansion:material",
    data = 515,
    ingredient = "redstone",
    color = colors.lime
  },
  obsidian = {
    sortIndex = 7,
    id = "minecraft:obsidian",
    data = 0,
    color = colors.yellow
  },
  snow = {
    sortIndex = 8,
    id = "minecraft:snowball",
    data = 0,
    color = colors.lightBlue
  },
  redstone = {
    sortIndex = 13,
    id = "minecraft:redstone",
    data = 0,
    force = false
  }
}

function getItemIdentifier(material)
  local data = materials[material]
  local builder = lp.getItemIdentifierBuilder()
  builder.setItemID(data.id)
  builder.setItemData(data.data)
  return builder.build()
end

function getItemAmount(material)
  return pipe.getItemAmount(getItemIdentifier(material))
end

function isEnabled(material)
  local data = materials[material]
  if data.force ~= nil then
    return data.force
  end
  local ingredientList = data.ingredient and {data.ingredient} or data.ingredients or {}
  for i, ingredient in ipairs(ingredientList) do
    if materials[ingredient].itemAmount < INGREDIENT_TRESHOLD then
      return false
    end
  end
  return data.itemAmount < MAX_TRESHOLD
end

function prettyPrint(t, sortFunction)
  table.sort(t, sortFunction)
  
  col_widths = {}
  for i, row in ipairs(t) do
    for j, col in ipairs(row) do
      local w = #col
      local w_max = col_widths[j]
      if not w_max or w and w > w_max then
        col_widths[j] = w
      end
    end
  end
  
  for i, row in ipairs(t) do
    local s = ""
    for j, col in ipairs(row) do
      s = s..col..string.rep(" ", col_widths[j] - #col)
    end
    print(s)
  end
end

while true do
  for material, data in pairs(materials) do
    data.itemAmount = getItemAmount(material)
  end
  
  local enabledColors = {}
  for material, data in pairs(materials) do
    local color = data.color
    if color ~= nil then
      local state = isEnabled(material)
      data.state = state
      if state == true then
        enabledColors[#enabledColors + 1] = color
      end
    else
      data.state = nil
    end
  end
  redstone.setBundledOutput(BUNDLED_OUTPUT, colors.combine(unpack(enabledColors)))
  
  local t = {}
  for material, data in pairs(materials) do
    local row = {material, " : ", tostring(data.itemAmount)}
    local color, state = data.color, data.state
    if color ~= nil and state ~= nil then
      row[#row + 1] = " -> "
      row[#row + 1] = tostring(state)
    end
    t[#t + 1] = row
  end

  prettyPrint(t, function(row1, row2) return materials[row1[1]].sortIndex < materials[row2[1]].sortIndex end)
  sleep(SLEEP_TIME)
  term.clear()
  term.setCursorPos(1, 1)
end
