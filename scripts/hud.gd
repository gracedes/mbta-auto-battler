extends CanvasLayer

@onready var line_cards := {
	"Blue": $UI/GridContainer/BlueCard,
	"Green": $UI/GridContainer/GreenCard,
	"Orange": $UI/GridContainer/OrangeCard,
	"Red": $UI/GridContainer/RedCard,
}
@onready var notif_card = $UI/StationNotifBox/NotifCard


var train_nodes := {}

func _ready() -> void:
	var main := get_tree().current_scene
	main.nearby_lines_updated.connect(_on_nearby_lines_updated)
	main.xp_gained.connect(_on_xp_gained)

	await get_tree().process_frame
	for train in get_tree().get_nodes_in_group("trains"):
		if train.line_name in line_cards:
			train_nodes[train.line_name] = train



func _process(_delta: float) -> void:
	for route in train_nodes:
		var train = train_nodes[route]
		var card = line_cards[route]
		
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
			
func _on_xp_gained(route: String, xp: int) -> void:
	if route in line_cards:
		line_cards[route].unlock()

	var main := get_tree().current_scene
	if not main.visited.is_empty():
		var latest_station: String = main.visited.keys().back()
		var is_new: bool = (xp == 4 * main.XP_GAIN)
		notif_card.show_notification(latest_station, is_new)
