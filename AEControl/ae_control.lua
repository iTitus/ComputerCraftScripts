local t = require("term")

local SLEEP_TIME = 1

local interruped = false

------------------------------

t.clear()
t.setCursor(1, 1)

print("AE Control!")

repeat
  if not interrupted then os.sleep(SLEEP_TIME) end
until interruped
