@tool
extends PanelContainer

@export var line_name: String = "Blue":
	set(value):
		line_name = value
		if is_node_ready():
			_update_visual_state()

@export var border_color: Color = Color("#003DA5"):
	set(value):
		border_color = value
		if is_node_ready():
			_update_visual_state()

@export var is_unlocked: bool = false:
	set(value):
		is_unlocked = value
		if is_node_ready():
			_update_visual_state()

@onready var name_label: Label = %LineNameLabel
@onready var xp_bar: Range = %XPBar
@onready var dps_label: Label = %DPSLabel
@onready var level_label: Label = %LevelLabel
@onready var lock_icon: TextureRect = %LockIcon

func _ready() -> void:
	_update_visual_state()

func _update_visual_state() -> void:
	var style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if is_unlocked:
		style.border_color = border_color
		name_label.text = line_name
		dps_label.visible = true
		level_label.visible = true
		xp_bar.visible = true
		lock_icon.visible = false
	else:
		style.border_color = Color("#666666")
		name_label.text = "???"
		dps_label.visible = false
		level_label.visible = false
		xp_bar.visible = false
		lock_icon.visible = true
	add_theme_stylebox_override("panel", style)

func unlock() -> void:
	if not is_unlocked:
		is_unlocked = true
		set_stats(1, 1)

func set_xp(current: float, max_xp: float) -> void:
	xp_bar.max_value = max_xp
	xp_bar.value = current

func set_stats(level: int, dps: int) -> void:
	if not is_unlocked:
		return
	level_label.text = "Lvl: %d" % level
	dps_label.text = "DPS: %d" % dps
