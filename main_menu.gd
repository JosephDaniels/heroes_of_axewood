extends Control

func _ready():
	print("Main Menu script is running!")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_new_game_button_pressed() -> void:
	print("Starting New Game!")

	var game_scene = load("res://game.tscn")  # Adjust this path if yours is different
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		print("❌ ERROR: Could not load game.tscn")

func _on_settings_button_pressed() -> void:
	print("Settings button pressed!")
	var settings_scene = load("res://settings_menu.tscn")
	if settings_scene:
		get_tree().change_scene_to_packed(settings_scene)
	else:
		print("⚠️ ERROR: Could not load SettingsMenu.tscn!")
