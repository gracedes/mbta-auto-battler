extends PanelContainer

@onready var status_label: Label = $%StationNotifLabel
@onready var name_label: Label = $%StationNameLabel

var active_tween: Tween

func _ready() -> void:
	modulate.a = 0.0
	hide()
	
func show_notification(station_name: String, is_new: bool) -> void:
	if is_new:
		status_label.text = "New Station Unlocked!"
	else:
		status_label.text = "Visited Station:"
	name_label.text = station_name
	
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	show()
	active_tween = create_tween()
	active_tween.tween_property(self, "modulate:a", 1.0, 0.25)
	active_tween.tween_interval(3.5)
	active_tween.tween_property(self, "modulate:a", 0.0, 0.4)
	active_tween.tween_callback(hide)
