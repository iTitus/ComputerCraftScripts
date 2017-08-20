pipe = peripheral.wrap("bottom")
lp = pipe.getLP()

materials = {
  ["cobble"] = {
    ["id"] = function() return lp.getItemIdentifierBuilder().setItemID("minecraft:cobblestone").build() end
  }
}

function getItemAmount(material)
  return pipe.getItemAmount(materials[material]["id"]())
end

for material, data in materials do
  print(material, getItemAmount(material))
end
