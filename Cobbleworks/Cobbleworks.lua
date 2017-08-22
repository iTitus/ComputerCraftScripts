pipe = peripheral.wrap("bottom")
lp = pipe.getLP()

MAX_TRESHOLD = 2048
INGREDIENT_TRESHOLD = MAX_TRESHOLD / 2

materials = {
  cobble = {
    id = "minecraft:cobblestone",
    data = 0,
    force = true
  },
  stone = {
    id = "minecraft:stone",
    data = 0
  },
  sand = {
    id = "minecraft:sand",
    data = 0,
    ingredient = "cobble"
  },
  slag = {
    id = "ThermalExpansion:material",
    data = 514,
    ingredients = {"sand", "cobble"}
  },
  gravel = {
    id = "minecraft:gravel",
    data = 0,
    ingredient = "stone"
  },
  flint = {
    id = "minecraft:flint",
    data = 0,
    ingredient = "gravel"
  },
  silicon = {
    id = "EnderIO:itemMaterial",
    data = 0,
    ingredient = "sand"
  },
  glass = {
    id = "minecraft:glass",
    data = 0,
    ingredient = "sand"
  },
  niter = {
    id = "ThermalFoundation:material",
    data = 17,
    ingredient = "sand"
  },
  richSlag = {
    id = "ThermalExpansion:material",
    data = 515,
    ingredient = "redstone"
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

for material, data in pairs(materials) do
  print(material..": "..getItemAmount(material).." -> "..tostring(isEnabled(material)))
end
