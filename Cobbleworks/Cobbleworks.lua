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
	data = 0,
	ingredient = "cobble"
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
  local ingredient = data.ingredient
  if ingredient ~= nil then
    if getItemAmount(ingredient) < (data.ingredientTreshold or INGREDIENT_TRESHOLD) then
	  return false
	end
  end
  return getItemAmount(material) >= (data.maxTreshold or MAX_TRESHOLD)
end

for material, data in pairs(materials) do
  print(material..": "..getItemAmount(material).." -> "..tostring(isEnabled(material)))
end
