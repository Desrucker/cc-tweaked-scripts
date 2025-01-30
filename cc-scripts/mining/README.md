# Nesse Version of "Tunnel"

This program automates the process of mining a tunnel using a **Turtle** in Minecraft (via the ComputerCraft mod). The turtle digs a straight tunnel of a specified length, manages its inventory by keeping valuable items, places torches periodically, and returns to its starting position once the tunnel is complete.

---

## Features

1. **Tunnel Digging**:
   - The turtle digs forward for a specified length, clearing blocks in front and above itself as it moves.
   - It uses the `tryDig()` function to dig blocks and the `moveForward()` function to move forward while ensuring the path is clear.

2. **Inventory Management**:
   - The turtle keeps valuable items (e.g., redstone, diamonds, gold, iron, coal, and torches) using the `filterInventory()` function.
   - Unwanted items are automatically dropped to free up inventory space.

3. **Torch Placement**:
   - The turtle places torches every 15 blocks to light up the tunnel using the `placeTorchAbove()` function.
   - It searches for torches in its inventory with the `findTorchSlot()` function.

4. **Fuel Management**:
   - The turtle checks its fuel level and refuels itself if necessary using the `refuel()` function.
   - If it runs out of fuel, it waits for the player to add more before continuing.

5. **Return to Start**:
   - After completing the tunnel, the turtle returns to its starting position by moving backward the same number of blocks it dug.

---

## How It Works

1. **Initialization**:
   - The program checks if it is running on a turtle. If not, it exits with an error.
   - It reads the tunnel length from the command-line arguments.

2. **Inventory Filtering**:
   - The turtle filters its inventory, keeping only valuable items and dropping the rest using the `filterInventory()` function.

3. **Tunnel Digging**:
   - The turtle digs forward using the `tryDig()` function, which clears blocks in front of it.
   - It moves forward using the `moveForward()` function, ensuring the path is clear and refueling itself if necessary.
   - The turtle also digs blocks above it to create a taller tunnel.

4. **Torch Placement**:
   - Every 15 blocks, the turtle places a torch above itself using the `placeTorchAbove()` function.
   - It searches for torches in its inventory with the `findTorchSlot()` function.

5. **Fuel Management**:
   - The turtle checks its fuel level using the `refuel()` function.
   - If it runs out of fuel, it waits for the player to add more before continuing.

6. **Completion**:
   - Once the tunnel is complete, the turtle returns to its starting position by moving backward the same number of blocks it dug.

--

## Key Functions

1. `filterInventory()`
- **Purpose**: Filters the turtle's inventory, keeping only valuable items and dropping the rest.
- **How It Works**:
  - Iterates through all 16 inventory slots.
  - Checks if the item in the slot is in the `keepItems` list.
  - Drops unwanted items.

2. `findTorchSlot()`
- **Purpose**: Searches the turtle's inventory for a torch.
- **How It Works**:
  - Iterates through all 16 inventory slots.
  - Returns the slot number if a torch is found.
  - Returns `nil` if no torches are found.

3. `placeTorchAbove()`
- **Purpose**: Places a torch above the turtle.
- **How It Works**:
  - Calls `findTorchSlot()` to locate a torch in the inventory.
  - If a torch is found, it places the torch above the turtle.
  - If no torch is found, it prints a message indicating no torches are available.

4. `tryDig()`
- **Purpose**: Attempts to dig blocks in front of the turtle.
- **How It Works**:
  - Continuously digs blocks in front of the turtle until no blocks remain.
  - Filters the inventory after each dig to drop unwanted items.

5. `refuel()`
- **Purpose**: Refuels the turtle if its fuel level is low or empty.
- **How It Works**:
  - Checks the turtle's fuel level.
  - If fuel is low, it searches the inventory for fuel items and refuels.
  - If no fuel is available, it waits for the player to add fuel.

6. `moveForward()`
- **Purpose**: Moves the turtle forward while ensuring the path is clear.
- **How It Works**:
  - Calls `refuel()` to ensure the turtle has enough fuel.
  - If a block is detected, it calls `tryDig()` to clear the path.
  - Moves the turtle forward once the path is clear.