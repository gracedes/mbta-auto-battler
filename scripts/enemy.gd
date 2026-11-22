extends StaticBody3D

signal hp_changed(current_hp: float, max_hp: float, level: int)

@export var level: int = 1

var BASE_HP: int = 50
var max_hp: float = BASE_HP
var hp: float = BASE_HP

@onready var hp_card: PanelContainer = $EnemyHPCard


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	_connect_emitters()
	hp_card.update_hp(hp, max_hp, level)

func _on_node_added(node: Node) -> void:
	if node.is_in_group("emitters"):
		_connect_emitters()

func _connect_emitters() -> void:
	for emitter in get_tree().get_nodes_in_group("emitters"):
		if not emitter.send_damage.is_connected(_on_damage_dealt):
			emitter.send_damage.connect(_on_damage_dealt)
	print("listening: ", get_tree().get_nodes_in_group("emitters").size(), " trains")

func _on_damage_dealt(damage) -> void:
	hp -= damage
	if hp <= 0:
		print("enemy defeated! resetting")
		level += 1
		get_parent().save.call_deferred()
		max_hp = 50.0 + 10.0 + (level ** 1.5)
		hp = max_hp
	hp_card.update_hp(hp, max_hp, level)

func apply_level(new_level: int) -> void:
	level = new_level
	max_hp = 50.0 + 10.0 + (level ** 0.75)
	hp = max_hp
	hp_card.update_hp(hp, max_hp, level)
