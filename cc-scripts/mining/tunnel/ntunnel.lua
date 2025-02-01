-- Nesse Version of "Tunnel" 1.2.0
-- Usage "ntunnel <distance> <n=0,e=1,s=2,w=3>"
-- Ex: ntunnel 10 3

-- Ensure the script is running on a Turtle
if (not turtle) then
    printError("Requires a Turtle")
    return
end

-- Get tunnel distance and initial direction from command-line arguments
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
local allowItems = {
    ["minecraft:coal"] = true,
    ["minecraft:torch"] = true
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

-- Table to track movements
local path = {}

-- Function to unload items (only slots 3-16), keeping one stack of fuel if specified
local function unload()
    turtle.turnLeft()
    turtle.turnLeft()
    sleep(0.2)

    for slot = 1, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        if (item and not allowItems[item.name]) then
            turtle.drop()
        end
    end

    sleep(0.2)
    turtle.turnRight()
    turtle.turnRight()
    print("Done unloading..")
end

-- Function to check item names and drop unwanted items
local function filterInventory()
    for slot = 1, 16 do
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

-- Function to move forward while tracking the path
local function moveForward()
    while not turtle.forward() do
        if (turtle.detect()) then
            if (not tryDig()) then
                return false
            end
        else
            sleep(0.5)
        end
    end

    -- Record the forward movement
    table.insert(path, {action = "forward"})

    return true
end

-- Function to turn left and update direction and track the turn
local function turnLeft()
    turtle.turnLeft()
    table.insert(path, {action = "turn", direction = "left"})
end

-- Function to turn right and update direction and track the turn
local function turnRight()
    turtle.turnRight()
    table.insert(path, {action = "turn", direction = "right"})
end

-- Function to place a torch above the turtle (always from slot 2)
local function placeTorchAbove()
    -- Temporarily disable path tracking for turns
    local oldTurnLeft = turnLeft
    local oldTurnRight = turnRight

    -- Override turn functions to avoid recording turns
    turnLeft = function()
        turtle.turnLeft()
    end

    turnRight = function()
        turtle.turnRight()
    end

    -- Place the torch
    turtle.select(2)
    if (turtle.placeUp()) then
        print("Placed a torch")
    else
        print("Failed to place torch.")
    end

    -- Restore the original turn functions
    turnLeft = oldTurnLeft
    turnRight = oldTurnRight
end

-- Function to retrace the path
local function retracePath()
    print("Retracing steps...")

    -- Reverse the path
    for i = #path, 1, -1 do
        local move = path[i]
        if move.action == "forward" then
            -- Move backward instead of forward
            while not turtle.back() do
                if (turtle.detect()) then
                    if (not tryDig()) then
                        print("Failed to move back. Stopping.")
                        return
                    end
                else
                    sleep(0.3)
                end
            end
        elseif move.action == "turn" then
            -- Reverse the turn
            if move.direction == "left" then
                turnRight()  -- Undo a left turn with a right turn
            elseif move.direction == "right" then
                turnLeft()   -- Undo a right turn with a left turn
            end
        end
    end

    print("Returned to starting position.")
end

-- Start tunneling process
local function main()
    print("Tunneling " .. distance .. " blocks...")

    for i = 1, distance do
        turtle.refuel()

        -- Check fuel level
        local fuel = turtle.getFuelLevel()
        if (fuel < 10) then
            print("Low on fuel, fuel level is " .. fuel)
            retracePath()
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
    retracePath()
    sleep(0.5)
    unload()
    turtle.select(1)
    print("Tunnel complete!")
end

main() -- Start the tunneling process by calling the main function
final() -- Complete the tunnel, return home, and unload items