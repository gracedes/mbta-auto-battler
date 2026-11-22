extends StaticBody3D


@export var level: int = 1

var BASE_HP: int = 50
var max_hp: float = BASE_HP
var hp: float = BASE_HP

@onready var hp_bar: Range = %HPBar
@onready var hp_label: Label = %HPLabel
@onready var level_label: Label = %LevelLabel

func _ready() -> void:
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
	hp -= damage
	if hp <= 0:
		print("enemy defeated! resetting")
		level += 1
		get_parent().save.call_deferred()
		hp = 50 + (10 + (level ** 1.5))
		max_hp = hp
	set_stats()
	
func set_stats() -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	level_label.text = "Lvl: %d" % level
	hp_label.text = "HP: %d" % hp
	

func apply_level(new_level: int) -> void:
	level = new_level
	hp = 50 + (10 + (level ** 0.75))
