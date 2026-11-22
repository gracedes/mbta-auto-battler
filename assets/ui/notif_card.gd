extends Control

@export var display_duration: float = 8.0

@onready var status_label: Label = find_child("StationNotifLabel", true, false)
@onready var name_label: Label = find_child("StationNameLabel", true, false)

func setup(station_name: String, is_new: bool) -> void:
	status_label.text = "New Station Unlocked!" if is_new else "Visited Station:"
	name_label.text = station_name

	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	tween.tween_interval(display_duration)
	tween.tween_property(self, "modulate:a", 0.0, 0.35)
	tween.tween_callback(queue_free)
