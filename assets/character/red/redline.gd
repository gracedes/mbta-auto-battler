extends Node3D

@export var line_name: String = "Red"
@export var location_manager: Node

func _ready() -> void:
	set_active(false)
	if location_manager:
		location_manager.nearby_lines_updated.connect(_on_nearby_lines_updated)
	else:
		print("WARNING: location_manager not assigned on ", name)

func set_active(is_here: bool) -> void:
	visible = is_here
	for child in find_children("*", "CollisionShape3D"):
		child.set_deferred("disabled", not is_here)

func _on_nearby_lines_updated(active_lines: Array) -> void:
	print(name, " received signal! Active lines: ", active_lines)
	set_active(line_name in active_lines)
