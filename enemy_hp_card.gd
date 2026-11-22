extends PanelContainer

@onready var hp_bar: Range = find_child("HPBar", true, false)
@onready var hp_label: Label = find_child("EnemyHPLabel", true, false)
@onready var level_label: Label = find_child("EnemyLevelLabel", true, false)

func update_hp(current_hp: float, max_hp: float, level: int) -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = max(current_hp, 0.0)
	if level_label:
		level_label.text = "Lvl: %d" % level
	if hp_label:
		hp_label.text = "HP: %d" % ceili(max(current_hp, 0.0))
