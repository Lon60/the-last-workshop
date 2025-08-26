extends PanelContainer

const GAME = preload("res://scenes/main.tscn")

func _on_play_btn_pressed() -> void:
	get_tree().change_scene_to_packed(GAME)


func _on_exit_btn_pressed() -> void:
	get_tree().quit()
