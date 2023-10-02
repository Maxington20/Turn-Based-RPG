extends Button

var combat_action : CombatAction


func _on_pressed():
	get_node("/root/BattleScene").current_character.cast_combat_action(combat_action)
