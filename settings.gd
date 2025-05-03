extends Node

signal cache_updated(key_name: String)
signal settings_updated(key_name: String)


const CACHE_FILE_PATH: String = "user://cache.json"
const SETTINGS_FILE_PATH: String = "user://settings.json"


var args: Dictionary = {}
var settings: Dictionary = {}
var cache: Dictionary = {}


func _ready() -> void:
	reload_cache()
	reload_settings()
	load_cmdline_args()
	load_environment_file()


func load_environment_file() -> void:
	var filepath: String = ""
	if FileAccess.file_exists("user://.env"):
		filepath = "user://.env"
	elif FileAccess.file_exists("res://.env"):
		filepath = "res://.env"
	else:
		return
	
	var file = FileAccess.open(filepath, FileAccess.READ)
	while file.get_position() < file.get_length():
		var line: String = file.get_line()
		var split: PackedStringArray = line.split("=")
		OS.set_environment(split[0], split[1].rstrip("\"").lstrip("\""))


func load_cmdline_args() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.contains("="):
			var key_value: PackedStringArray = arg.split("=")
			var value: Variant
			if key_value[1].to_lower() == "true":
				value = true
			else:
				value = key_value[1]
			args[key_value[0].trim_prefix("--")] = value
		else:
			args[arg.trim_prefix("--")] = ""


func reload_cache() -> void:
	var file: String = FileAccess.get_file_as_string(CACHE_FILE_PATH)
	if file:
		var json: Dictionary = JSON.parse_string(file)
		if json:
			cache = json


func update_cache(key_name: String, save_data: Dictionary) -> void:
	reload_cache()
	if key_name not in cache:
		cache[key_name] = {}
	for key: String in save_data:
		cache[key_name][key] = save_data[key]
	_save_cache()
	cache_updated.emit(key_name)


func _save_cache() -> void:
	var file := FileAccess.open(CACHE_FILE_PATH, FileAccess.WRITE)
	if not file:
		Console.print("Error opening cache file for writing: %s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(cache, "\t"))
	file.close()


func reload_settings() -> void:
	var file := FileAccess.get_file_as_string(SETTINGS_FILE_PATH)
	if file:
		var json: Dictionary = JSON.parse_string(file)
		if json:
			settings = json


func update_settings(key_name: String, save_data: Dictionary) -> void:
	reload_settings()
	if key_name not in settings:
		settings[key_name] = {}
	for key: String in save_data:
		settings[key_name][key] = save_data[key]
	_save_settings()
	settings_updated.emit(key_name)


func _save_settings() -> void:
	var file := FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	if not file:
		Console.print("Error opening settings file for writing: %s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(settings, "\t"))
	file.close()


static func to_bool(_value: String) -> bool:
	return _value.to_lower() == "true"
