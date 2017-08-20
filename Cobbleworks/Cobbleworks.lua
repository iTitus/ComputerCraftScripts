pipe = peripheral.wrap("bottom")
lp = pipe.getLP()

materials = {
  ["cobble"] = {
    ["id"] =
	  function()
	    builder = lp.getItemIdentifierBuilder()
	    builder.setItemID("minecraft:cobblestone")
	    return builder.build()
	  end
  }
}

function getItemAmount(material)
  return pipe.getItemAmount(materials[material]["id"]())
end

for material, data in pairs(materials) do
  print(material, getItemAmount(material))
end
