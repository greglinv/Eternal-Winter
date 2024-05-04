# Eternal-Winter

This project is a simple text-based adventure game built in Racket. The game involves exploring various locations within a mystical Ice Fortress, collecting items, solving puzzles involving locked doors, and ultimately gathering three "Final Flames" to complete the game.
Features

    Multiple Locations: Explore different areas such as the Entrance Gate, Frozen Hallway, Guard's Chamber, and the Throne Room.
    Inventory Management: Players can pick up and drop items found in various locations.
    Puzzle Elements: Includes locked doors that require specific keys to unlock, adding complexity and requiring players to think strategically.
    Win Condition: The game concludes successfully when the player collects all three "Final Flames" and returns to the Entrance Gate.

How to Run the Game

To run this game, you will need a Racket environment. Follow these steps:

    Install Racket: If you haven't already, download and install Racket from the official Racket website.
    Open DrRacket: Launch the DrRacket IDE, which comes with the Racket installation.
    Load the Game: Open the game file (game.rkt) in DrRacket.
    Run the Game: Press the 'Run' button at the top of the DrRacket window to start the game.

Gameplay Instructions

    Movement: Use commands like north, south, east, and west to move between locations.
    Pick Up Items: Type pick up [item name] to collect items and store them in your inventory.
    Drop Items: Type drop [item name] to remove items from your inventory and leave them at your current location.
    Check Inventory: Type inventory to view the items you are carrying.
    Look Around: Type look to get a description of your current location.
    Search: Type search to reveal any hidden items in the location.
    Unlock Doors: Automatically attempts to use the correct key when trying to move through a locked direction.

Development Setup

This game was developed in Racket 8.x. No external libraries are required as all functions are implemented using standard Racket features.
Limitations

    Graphics: This game does not include graphical elements, as it is purely text-based.
    Complex Interactions: Interactions are limited to basic commands for navigation, item pickup, and door unlocking.

Contributing

Contributions to this project are welcome. You can improve existing functionalities or add new features. Please fork the repository, make your changes, and submit a pull request.
