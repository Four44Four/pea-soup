# Sprint 1
 - Test for building/packaging test project on targetted platforms (Windows and Linux)
 - Attack attempt signaling
    - Turns the target entity to a reddish color for 0.5 seconds
    - Track if the entity is in a hurting/healing state so that it doesnt lose its effect while moving
       - When redrawing the entity while moving, check its state to apply the correct color variant
       - When redrawing the entity to show health, check its state to apply the correct color variant
       - Start a non-repeating async timer every time an entity gets hurt/healed
          - The entity's hurting/healing state instantly changes to reflect so
             - ID of the timer (entity id + "-hurtinghealing") should be so that it can be overriden/reset by another hurting/healing state change
          - Rerender the entity's char to show that
          - Timer callback:
             - Set the state back to neutral state
             - Rerender the entity's char to show that
    - Similar for healing
       - But a greenish color
    - Store a reddish and greenish version of each entity's color to swap to (in the entity struct)
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
