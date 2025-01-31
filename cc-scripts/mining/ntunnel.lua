-- Nesse Version of "Tunnel" 1.1.2
-- Usage "ntunnel <Length>
-- Ex: ntunnel 10

if not turtle then
    printError("Requires a Turtle")
    return
end

-- Get tunnel length from command-line arguments
local tArgs = { ... }
if #tArgs ~= 1 then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <length>")
    return
end

local length = tonumber(tArgs[1])
if length == nil or length < 1 then
    print("Usage: ntunnel <length>")
    return
end

-- List of items to keep
local keepItems = {
    ["minecraft:redstone"] = true,
    ["minecraft:diamond"] = true,
    ["minecraft:raw_gold"] = true,
    ["minecraft:raw_iron"] = true,
    ["minecraft:coal"] = true,
    ["minecraft:torch"] = true,
    ["minecraft:raw_copper"] = true
}

-- Function to check if inventory is full
local function isInventoryFull()
    for slot = 3, 16 do
        if turtle.getItemCount(slot) == 0 then
            return false  -- Found an empty slot, inventory is NOT full
        end
    end
    return true  -- No empty slots left, inventory IS full
end

-- Function to check if coal in slot 1 is ≤ 5 and cannot refuel
local function isLowOnFuel()
    if turtle.getFuelLevel() == "unlimited" then
        return false
    end
    turtle.select(1)
    local item = turtle.getItemDetail()
    if item and item.name == "minecraft:coal" and item.count <= 5 then
        return not turtle.refuel(1)  -- True if it can't refuel
    end
    return false
end

-- Function to unload items (only slots 3-16), keeping one stack of fuel if specified
local function unload()
    turnLeft()
    turnLeft()
    local n = 3
    repeat 
        local slot = turtle.getItemCount(n)
        turtle.select(n)
        turtle.drop()
        n = n + 1
    until (n > 16)
    turtle.turnRight()
    turtle.turnRight()

    turtle.select(1)  -- Reset selection
    print("Unloading complete.")
end

-- Function to return home and unload items when necessary
local function returnHome()
    print("Returning home to deposit items or refuel...")

    -- Move back to the start position
    for i = 1, turtle.getFuelLevel() do
        if not turtle.back() then
            turtle.dig()
            sleep(0.3)
        end
    end

    -- Deposit items directly behind, keeping one stack of fuel
    unload(true)

    print("Returning home complete. Stopping.")
    return true  -- Stop execution completely
end

-- Function to check item names and drop unwanted items
local function filterInventory()
    for slot = 1, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        if item and not keepItems[item.name] then
            turtle.drop()  -- Drop unwanted items
        end
    end
    turtle.select(1) -- Reset selection
end

-- Function to place a torch above the turtle (always from slot 2)
local function placeTorchAbove()
    turtle.select(2)  -- Always select slot 2 for torches
    if turtle.placeUp() then
        print("Placed a torch")
    else
        print("Failed to place torch! Check inventory.")
    end
end

local function tryDig()
    while turtle.detect() do
        if turtle.dig() then
            sleep(0.3)
        else
            return false
        end
    end
    return true
end

local function refuel()
    if turtle.getFuelLevel() == "unlimited" or turtle.getFuelLevel() > 0 then
        return
    end
    for i = 1, 16 do
        turtle.select(i)
        if turtle.refuel(1) then
            return
        end
    end
    print("Out of fuel! Add more to continue.")
    while turtle.getFuelLevel() == 0 do
        os.pullEvent("turtle_inventory")
    end
    print("Resuming tunnel...")
end

local function moveForward()
    refuel()
    while not turtle.forward() do
        if turtle.detect() then
            if not tryDig() then 
                return false 
            end
        else
            sleep(0.3)
        end
    end
    return true
end

-- Start tunneling
print("Tunneling " .. length .. " blocks...")

for i = 1, length do
    -- Check if inventory is full or coal is low, and return home immediately
    if isInventoryFull() or isLowOnFuel() then
        if returnHome() then 
            return 
        end  
    end

    tryDig()
    moveForward()
    turtle.digUp()
    
    -- Filter inventory every 5 blocks
    if i % 5 == 0 then
        filterInventory()
    end

    -- Place torches every 15 blocks
    if i % 15 == 0 then
        turtle.turnRight()
        placeTorchAbove()
        turtle.turnLeft()
        sleep(0.3)
    end
end

-- Return home when done
print("Returning to start...")
for i = 1, length do
    turtle.back()
end

print("Tunnel complete!")