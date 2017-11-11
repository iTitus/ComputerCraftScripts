function download(url, fileName)
  print("Downloading "..fileName.." from "..url)
  local content = http.get(url).readAll()
  if not content then
    error("Could not connect to website")
  end
  f = fs.open(fileName, "w")
  f.write(content)
  f.close()
  print("Success")
end

function downloadReplace(url, fileName)
  download(url, "temp")
  fs.delete(fileName)
  fs.move("temp", fileName)
end

downloadReplace("https://raw.githubusercontent.com/iTitus/ComputerCraftScripts/master/EnergyControl/Startup.lua", "startup.lua")
downloadReplace("https://raw.githubusercontent.com/iTitus/ComputerCraftScripts/master/EnergyControl/VersionChecker.lua", "versionChecker.lua")
downloadReplace("https://raw.githubusercontent.com/iTitus/ComputerCraftScripts/master/EnergyControl/EnergyControl.lua", "energyControl.lua")
