@tool
extends PanelContainer

@export var line_name: String = "Blue":
	set(value):
		line_name = value
		if is_node_ready():
			$MarginContainer/HBoxContainer/VBoxContainer/LineNameLabel.text = value
			

@export var border_color: Color = Color("#003DA5"):
	set(value):
		border_color = value
		if is_node_ready():
			var style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat
			style.border_color = value
			add_theme_stylebox_override("panel", style)

@onready var xp_bar: Range = $MarginContainer/HBoxContainer/XPBar

func _ready() -> void:
	line_name = line_name
	border_color = border_color
	
func set_xp(current: float, max_xp: float) -> void:
	xp_bar.max_value = max_xp
	xp_bar.value = current
