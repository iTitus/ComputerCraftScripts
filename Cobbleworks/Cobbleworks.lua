pipe = peripheral.wrap("bottom")
lp = pipe.getLP()

MAX_TRESHOLD = 2048
INGREDIENT_TRESHOLD = MAX_TRESHOLD / 2

materials = {
  cobble = {
    id = "minecraft:cobblestone",
    data = 0,
    force = true,
    color = colors.red
  },
  stone = {
    id = "minecraft:stone",
    data = 0,
    color = colors.green
  },
  sand = {
    id = "minecraft:sand",
    data = 0,
    ingredient = "cobble",
    color = colors.brown
  },
  slag = {
    id = "ThermalExpansion:material",
    data = 514,
    ingredients = {"sand", "cobble"},
    color = colors.blue
  },
  gravel = {
    id = "minecraft:gravel",
    data = 0,
    ingredient = "stone",
    color = colors.purple
  },
  flint = {
    id = "minecraft:flint",
    data = 0,
    ingredient = "gravel",
    color = colors.cyan
  },
  silicon = {
    id = "EnderIO:itemMaterial",
    data = 0,
    ingredient = "sand",
    color = colors.lightGray
  },
  glass = {
    id = "minecraft:glass",
    data = 0,
    ingredient = "sand",
    color = colors.gray
  },
  niter = {
    id = "ThermalFoundation:material",
    data = 17,
    ingredient = "sand",
    color = colors.pink
  },
  richSlag = {
    id = "ThermalExpansion:material",
    data = 515,
    ingredient = "redstone",
    color = colors.lime
  },
  obsidian = {
    id = "minecraft:obsidian",
    data = 0,
    color = colors.yellow
  },
  redstone = {
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
    if getItemAmount(ingredient) < INGREDIENT_TRESHOLD then
      return false
    end
  end
  return getItemAmount(material) < MAX_TRESHOLD
end

while true do
  for material, data in pairs(materials) do
    local text = material..": "..getItemAmount(material).." -> "
	term.write(text)
	
	local color = data.color
	if color ~= nil then
	  local state = isEnabled(material)
	  term.blit(tostring(state), state and colors.green or colors.red, colors.black)
	  term.blit("    ", color, color)
	end
  end
  sleep(1)
  term.clear()
end
