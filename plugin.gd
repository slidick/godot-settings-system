@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("Settings", "res://addons/settings_system/settings.gd")

func _exit_tree():
	remove_autoload_singleton("Settings")
