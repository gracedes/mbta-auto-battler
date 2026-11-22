extends CanvasLayer

signal start_game

const MIN_DISPLAY_TIME := 0.0

var _routes_done := false
var _min_time_met := false
var _user_clicked := false
var _started := false

@onready var backdrop: Control = $Backdrop
@onready var status: Label = $Backdrop/StatusLabel
@onready var tap_sound: AudioStreamPlayer = $TapSound

func _ready() -> void:
	layer = 100
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.gui_input.connect(_on_backdrop_gui_input)
	status.text = "Click to Start"
	get_parent().routes_loaded.connect(_on_routes_loaded)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Game"), true)
	await get_tree().create_timer(MIN_DISPLAY_TIME).timeout
	_min_time_met = true
	_try_start()

func _on_routes_loaded() -> void:
	_routes_done = true
	_try_start()

func _on_backdrop_gui_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventScreenTouch and event.pressed:
		tapped = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped = true

	if tapped and not _user_clicked:
		_user_clicked = true
		tap_sound.play()
		status.text = "Loading..."
		_try_start()
		
func _try_start() -> void:
	if _started:
		return
	if _user_clicked and _routes_done and _min_time_met:
		_started = true
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Game"), false)
		start_game.emit()
		if tap_sound.playing:
			await tap_sound.finished
		queue_free()
