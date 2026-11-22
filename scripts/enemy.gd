extends StaticBody3D


@export var level: int = 1
@export var size_scale_multiplier: float = 1.01

var BASE_HP: int = 50
var hp: float = BASE_HP
var mi: Node
var size: Vector3

func _ready() -> void:
	mi = $MeshInstance3D
	size = mi.scale
	get_tree().node_added.connect(_on_node_added)
	_connect_emitters()

func _on_node_added(node: Node) -> void:
	if node.is_in_group("emitters"):
		_connect_emitters()

func _connect_emitters() -> void:
	for emitter in get_tree().get_nodes_in_group("emitters"):
		if not emitter.send_damage.is_connected(_on_damage_dealt):
			emitter.send_damage.connect(_on_damage_dealt)
	print("listening: ", get_tree().get_nodes_in_group("emitters").size(), " trains")

func _on_damage_dealt(damage):
	print(self, " took ", damage, " hp: ", hp)
	hp -= damage
	if hp <= 0:
		print("enemy defeated! resetting")
		level += 1
		get_parent().save.call_deferred()
		mi.scale *= size_scale_multiplier
		mi.position.y *= 1 + (size_scale_multiplier - 1.0) / 2
		hp = 50 + (10 + (level ** 0.75))

func apply_level(new_level: int) -> void:
	level = new_level
	hp = 50 + (10 + (level ** 0.75))
	mi.scale = self.size * (size_scale_multiplier ** level)
