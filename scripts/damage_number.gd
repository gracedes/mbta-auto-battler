class_name DamageNumber
extends Label

@export var amount: int = 1
@export var start_pos := Vector2.ZERO      # screen coordinates
@export var life: float = 1.2
@export var rise: float = 70.0
@export var color: Color = Color("ffffff")

func _ready() -> void:
	text = "-" + str(amount)
	modulate = color
	add_theme_color_override("outline_color", Color.BLACK)
	add_theme_constant_override("outline_size", 8)
	size = get_minimum_size()
	var from := start_pos - size / 2.0
	position = from
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", from - Vector2(0, rise), life)
	tween.tween_property(self, "modulate:a", 0.0, life * 0.4).set_delay(life * 0.6)
	await tween.finished
	queue_free()
