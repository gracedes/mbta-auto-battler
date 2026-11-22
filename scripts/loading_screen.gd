extends CanvasLayer

signal start_game

const MIN_DISPLAY_TIME := 0.0
const SAVE_PATH := "user://save.json"

var _routes_done := false
var _min_time_met := false
var _user_clicked := false
var _started := false

@onready var backdrop: Control = $Backdrop
@onready var status: Label = $Backdrop/StatusLabel
@onready var tap_sound: AudioStreamPlayer = $TapSound
@onready var new_player_screen: Control = find_child("NewPlayerScreen", true, false)
@onready var confirm_button: Button = find_child("ConfirmButton", true, false)

func _ready() -> void:
	layer = 100
	if new_player_screen:
		new_player_screen.hide()
	if confirm_button:
		confirm_button.pressed.connect(_on_new_player_continue_pressed)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.gui_input.connect(_on_backdrop_gui_input)
	status.text = "Click to Start"
	
	var main := get_parent()
	main.routes_loaded.connect(_on_routes_loaded)
	if main._routes_announced:
		_routes_done = true

	var game_bus := AudioServer.get_bus_index("Game")
	if game_bus != -1:
		AudioServer.set_bus_mute(game_bus, true)
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
		if not FileAccess.file_exists(SAVE_PATH) and new_player_screen:
			backdrop.hide()
			new_player_screen.show()
		else:
			_finish_loading()

func _on_new_player_continue_pressed() -> void:
	if tap_sound and tap_sound.stream != null:
		tap_sound.play()
	_finish_loading()

func _finish_loading() -> void:
	var game_bus := AudioServer.get_bus_index("Game")
	if game_bus != -1:
		AudioServer.set_bus_mute(game_bus, false)
	start_game.emit()
	queue_free()
