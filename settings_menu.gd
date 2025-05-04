extends Control


func _on_back_button_pressed() -> void:
	print("Back button pressed!")
	var main_menu_scene = load("res://main_menu.tscn")  # Adjust path!
	if main_menu_scene:
		print("Going back to Main Menu...")
		get_tree().change_scene_to_packed(main_menu_scene)
	else:
		print("⚠️ ERROR: Could not load MainMenu.tscn")
