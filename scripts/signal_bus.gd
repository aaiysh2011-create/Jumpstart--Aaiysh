extends Node
## Global event hub (autoload). Lets the player, enemies, pickups and HUD talk
## to each other without holding references to one another.

signal score_changed(new_score: int)
signal health_changed(current: int, maximum: int)
signal fragment_collected
signal player_died
signal goal_reached
