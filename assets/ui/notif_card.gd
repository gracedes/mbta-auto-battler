extends Control

@onready var status_label: Label = find_child("StationNotifLabel", true, false)
@onready var name_label: Label = find_child("StationNameLabel", true, false)

var display_timer: float = 0.0

func _ready() -> void:
	visible = false
	modulate.a = 0.0

func _process(delta: float) -> void:
	if display_timer > 0.0:
		display_timer -= delta
		if display_timer <= 0.0:
			visible = false
			modulate.a = 0.0

func show_notification(station_name: String, is_new: bool) -> void:
	status_label.text = "New Station Unlocked!" if is_new else "Visited Station:"
	name_label.text = station_name

	visible = true
	modulate.a = 1.0
	display_timer = 3.5
