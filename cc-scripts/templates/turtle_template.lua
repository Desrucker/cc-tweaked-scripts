-- Check if the program is running on a Turtle
if not turtle then
    printError("Requires a Turtle") -- Print an error message if not running on a Turtle
    return -- Exit the program as it requires a Turtle to run
end

-- Get command-line arguments
local tArgs = { ... } -- Capture all command-line arguments into a table

-- Check if the correct number of arguments are provided
if #tArgs ~= 2 then
    local programName = arg[0] or fs.getName(shell.getRunningProgram()) -- Get the program name
    print("Usage: " .. programName .. " <distance> <width>") -- Show usage instructions
    return -- Exit if the number of arguments is incorrect
end

-- Convert the arguments to numbers
local distance = tonumber(tArgs[1]) -- Convert the first argument (distance)
local width = tonumber(tArgs[2])    -- Convert the second argument (width)

-- Validate the distance argument
if not distance or distance < 1 then
    print("Error: Argument 1 (distance) must be a positive number.")
    return
end

-- Validate the width argument
if not width or width < 1 then
    print("Error: Argument 2 (width) must be a positive number.")
    return
end
