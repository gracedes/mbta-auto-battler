extends Node3D

@export var line_name: String = "Blue"
@export var location_manager: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_active(false)
	if location_manager:
		location_manager.nearby_lines_updated.connect(_on_nearby_lines_updated)

func set_active(is_here: bool) -> void:
	visible = is_here
	for child in find_children("*", "CollisionShape3D"):
		child.set_deferred("disabled", not is_here)
		
func _on_nearby_lines_updated(active_lines: Array) -> void:
	set_active(line_name in active_lines)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
