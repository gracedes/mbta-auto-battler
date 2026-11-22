extends StaticBody3D

@export var level: int = 1
@export var size_scale_multiplier: float = 1.1

var BASE_HP: int = 50
var hp: float = BASE_HP

func _ready():
	for train in get_tree().get_nodes_in_group("trains"):
		if not train.damage_enemy.is_connected(_on_damage_dealt):
			train.damage_enemy.connect(_on_damage_dealt)

func _on_damage_dealt(damage):
	hp -= damage
	print("enemy received %s damage!" % [damage])
	if hp <= 0:
		print("enemy defeated! resetting")
		level += 1
		scale *= size_scale_multiplier
		hp = 50 + (10 + (level ** 0.75))
