local comp = require("component")
local term = require("term")
local math = require("math")
local os = require("os")
local table = require("table")
local colors = require("colors")
local gpu = comp.gpu
local me = comp.me_controller

local SLEEP_TIME = 1
local MAX_CRAFTING_CPUS_USED = 1
local DEFAULT_PRIORITY = 1
local DEFAULT_CRAFT_SIZE = 64
local STATE_

local to_autocraft = {}
local autocraft_items = {}
------------------------------

local function add_autocraft_items()
  local function add(name, damage, label, min_size, craft_size, priority)
    damage = damage or 0
    label = label or (name .. "@" .. damage)
    min_size = min_size or 0
    craft_size = craft_size or DEFAULT_CRAFT_SIZE
    priority = priority or DEFAULT_PRIORITY
    table.insert(autocraft_items, { name=name, damage=damage, label=label, min_size=min_size, craft_size=craft_size, priority=priority, crafting_job=nil })
  end
  add("minecraft:planks", 0, "Oak Wood Planks", 128, nil, 2)
  add("minecraft:chest", 0, "Chest", 128)
  
  table.sort(autocraft_items, function(a, b)
    if a.priority ~= b.priority then
      return a.priority < b.priority
    elseif a.min_size ~= b.min_size then
      return a.min_size > b.min_size
    elseif a.craft_size ~= b.craft_size then
      return a.craft_size > b.craft_size
    elseif a.name ~= b.name then
      return a.name < b.name
    else
      return a.damage < b.damage
    end
  end)
end

function getCPUsUsed()
  local i = 0
  for _, item in ipairs(autocraft_items) do
    if item.crafting_job and not item.crafting_job.isDone() and not item.crafting_job.isCanceled() then
        i = i + 1
    end
  end
  return i
end

local function getMEItemSize(stack)
  local items = me.getItemsInNetwork({ name=stack.name, damage=stack.damage })
  if items and #items > 0 then
    for _, item in ipairs(items) do
      if not item.hasTag then return item.size end
    end
  end
  return 0
end

function update_tables()
  local to_autocraft = {}
  for _, item in ipairs(autocraft_items) do
    local size = getMEItemSize(item)
    item.size = size
    local to_craft = math.max(0, math.min(item.craft_size, size))
    if to_craft > 0 then
      table.insert(to_autocraft, { name=item.name, damage=item.damage, to_craft=to_craft})
    end
  end
end

local function do_autocrafting()
  local cpus_used = getCPUsUsed()
  if cpus_used >= MAX_CRAFTING_CPUS_USED then
    return
  end
end

local function render_info()
  term.clear()
  term.setCursor(1, 1)
  term.write("AE Control!")
  term.setCursor(1, 3)
  
  local _, y = term.getCursorPos()
  for _, item in ipairs(autocraft_items) do
    local line = item.label .. " " .. item.size .. "/" .. item.min_size
    local crafting_job = item.crafting_job
    if crafting_job then
      line = line .. "done=" .. tostring(crafting_job.isDone()) .. "canceled=" .. tostring(crafting_job.isCanceled())
    end
    term.write(line)
	
	y = y + 1
	term.setCursorPos(1, y)
  end
end

term.clear()
term.setCursor(1, 1)
add_autocraft_items()

while true do
  update_tables()
  do_autocrafting()
  render_info()
  os.sleep(SLEEP_TIME)
end
