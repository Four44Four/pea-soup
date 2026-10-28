# Sprint 1
 - Fix the inversed color + nonfunctional alt keybinds on Windows (PDCurses)
 - Add the window resize auto redraw
    - More important for Windows (PDCurses) bc it seems like resizing the window corrupts the screen
# Sprint 2
 - Research into locally runnable decision making AI models
 - Make a basic vegetable AI controlled NPC
```
rules: healing others damages self, cannot move into walls, can only heal/attack directly adjacent entities, regen over time
walls X
space _
entity heavy damage #
entity medium damage O
entity light damage -
entity no damage .
self P
self health 70
row length 27
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
__XXXX___XXX___#_O-OXXXX____XXXX______
__________XXXX______.____XXXXXX_______
____-_____________.______.______XXX_O_
__XX_X_X_X_X______XXXX___O_.._-XX_____
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
__XXXX___XXX___#_O-OXXXX____XXXX______
__________XXXX______.____XXXXXX_______
____-_____________P______.______XXX_O_
__XX_X_X_X_X______XXXX___O_.._-XX_____
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
__XXXX___XXX___#_O-OXXXX____XXXX______
__________XXXX______.____XXXXXX_______
____-_____________.______.______XXX_O_
__XX_X_X_X_X______XXXX___O_.._-XX_____
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
__XXXX___XXX___#_O-OXXXX____XXXX______
__________XXXX______.____XXXXXX_______
____-_____________.______.______XXX_O_
__XX_X_X_X_X______XXXX___O_.._-XX_____
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
__XXXX___XXX___#_O-OXXXX____XXXX______
__________XXXX______.____XXXXXX_______
____-_____________.______.______XXX_O_
__XX_X_X_X_X______XXXX___O_.._-XX_____
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
__XXXX___XXX___#_O-OXXXX____XXXX______
__________XXXX______.____XXXXXX_______
____-_____________.______.______XXX_O_
__XX_X_X_X_X______XXXX___O_.._-XX_____
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
__XXXX___XXX___#_O-OXXXX____XXXX______
__________XXXX______.____XXXXXX_______
____-_____________.______.______XXX_O_
__XX_X_X_X_X______XXXX___O_.._-XX_____
choose 1 action
move up
move down
move right
move left
attack up
attack down
attack right
attack left
heal up
heal down
heal right
heal left
```
 - Add interactions between the vegetable NPC and the controllable character
 - Make multiple vegetable NPCs spawn as the player moves (they must persist even when they move off screen)
    - Make the locally running AI model control all of the vegetable NPCs using a ticking system
    - Add interactions between each vegetable NPC (this should be derived from the interactions between the vegetable NPC and the controllable character)
# Sprint 3
 - Locally savable game state
 - Procedural map manipulation abilities
# Sprint 4
 - Finishing touches
    - Smooth out any building/packaging issues
