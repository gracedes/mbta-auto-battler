# Called when the node enters the scene tree for the first time.
extends Node2D

@onready var api_key_file = "res://api-key.txt"
const API_ROOT = "https://api-v3.mbta.com/stops?"
var headers = []

const MAX_RADIUS = 0.01    # 0.01 = 0.5 miles
const ROUTES = ["Green", "Red", "Orange", "Blue"]
const ROUTES_STRING = "Green,Red,Orange,Blue"

@export var visited = {}

func _ready():
	var api_key = load_api_key()
	headers = PackedStringArray(["X-API-Key: " + api_key])
	loc_ping()

func loc_ping():
	var loc_temp = [-71.141287, 42.39583]
	
	$HTTPRequest.request_completed.connect(_on_loc_request_completed)
	$HTTPRequest.request("%sfilter[route]=%s&filter[longitude]=%s&filter[latitude]=%s&filter[radius]=%s" % [API_ROOT, ROUTES_STRING, loc_temp[0], loc_temp[1], MAX_RADIUS], headers)
	
	return


func _on_loc_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	var lines = {}
	for line in ROUTES:
		lines[line] = ""
		
	for station in json["data"]:
		#station_lines = 
		print(station)
	return json
	

func load_api_key() -> String:
	var key := OS.get_environment("MBTA_API_KEY")
	if key == "":
		if FileAccess.file_exists(api_key_file):
			key = FileAccess.get_file_as_string(api_key_file)
		else:
			push_error("No MBTA API key: set mbta_key_file or create " + api_key_file)
			return ""
	return key.strip_edges()
