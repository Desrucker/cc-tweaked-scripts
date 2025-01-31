-- Nesse Version of "Tunnel" 1.0.0
-- Usage "NTunnel <Length>
-- Ex: NTunnel 10

if not turtle then
    printError("Requires a Turtle")
    return
end

-- Get tunnel length from command-line arguments
local tArgs = { ... }
local length = tonumber(tArgs[1])

if not length or length < 1 then
    print("Usage: NTunnel <length>")
    return
end

-- List of items to keep
local keepItems = {
    ["minecraft:redstone"] = true,
    ["minecraft:diamond"] = true,
    ["minecraft:gold_ingot"] = true,
    ["minecraft:iron_ingot"] = true,
    ["minecraft:coal"] = true,
    ["minecraft:torch"] = true

}

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

-- Function to check for torches in the turtle's inventory
local function findTorchSlot()
    for slot = 1, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        if item and item.name == "minecraft:torch" then
            return slot  -- Return the slot number if a torch is found
        end
    end
    return nil  -- Return nil if no torches are found
end

-- Function to place a torch above the turtle
local function placeTorchAbove()
    local torchSlot = findTorchSlot()  -- Get the slot with a torch
    if torchSlot then
        turtle.select(torchSlot)  -- Select the slot with the torch
        turtle.placeUp()  -- Place the torch above the turtle
        print("Placed a torch")
    else
        print("No torches found in inventory.")
    end
end

local function tryDig()
    while turtle.detect() do
        if turtle.dig() then
            sleep(0.3)
            filterInventory()
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
            if not tryDig() then return false end
        else
            sleep(0.3)
        end
    end
    return true
end

-- Start tunneling
print("Tunneling " .. length .. " blocks...")

for i = 1, length do
    tryDig()
    moveForward()
    turtle.digUp()
    if i % 5 == 0 then
        filterInventory()  -- Ensure inventory stays clean
    end

    -- Place torches every 15 blocks
    if i % 15 == 0 then
        turtle.turnRight()
        placeTorchAbove()
        turtle.turnLeft()
        print("Placed a torch")
        sleep(0.3)
    end
end

-- Return home
print("Returning to start...")
for i = 1, length do
    turtle.back()
end

print("Tunnel complete!")
