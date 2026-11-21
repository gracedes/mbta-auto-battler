# Called when the node enters the scene tree for the first time.
extends Node2D

@onready var api_key_file = "res://api-key.txt"
const API_ROOT = "https://api-v3.mbta.com"

func _ready():
	var api_key = load_api_key()
	var headers := PackedStringArray([
		"X-API-Key: " + api_key,
	])
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request(API_ROOT + "/stops?filter%5Broute%5D=Red", headers)

func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	for station in json["data"]:
		print(station["attributes"]["name"])
		

func load_api_key() -> String:
	var key := OS.get_environment("MBTA_API_KEY")
	if key == "":
		if FileAccess.file_exists(api_key_file):
			key = FileAccess.get_file_as_string(api_key_file)
		else:
			push_error("No MBTA API key: set mbta_key_file or create " + api_key_file)
			return ""
	return key.strip_edges()
