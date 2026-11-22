extends Node3D

signal send_damage(damage)

@warning_ignore("shadowed_global_identifier")
const DamageNumber := preload("res://scripts/damage_number.gd")
@export var train: Node

var _layer: CanvasLayer
var last_damage: float = 0.0

func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 10
	add_child(_layer)
	train.damage_enemy.connect(_on_damage_dealt)
	self.position.x = train.position.x

func _on_damage_dealt(damage):
	last_damage = damage

# Called by the animation's Call Method track at the impact frame.
func on_anim_hit() -> void:
	send_damage.emit(last_damage)
	spawn_damage(last_damage)

func spawn_damage(amount: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var screen_pos := cam.unproject_position(global_position)
	var popup := DamageNumber.new()
	@warning_ignore("narrowing_conversion")
	popup.amount = amount
	popup.start_pos = screen_pos + Vector2(
		randf_range(-20.0, 20.0), randf_range(-20.0, 20.0)
	)
	_layer.add_child(popup)
