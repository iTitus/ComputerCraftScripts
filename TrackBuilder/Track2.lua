local tArgs = {...}

if not tArgs or #tArgs ~= 1 or not tonumber(tArgs[1]) then
  error("Bad arguments!")
end

local iterations = math.floor(tonumber(tArgs[1]))

if iterations < 1 or iterations > 1024 then
  error("Argument out of bounds!")
end

function collectIntoFirstSlot()
  local b = false
  for i = 2, 16, 1 do
    if turtle.getItemCount(i) > 0 then
      b = true
      break;
    end
  end
  if not b then
    return
  end
  for i = 2, 16, 1 do
    if turtle.getItemSpace(1) < 1 then
      break
    end
    turtle.select(i)
    turtle.transferTo(1)
  end
  turtle.select(1)
end

function placeForward()
  turtle.breakDown()
  turtle.placeDown()
  turtle.forward()
end

turtle.select(1)
for i = 1, iterations, 1 do
  if turtle.getItemCount() < 1 then
    collectIntoFirstSlot()
  end
  while turtle.getItemCount() < 1 do
    print("No more blocks. Waiting...")
    os.pullEvent("turtle_inventory")
    collectIntoFirstSlot()
  end
  placeForward()
end
