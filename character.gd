extends Node2D
class_name Character

@export var is_player : bool
@export var current_hp : int = 25
@export var max_hp : int = 25

@export var combat_actions : Array
@export var opponent : Node

@onready var health_bar : ProgressBar = get_node("HealthBar")
@onready var health_text : Label = get_node("HealthBar/HealthText")

@export var visual : Texture2D
@export var flip_visual : bool


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Sprite.texture = visual
	$Sprite.flip_h = flip_visual
	
	get_node("/root/BattleScene").character_begin_turn.connect(_on_character_begin_turn)
	health_bar.max_value = max_hp
	
#	var new_stylebox_normal = $HealthBar.get_theme_stylebox("fill").duplicate()
	
#	print(new_stylebox_normal)
#	new_stylebox_normal.corner_radius_top_right = 0
#	new_stylebox_normal.corner_radius_bottom_right = 0
#
#	$HealthBar.add_theme_stylebox_override("new_thing", new_stylebox_normal)
#	$HealthBar.remove_theme_stylebox_override("fill")

func take_damage(damage):
	current_hp -= damage
	_update_health_bar()
	
	if current_hp <= 0:
		# sends over whatever character is calling the code
		get_node("/root/BattleScene").character_died(self)
		queue_free()
		

func heal(amount):
	current_hp += amount
	
	if current_hp > max_hp:
		current_hp = max_hp
	
	_update_health_bar()

func _update_health_bar():
	health_bar.value = current_hp
	health_text.text = str(current_hp, " / ", max_hp)
	

func _on_character_begin_turn(character):
	if character == self and is_player == false:
		_decide_combat_action()


func cast_combat_action(action):
	
	var battle_log = get_node("../BattleLog")
	var char_label = "Player" if is_player else "Enemy"
	var sprite = $Sprite
	var starting_x_position = sprite.position.x
	var starting_y_position = sprite.position.y
	
	if action.damage > 0:
		if is_player:			
			attack_movement(sprite, 30, starting_x_position, 0.25)
		
		else:
			attack_movement(sprite, -30, starting_x_position, 0.25)
			
		opponent.take_damage(action.damage)
		battle_log.text = str(char_label, " used ", action.display_name)
		battle_log.visible = true
		
	elif action.heal > 0:		
		await heal_movement(sprite, -20, starting_y_position, 0.2)			
		heal(action.heal)
		
		battle_log.text = str(char_label, " healed for ", action.heal)
		battle_log.visible = true
	
	get_node("/root/BattleScene").end_current_turn()


func attack_movement(sprite, distance, starting_x_position, wait_in_seconds):
	sprite.position.x = starting_x_position + distance
	await get_tree().create_timer(wait_in_seconds).timeout
	sprite.position.x = starting_x_position
	
func heal_movement(sprite, distance, starting_y_position, wait_in_seconds):
	for i in 3:		
		sprite.position.y = starting_y_position + distance
		await get_tree().create_timer(wait_in_seconds).timeout
		sprite.position.y = starting_y_position
		await get_tree().create_timer(wait_in_seconds).timeout

func _decide_combat_action():
	var health_percent = float(current_hp) / float(max_hp)
	
	for i in combat_actions:
		var action = i as CombatAction
		
		if action.heal > 0 :
			if randf() > health_percent + 0.2:
				cast_combat_action(action)
				return
			else:
				continue
		else:
			cast_combat_action(action)
			return
	
