# Called when the node enters the scene tree for the first time.
extends Node2D

const API_ROOT = "https://mbta.gracie.foo"
var headers = []

const MAX_RADIUS = 0.01    # 0.01 = 0.5 miles
const ROUTES = ["Green", "Red", "Orange", "Blue"]
const ROUTES_STRING = "Green,Red,Orange,Blue"

@export var visited = {}

func _ready():
	loc_ping()

func loc_ping():
	var loc_temp = [-71.141287, 42.39583]
	$HTTPRequest.request_completed.connect(_on_loc_request_completed)
	$HTTPRequest.request("%s/stops?filter[route]=%s&filter[longitude]=%s&filter[latitude]=%s&filter[radius]=%s" % [API_ROOT, ROUTES_STRING, loc_temp[0], loc_temp[1], MAX_RADIUS])
	return

func _on_loc_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	for station in json["data"]:
		#station_lines = 
		print(station)
	return json
	
