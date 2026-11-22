extends CanvasLayer

@onready var line_cards := {
	"Blue": $UI/GridContainer/BlueCard,
	"Green": $UI/GridContainer/GreenCard,
	"Orange": $UI/GridContainer/OrangeCard,
	"Red": $UI/GridContainer/RedCard,
}

var train_nodes := {}

func _ready() -> void:
	# Wait one frame so all train nodes finish their _ready() and join the "trains" group
	await get_tree().process_frame
	for train in get_tree().get_nodes_in_group("trains"):
		if train.line_name in line_cards:
			train_nodes[train.line_name] = train

	# Unlock cards whenever main.gd unlocks a train line
	var main := get_parent()
	if main.has_signal("nearby_lines_updated"):
		main.nearby_lines_updated.connect(_on_nearby_lines_updated)

func _process(_delta: float) -> void:
	# Keep XP bars, Lvl, and DPS synced with the actual train nodes (including debug cheats!)
	for route in train_nodes:
		var train = train_nodes[route]
		var card = line_cards[route]
		
		# Unlock automatically if the train is visible or gained XP via debug keys
		if not card.is_unlocked and (train.visible or train.xp > 25):
			card.unlock()
			
		if card.is_unlocked:
			var current_level_xp: int = int(train.xp) % 250
			card.set_xp(current_level_xp, 250)
			card.set_stats(train.level, roundi(train.dps))

func _on_nearby_lines_updated(active_lines: Array) -> void:
	for route in active_lines:
		if route in line_cards:
			line_cards[route].unlock()
