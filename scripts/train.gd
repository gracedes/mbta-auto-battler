extends Node3D

signal damage_enemy(damage)

@export var line_name = ""     # "Green", "Red", "Orange", or "Blue"
var location_manager: Node
var anim_player: Node
const anim_mapping = {
	"Green": "attack_green",
	"Red": "attack_red",
	"Orange": "attack_orange",
	"Blue": "attack_blue"
}

const input_mapping = {
	"Green": "green_line",
	"Red": "red_line",
	"Orange": "orange_line",
	"Blue": "blue_line"
}

var attack_timer = 0.0
var ATTACK_TIMER_MAX = 5.0

@export var xp = 25
var level
var dps: float
var rof: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("trains")
	anim_player = $AnimationPlayer
	calculate_vars()
	var root = get_parent()
	location_manager = get_parent()
	root.xp_gained.connect(_on_xp_gain)
	set_active(false)
	location_manager.nearby_lines_updated.connect(_on_nearby_lines_updated)

func set_active(is_here: bool) -> void:
	visible = is_here
	for child in find_children("*", "CollisionShape3D"):
		child.set_deferred("disabled", not is_here)

func _on_nearby_lines_updated(active_lines: Array) -> void:
	set_active(line_name in active_lines)

func _process(delta: float) -> void:
	if attack_timer < ATTACK_TIMER_MAX - rof:
		attack_timer += delta
	else:
		if visible:
			if line_name in anim_mapping:
				if ATTACK_TIMER_MAX - rof < 3.33:
					anim_player.speed_scale = 3.33 / (ATTACK_TIMER_MAX - rof)
				anim_player.play(anim_mapping[line_name], )
			damage_enemy.emit(dps * attack_timer)
		attack_timer = 0.0

func _on_xp_gain(route, xp_increase) -> void:
	if route == line_name:
		xp += xp_increase
		calculate_vars()
		print(line_name, " xp:", xp, " level:", level)

func calculate_vars() -> void:
	level = (xp / 250) + 1
	dps = 5.0 * (level ** (2.0 / 3.0))
	rof = min(0.75 * (level / 5), ATTACK_TIMER_MAX - 0.2)

func _input(_event):
	debug_inputs()

func debug_inputs():
	if Input.is_action_pressed(input_mapping[line_name]):
		if Input.is_action_just_pressed("add_xp"):
			print("granting %s xp to %s" % [500, line_name])
			xp += 500
			calculate_vars()
		elif Input.is_action_just_pressed("reset_debug"):
			print("reset xp on %s" % [line_name])
			xp = 0
			calculate_vars()
