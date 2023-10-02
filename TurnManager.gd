extends Node

@export var player_character : Node 
@export var enemy_character : Node

# Character is the class I made
var current_character : Character

@export var next_turn_delay : float = 1.0

var game_over : bool = false

signal character_begin_turn(character)
signal character_end_turn(character)

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(next_turn_delay).timeout
	begin_next_turn()


func begin_next_turn():
	if current_character == player_character:
		current_character = enemy_character
	
	elif current_character == enemy_character:
		current_character = player_character
	
	else:
		current_character = player_character
		
	emit_signal("character_begin_turn", current_character)

func end_current_turn():
	
	emit_signal("character_end_turn", current_character)
	
	await get_tree().create_timer(next_turn_delay).timeout
	
	if !game_over:
		get_node("BattleLog").visible = false
		begin_next_turn()
	

func character_died (character):
	game_over = true
	
	var banner = get_node("EndBanner")
	
	if character.is_player == true:
		print("Game Over!")
		banner.text = "You Lose!"
		banner.visible = true
		
	else:
		banner.text = "You Win!"
		banner.visible = true
