extends StaticBody3D

@export var level: int = 1
@export var size_scale_multiplier: float = 1.1

var hp: int = 50
#@export var hp_gain: int = 

func take_damage(amount: int) -> void:
	hp -= amount
	
	if hp <= 0:
		record_defeat()

func record_defeat() -> void:
	level += 1
	scale *= size_scale_multiplier
	
	hp = 50 #placeholder for equation
