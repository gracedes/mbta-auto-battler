extends StaticBody3D

@export var level: int = 1
@export var size_scale_multiplier: float = 1.01

var BASE_HP: int = 50
var hp: float = BASE_HP
var mi: Node

func _ready() -> void:
	mi = $MeshInstance3D
	get_tree().node_added.connect(_on_node_added)
	_connect_trains()

func _on_node_added(node: Node) -> void:
	if node.is_in_group("trains"):
		_connect_trains()

func _connect_trains() -> void:
	for train in get_tree().get_nodes_in_group("trains"):
		if not train.damage_enemy.is_connected(_on_damage_dealt):
			train.damage_enemy.connect(_on_damage_dealt)
	print("listening: ", get_tree().get_nodes_in_group("trains").size(), " trains")

func _on_damage_dealt(damage):
	print(self, " took ", damage, " hp: ", hp)
	hp -= damage
	print("enemy received %s damage!" % [damage])
	if hp <= 0:
		print("enemy defeated! resetting")
		level += 1
		mi.scale *= size_scale_multiplier
		print(1 + (size_scale_multiplier - 1.0) / 2)
		mi.position.y *= 1 + (size_scale_multiplier - 1.0) / 2
		hp = 50 + (10 + (level ** 0.75))
