extends CanvasLayer

signal restart # signal means it is going to emit

func _on_restart_button_pressed() -> void:
	restart.emit() # we emit restart out of this scene
