-- Nesse Version of "Tunnel" 1.2.0
-- Usage "ntunnel <distance>"
-- Ex: ntunnel 10

-- Ensure the script is running on a Turtle
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
    ["minecraft:amethyst_shard"] = true,
    ["minecraft:amethyst_block"] = true,
    ["minecraft:coal"] = true,
    ["minecraft:torch"] = true
}

-- Set initial position and direction (Manually Inputted)
local STARTx, STARTy, STARTz = 318.877, -40.000, 88.458  -- Set starting coordinates
local x, y, z = STARTx, STARTy, STARTz  -- Initialize position tracking
local facing = 3  -- 0 = North, 1 = East, 2 = South, 3 = West

-- Function to check if the turtle has fuel items
local function hasFuel()
    for slot = 1, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        if (item and fuelItems[item.name]) then
            return true
        end
    end
    return false
end

-- Function to check if the turtle has free inventory slots
local function hasFreeSlots()
    for slot = 1, 16 do
        if (turtle.getItemCount(slot) == 0) then
            return true
        end
    end
    return false
end

-- Function to unload items (only slots 3-16), keeping one stack of fuel if specified
local function unload()
    turtle.turnLeft()
    turtle.turnLeft()
    sleep(0.2)

    for slot = 3, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        if (item and not fuelItems[item.name]) then
            turtle.drop()
        else
            print("Item is fuel or item is nil, not dropping.")
        end
    end

    sleep(0.2)
    turtle.turnRight()
    turtle.turnRight()
    print("Done unloading..")
end

-- Function to check item names and drop unwanted items
local function filterInventory()
    for slot = 3, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        if (item and not keepItems[item.name]) then
            turtle.drop()
        end
    end
    turtle.select(1)
end

-- Function to dig in front of the turtle until the path is clear
local function tryDig()
    local attempts = 0
    while turtle.detect() do
        if (turtle.dig()) then
            sleep(0.5)
        else
            attempts = attempts + 1
            if (attempts >= 2) then
                print("Failed to dig after 2 attempts. Moving on.")
                return false
            end
        end
    end
    return true
end

-- Function to move forward while updating position
local function moveForward()
    while not turtle.forward() do
        if (turtle.detect()) then
            if (not tryDig()) then
                return false
            end
        else
            sleep(0.3)
        end
    end

    -- Update position based on direction
    if facing == 0 then z = z + 1  -- North
    elseif facing == 1 then x = x + 1  -- East
    elseif facing == 2 then z = z - 1  -- South
    elseif facing == 3 then x = x - 1  -- West
    end

    return true
end

-- Function to turn left and update direction
local function turnLeft()
    turtle.turnLeft()
    facing = (facing - 1) % 4
end

-- Function to turn right and update direction
local function turnRight()
    turtle.turnRight()
    facing = (facing + 1) % 4
end

-- Function to place a torch above the turtle (always from slot 2)
local function placeTorchAbove()
    turtle.select(2)
    if (turtle.placeUp()) then
        print("Placed a torch")
    else
        print("Failed to place torch.")
    end
end

-- Function to return the turtle to its exact starting coordinates
local function returnToStart()
    print("Returning to starting position...")

    -- Move back to correct X coordinate
    while x > STARTx do
        if facing ~= 3 then  -- Face West
            turnLeft()
        end
        moveForward()
    end
    while x < STARTx do
        if facing ~= 1 then  -- Face East
            turnRight()
        end
        moveForward()
    end

    -- Move back to correct Z coordinate
    while z > STARTz do
        if facing ~= 2 then  -- Face South
            turnRight()
        end
        moveForward()
    end
    while z < STARTz do
        if facing ~= 0 then  -- Face North
            turnLeft()
        end
        moveForward()
    end

    print("Returned to original coordinates.")
end

-- Start tunneling process
local function main()
    print("Tunneling " .. distance .. " blocks...")

    for i = 1, distance do
        -- Check fuel and refuel
        if (not hasFuel()) then
            print("Out of fuel! Returning home.")
            returnToStart()
            return
        end
        turtle.refuel()

        -- Check fuel level
        local fuel = turtle.getFuelLevel()
        if (fuel < 10) then
            print("Low on fuel, fuel level is " .. fuel)
            returnToStart()
            return
        end

        -- Check inventory space
        if (not hasFreeSlots()) then
            print("Inventory full! Returning home.")
            returnToStart()
            return
        end

        -- Dig, move, and place torches
        tryDig()
        moveForward()
        turtle.digUp()
        
        -- Filter inventory every 10 blocks
        if (i % 10 == 0) then
            filterInventory()
        end

        -- Place torches every 13 blocks
        if (i % 13 == 0) then
            placeTorchAbove()
        end
    end
end

-- Complete the tunnel and return home
local function final()
    returnToStart()
    sleep(0.5)
    unload()
    turtle.select(1)
    print("Tunnel complete!")
end

main() -- Start the tunneling process by calling the main function
final() -- Complete the tunnel, return home, and unload items