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

downloadReplace("https://raw.githubusercontent.com/iTitus/ComputerCraftScripts/master/ReactorControl/Startup.lua", "startup")
downloadReplace("https://raw.githubusercontent.com/iTitus/ComputerCraftScripts/master/ReactorControl/VersionChecker.lua", "versionChecker")
downloadReplace("https://raw.githubusercontent.com/iTitus/ComputerCraftScripts/master/ReactorControl/Button.lua", "button")
downloadReplace("https://raw.githubusercontent.com/iTitus/ComputerCraftScripts/master/ReactorControl/Paint.lua", "paint")
downloadReplace("https://raw.githubusercontent.com/iTitus/ComputerCraftScripts/master/ReactorControl/ReactorControl.lua", "reactorControl")
