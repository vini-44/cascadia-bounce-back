extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.  


func _pressed():
	if disabled:
		return
	disabled = true
	var click: AudioStreamPlayer = $"../MenuClick"
	click.play()
	await click.finished
	print("play!")
	if get_tree().change_scene_to_file("res://scenes/world_map.tscn") != OK:
		disabled = false
