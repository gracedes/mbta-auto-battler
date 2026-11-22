extends Node3D

@export var line_name: String = "Green"
@export var location_manager: Node

var attack_timer = 0.0
var ATTACK_TIMER_MAX = 5.0

@export var xp = 0
var level
var dps 
var rof

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	calculate_vars()
	var root = get_parent()   # or however it's reached
	root.xp_gained.connect(_on_xp_gain)
	set_active(false)
	if location_manager:
		location_manager.nearby_lines_updated.connect(_on_nearby_lines_updated)
	else:
		print("WARNING: location_manager not assigned on ", name)

func set_active(is_here: bool) -> void:
	visible = is_here
	for child in find_children("*", "CollisionShape3D"):
		child.set_deferred("disabled", not is_here)

func _on_nearby_lines_updated(active_lines: Array) -> void:
	print(name, " received signal! Active lines: ", active_lines)
	set_active(line_name in active_lines)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if attack_timer < ATTACK_TIMER_MAX - rof:
		attack_timer += delta
	else:
		#attack
		print(attack_timer)
		attack_timer = 0.0

func _on_xp_gain(route, xp_increase):
	if route == line_name:
		xp += xp_increase
		calculate_vars()
	
func calculate_vars():
	level = (xp / 250) + 1
	dps = 2.0 * (level ** (2.0/3.0))
	rof = min(0.1 * (level % 5), ATTACK_TIMER_MAX - 0.25)
	print("xp: " + str(xp) + " level: " + str(level))
