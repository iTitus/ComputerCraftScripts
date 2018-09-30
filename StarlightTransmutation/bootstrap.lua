local shell = require("shell")

print("Updating files...")
shell.execute("update")
print("Starting Starlight Transmutation")
shell.execute("starlight_transmutation")
