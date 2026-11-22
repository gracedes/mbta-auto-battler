extends CanvasLayer

const NOTIF_CARD_SCENE := preload("res://assets/ui/notif_card.tscn") # Update path if in a subfolder

@onready var line_cards := {
	"Blue": $UI/GridContainer/BlueCard,
	"Green": $UI/GridContainer/GreenCard,
	"Orange": $UI/GridContainer/OrangeCard,
	"Red": $UI/GridContainer/RedCard,
}
@onready var notif_box: Panel = $UI/StationNotifBox
@onready var notif_stack: VBoxContainer = $UI/StationNotifBox/MarginContainer/NotifStack

var train_nodes := {}

func _ready() -> void:
	notif_box.hide()

	var main := get_tree().current_scene
	main.nearby_lines_updated.connect(_on_nearby_lines_updated)
	main.station_visited.connect(_on_station_visited)

	await get_tree().process_frame
	for train in get_tree().get_nodes_in_group("trains"):
		if train.line_name in line_cards:
			train_nodes[train.line_name] = train

func _process(_delta: float) -> void:
	notif_box.visible = notif_stack.get_child_count() > 0

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

func _on_station_visited(station_name: String, is_new: bool) -> void:
	while notif_stack.get_child_count() >= 2:
		var oldest := notif_stack.get_child(0)
		notif_stack.remove_child(oldest)
		oldest.queue_free()

	var card := NOTIF_CARD_SCENE.instantiate()
	notif_stack.add_child(card)
	card.setup(station_name, is_new)
	notif_box.show()
