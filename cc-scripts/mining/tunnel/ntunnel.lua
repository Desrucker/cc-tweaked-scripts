-- Nesse Version of "Tunnel" 1.1.2
-- Usage "ntunnel <distance>
-- Ex: ntunnel 10

if (not turtle) then
    printError("Requires a Turtle")
    return
end

-- Get tunnel distance from command-line arguments
local tArgs = { ... }
if (#tArgs ~= 1) then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usage: " .. programName .. " <distance>")
    return
end

local distance = tonumber(tArgs[1])
if (distance == nil or distance < 1) then
    print("Usage: ntunnel <distance>")
    return
end

-- List of items for fuel
local fuelItems = {
    ["minecraft:coal"] = true
}

-- List of items to keep
local keepItems = {
    ["minecraft:redstone"] = true,
    ["minecraft:diamond"] = true,
    ["minecraft:raw_gold"] = true,
    ["minecraft:raw_iron"] = true,
    ["minecraft:raw_copper"] = true,
    ["minecraft:coal"] = true,
    ["minecraft:torch"] = true
}

-- Function to unload items (only slots 3-16), keeping one stack of fuel if specified
local function unload()
    turtle.turnLeft()
    turtle.turnLeft()

    sleep(0.2)

    for (slot = 3, 16) do
        turtle.select(slot)
        local item = turtle.getItemCount(i)
        if (item and not fuelItems[item.name]) then
            turtle.drop() -- Drop item if it's not in fuelItems
        else
            print("Item is fuel or item is nil, not dropping.")
        end
    end

    sleep(0.2)

    turtle.turnRight()
    turtle.turnRight()

    turtle.select(1)
    print("Done unloading..")
end

-- Function to check item names and drop unwanted items
local function filterInventory()
    for (slot = 3, 16) do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        if (item and not keepItems[item.name]) then
            turtle.drop()  -- Drop unwanted items
        end
    end
    turtle.select(3) -- Reset selection
end


local function moveForward()
    refuel()
    while not turtle.forward() do
        if (turtle.detect()) then
            if (not tryDig()) then 
                return false 
            end
        else
            sleep(0.3)
        end
    end
    return true
end

local function tryDig()
    while turtle.detect() do
        if (turtle.dig()) then
            sleep(0.3)
        else
            return false
        end
    end
    return true
end

-- Function to place a torch above the turtle (always from slot 2)
local function placeTorchAbove()
    turtle.select(2)  -- Always select slot 2 for torches
    if (turtle.placeUp()) then
        print("Placed a torch")
    else
        print("Failed to place torch! Check inventory.")
    end
end

-- Start tunneling
print("Tunneling " .. distance .. " blocks...")

for (i = 1, distance) do
    -- Check if inventory is full or coal is low, and return home immediately
    if (isInventoryFull() or isLowOnFuel()) then
        if (returnHome()) then 
            return 
        end  
    end

    tryDig()
    moveForward()
    turtle.digUp()
    
    -- Filter inventory every 5 blocks
    if (i % 5 == 0) then
        filterInventory()
    end

    -- Place torches every 15 blocks
    if (i % 15 == 0) then
        turtle.turnRight()
        sleep(0.2)
        placeTorchAbove()
        turtle.turnLeft()
        sleep(0.2)
    end
end

-- Function to return home and unload items when necessary
local function returnHome()
    print("Returning home to deposit items or refuel...")

    -- Move back to the start position
    for (i = 1, turtle.getFuelLevel()) do
        if (not turtle.back()) then
            turtle.dig()
            sleep(0.3)
        end
    end

    -- Deposit items directly behind, keeping one stack of fuel
    unload(true)

    print("Returning home complete. Stopping.")
    return true  -- Stop execution completely
end

-- Return home when done
print("Returning to start...")
for (i = 1, distance) do
    turtle.back()
end

print("Tunnel complete!")