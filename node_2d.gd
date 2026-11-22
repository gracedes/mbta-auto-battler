# Called when the node enters the scene tree for the first time.
extends Node2D

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

var pending_routes = ROUTES.duplicate()
var current_route = ""
var routes = {}

var XP_GAIN = 25
@export var visited = {}

signal xp_gained(route, xp)

func _ready():
	create_routes_list()
	await get_tree().create_timer(1.0).timeout
	loc_ping()
	await get_tree().create_timer(1.0).timeout
	loc_ping()
	await get_tree().create_timer(1.0).timeout
	loc_ping()

func create_routes_list():
	"""  creates a dict of stations which contains a list of routes it appears on """
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
	var loc_temp = [-71.11025, 42.328316] # formatted long then lat
	var h := HTTPRequest.new()
	h.timeout = 10.0
	add_child(h)
	h.request_completed.connect(_on_loc_request_completed.bind(h))
	var err = h.request("%s/stops?filter[route]=%s&filter[longitude]=%s&filter[latitude]=%s&filter[radius]=%s" % [API_ROOT, ROUTES_STRING, loc_temp[0], loc_temp[1], MAX_RADIUS])
	if err != OK:
		h.queue_free()

func _on_loc_request_completed(_result, _response_code, _headers, body, http_request):
	http_request.queue_free()
	if _result != HTTPRequest.RESULT_SUCCESS or _response_code != 200:
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		return
	for station in json["data"]:
		name = station["attributes"]["name"]
		print(name)
		if not name in routes:
			continue
		
		var xp
		if name in visited:
			xp = XP_GAIN
		else:
			visited[name] = 1
			xp = 4 * XP_GAIN
		print(visited)
		for route in routes[name]:
			print(route + str(xp))
			# send signal to train to level up
			xp_gained.emit(route, xp)
