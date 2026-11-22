# Called when the node enters the scene tree for the first time.
extends Node2D

signal nearby_lines_updated(active_lines: Array)
signal xp_gained(route, xp)
signal location_error(code: int)   # 1 = denied, 2 = unavailable, 3 = timeout
signal station_visited(station_name: String, is_new: bool)

const API_ROOT = "https://mbta.gracie.foo"
var headers = []

const MAX_RADIUS = 0.002    # 0.01 = 0.5 miles
const ROUTES = ["Green", "Red", "Orange", "Blue"]
const ROUTE_FILTERS = {
	"Green": "Green-B,Green-C,Green-D,Green-E",
	"Red": "Red",
	"Orange": "Orange",
	"Blue": "Blue",
}
const ROUTES_STRING = "Green-B,Green-C,Green-D,Green-E,Red,Orange,Blue"

const VISIT_COOLDOWN := 60.0 * 60.0   # one hour

var pending_routes = ROUTES.duplicate()
var current_route = ""
var routes = {}

const TEST_LOCATIONS := [
	[-71.0624242, 42.3563946],  # Park Street     (Red + Green)
	[-71.0861765, 42.3624908],  # Kendall/MIT     (Red + Green B)
	[-71.075727,  42.34735],    # Back Bay        (Green C)
	[-71.141287,  42.39583],    # Alewife         (Red N terminus)
	[-71.005409,  42.251809],   # Quincy Center   (Red S terminus)
	[-71.06129,   42.365577],   # North Station   (Orange + Blue)
	[-71.071097,  42.43668],    # Oak Grove       (Orange N terminus)
	[-71.113943,  42.300713],   # Forest Hills    (Orange S terminus)
	[-71.055242,  42.352271],   # South Station   (Blue + Orange + Red)
	[-71.030395,  42.374262],   # Airport         (Blue only)
	[-70.9925332, 42.4078425],  # Revere Beach    (Blue E terminus)
]
var location_index = 0
var station_cooldown = true

const PING_INTERVAL := 15.0
var ping_timer := PING_INTERVAL

var XP_GAIN = 25
@export var visited = {}
@export var unlocked_trains = {}

var _geo = null
var _pos_cb = null
var _pos_err_cb = null

func _ready():
	create_routes_list()
	_setup_geo()

func _process(delta: float) -> void:
	ping_timer += delta
	if ping_timer >= PING_INTERVAL:
		ping_timer = 0.0
		print("pinging location")
		loc_ping()

func _setup_geo() -> void:
	if OS.get_name() != "Web":
		return
	var navigator = JavaScriptBridge.get_interface("navigator")
	if navigator == null or "geolocation" not in navigator:
		push_error("no geolocation available (page must be served over HTTPS)")
		return
	_geo = navigator["geolocation"]
	_pos_cb = JavaScriptBridge.create_callback(_on_position)
	_pos_err_cb = JavaScriptBridge.create_callback(_on_position_error)

func create_routes_list():
	$HTTPRequest.request_completed.connect(_populate_routes)
	_start_next()

func _start_next() -> void:
	if pending_routes.is_empty():
		return
	var route = pending_routes[0]
	var filter = ROUTE_FILTERS[route]
	var err = $HTTPRequest.request(API_ROOT + "/stops?filter%5Broute%5D=" + filter)
	if err != OK:
		push_error("send %s failed: %s" % [route, error_string(err)])
		return
	pending_routes.pop_front()
	current_route = route

func _populate_routes(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	for station in json["data"]:
		@warning_ignore("shadowed_variable_base_class")
		var name = station["attributes"]["name"]
		if not name in routes:
			routes[name] = [current_route]
		elif current_route not in routes[name]:
			routes[name].append(current_route)
	_start_next()

func loc_ping():
	if _geo != null:
		_geo.call("getCurrentPosition", _pos_cb, _pos_err_cb,
			{"enableHighAccuracy": true, "timeout": 15000, "maximumAge": 10000})
		return
	_query_nearby_stops(TEST_LOCATIONS[location_index % len(TEST_LOCATIONS)])

func _on_position(args: Array) -> void:
	var coords = args[0]["coords"]
	_query_nearby_stops([float(coords["longitude"]), float(coords["latitude"])])

func _on_position_error(args: Array) -> void:
	var err = args[0]
	var code = int(err["code"])
	match code:
		1: push_error("location permission DENIED")
		2: push_error("position unavailable")
		3: push_error("location request timed out")
		_: push_error("unknown location error: " + str(err))
	location_error.emit(code)

func _query_nearby_stops(loc: Array) -> void:
	var h := HTTPRequest.new()
	h.timeout = 10.0
	add_child(h)
	h.request_completed.connect(_on_loc_request_completed.bind(h))
	var err = h.request(
		"%s/stops?filter%%5Broute%%5D=%s&filter%%5Blatitude%%5D=%s&filter%%5Blongitude%%5D=%s&filter%%5Bradius%%5D=%s"
		% [API_ROOT, ROUTES_STRING, loc[1], loc[0], MAX_RADIUS]
	)
	if err != OK:
		push_error("loc query failed: %s" % error_string(err))
		h.queue_free()

func _on_loc_request_completed(_result, _response_code, _headers, body, http_request):
	http_request.queue_free()
	if _result != HTTPRequest.RESULT_SUCCESS or _response_code != 200:
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		return
	
	var xp = 0
	var now = Time.get_unix_time_from_system()
	
	for station in json["data"]:
		name = station["attributes"]["name"]
		if not name in routes:
			continue
		var is_new := false
		if not name in visited:
			visited[name] = now
			xp = 4 * XP_GAIN
			is_new = true
			print(name)
		elif station_cooldown and now - visited[name] < VISIT_COOLDOWN:
			continue
		else:
			visited[name] = now
			xp = XP_GAIN
			print(name)
		station_visited.emit(name, is_new)

		for route in routes[name]:
			print(route + " +" + str(xp))
			if route not in unlocked_trains:
				unlocked_trains[route] = 1
				nearby_lines_updated.emit(unlocked_trains.keys())
			xp_gained.emit(route, xp)

func _input(_event):
	debug_inputs()

func debug_inputs():
	if Input.is_action_pressed("debug"):
		if Input.is_action_just_pressed("next"):
			print("spoofing next location in list and sending location ping")
			location_index += 1
			loc_ping()
		elif Input.is_action_just_pressed("prev"):
			print("spoofing previous location in list and sending location ping")
			location_index -= 1
			loc_ping()
		elif Input.is_action_just_pressed("ping_location"):
			print("sending location ping")
			loc_ping()
		elif Input.is_action_just_pressed("toggle_cooldown"):
			if station_cooldown:
				print("station cooldown toggled off")
				station_cooldown = false
			else:
				print("station cooldown toggled on")
				station_cooldown = true
		elif Input.is_action_just_pressed("reset_all"):
			print("restarting scene")
			await get_tree().process_frame
			get_tree().reload_current_scene()
		elif Input.is_action_just_pressed("reset_debug"):
			print("resetting debug options")
			station_cooldown = true
			location_index = 0
