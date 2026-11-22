extends CanvasLayer

signal start_game

const MIN_DISPLAY_TIME := 0.0

var _routes_done := false
var _min_time_met := false
var _can_dismiss := false

@onready var backdrop: ColorRect = $Backdrop
@onready var status: Label = $Backdrop/Status
@onready var tap_sound: AudioStreamPlayer = $TapSound

func _ready() -> void:
	layer = 100
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.gui_input.connect(_on_backdrop_gui_input)
	status.text = "Loading…"
	get_parent().routes_loaded.connect(_on_routes_loaded)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Game"), true)
	await get_tree().create_timer(MIN_DISPLAY_TIME).timeout
	_min_time_met = true
	_try_enable()

func _on_routes_loaded() -> void:
	_routes_done = true
	_try_enable()

func _try_enable() -> void:
	if _can_dismiss:
		return
	if _routes_done and _min_time_met:
		_can_dismiss = true
		status.text = "Tap / click anywhere to continue"
		
func _on_backdrop_gui_input(event: InputEvent) -> void:
	if not _can_dismiss:
		return
	var tapped := false
	if event is InputEventScreenTouch and event.pressed:
		tapped = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped = true
	if tapped:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Game"), false)
		tap_sound.play()
		start_game.emit()
		await tap_sound.finished
		queue_free()
