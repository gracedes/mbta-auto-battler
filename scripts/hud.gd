extends CanvasLayer

@export var unlocked_lines: Array[String] = []
@export var line_xp: Dictionary = { "Blue": 0, "Green": 0, "Orange": 0, "Red": 0}

const MAX_XP_PER_LEVEL := 500

@onready var line_cards := {
	"Blue": $UI/GridContainer/BlueCard,
	"Green": $UI/GridContainer/GreenCard,
	"Orange": $UI/GridContainer/OrangeCard,
	"Red": $UI/GridContainer/RedCard,
}

func _ready() -> void:
	var main := get_parent()
	main.xp_gained.connect(_on_xp_gained)
	
	for route in line_cards:
		if route in unlocked_lines:
			line_cards[route].unlock()
			line_cards[route].set_xp(line_xp[route],MAX_XP_PER_LEVEL)
		else:
			line_cards[route].is_unlocked = false

func _on_xp_gained(route: String, xp: int) -> void:
	if not route in line_cards:
		return
	if not route in unlocked_lines:
		unlocked_lines.append(route)
		line_cards[route].unlock()
		
	line_xp[route] += xp
	line_cards[route].set_xp(line_xp[route], MAX_XP_PER_LEVEL)
